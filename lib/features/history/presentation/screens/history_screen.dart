import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/networking/curl_generator.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/method_badge.dart';
import '../../../../core/widgets/status_code_badge.dart';
import '../../../request_builder/presentation/providers/request_builder_provider.dart';
import '../../domain/models/history_entry_entity.dart';
import '../providers/history_provider.dart';

/// HistoryScreen shows recently executed requests, response status,
/// round-trip latency, payload sizes, and one-click replay options.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Request History',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          historyAsync.maybeWhen(
            data: (entries) {
              if (entries.isEmpty) return const SizedBox.shrink();
              return IconButton(
                tooltip: 'Clear All History',
                icon: const Icon(Icons.delete_sweep_outlined, size: 22),
                onPressed: () => _confirmClearHistory(context, ref),
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 12),
                Text(
                  'Failed to load history: $error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
        ),
        data: (entries) {
          if (entries.isEmpty) {
            return const EmptyState(
              icon: Icons.history_rounded,
              title: 'No History Recorded',
              description:
                  'Every request executed in the Request Builder is automatically audited here with latency, headers, and one-tap replay.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: entries.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final entry = entries[index];
              return _HistoryCard(
                entry: entry,
                onTap: () => _showHistoryDetailSheet(context, entry, ref),
                onReplay: () => _replayRequest(context, entry, ref),
                onCopyCurl: () => _copyCurl(context, entry),
                onDelete: () => _deleteEntry(entry.id, ref),
              );
            },
          );
        },
      ),
    );
  }

  void _replayRequest(
    BuildContext context,
    HistoryEntryEntity entry,
    WidgetRef ref,
  ) {
    ref
        .read(requestBuilderProvider.notifier)
        .loadRequest(entry.toHttpRequestData());
    context.go('/builder');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Replaying ${entry.method} ${entry.url} in builder.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _copyCurl(BuildContext context, HistoryEntryEntity entry) {
    final curl = CurlGenerator.generate(entry.toHttpRequestData());
    Clipboard.setData(ClipboardData(text: curl));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('cURL command copied to clipboard.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _deleteEntry(String id, WidgetRef ref) async {
    await ref.read(historyRepositoryProvider).deleteEntry(id);
  }

  Future<void> _confirmClearHistory(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All History?'),
        content: const Text(
          'This will permanently delete all recorded request audit logs. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(historyRepositoryProvider).clearAllHistory();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request history cleared.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showHistoryDetailSheet(
    BuildContext context,
    HistoryEntryEntity entry,
    WidgetRef ref,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          maxChildSize: 0.95,
          minChildSize: 0.4,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.dividerColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      MethodBadge(method: entry.method),
                      const SizedBox(width: 8),
                      StatusCodeBadge(
                        statusCode: entry.statusCode,
                        statusMessage: entry.statusMessage,
                      ),
                      const Spacer(),
                      Text(
                        '${entry.executedAt.hour.toString().padLeft(2, '0')}:${entry.executedAt.minute.toString().padLeft(2, '0')}:${entry.executedAt.second.toString().padLeft(2, '0')}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SelectableText(
                    entry.url,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _StatChip(
                        icon: Icons.timer_outlined,
                        label: 'Duration',
                        value: entry.formattedDuration,
                      ),
                      const SizedBox(width: 12),
                      _StatChip(
                        icon: Icons.data_usage_rounded,
                        label: 'Payload',
                        value: entry.formattedSize,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          icon: const Icon(Icons.replay_rounded, size: 18),
                          label: const Text('Replay Request'),
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            _replayRequest(context, entry, ref);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.code_rounded, size: 18),
                        label: const Text('cURL'),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          _copyCurl(context, entry);
                        },
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  // Request Headers
                  Text(
                    'Request Headers (${entry.requestHeaders.length})',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (entry.requestHeaders.isEmpty)
                    Text(
                      'No headers sent',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    )
                  else
                    ...entry.requestHeaders.map(
                      (h) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${h.key}: ',
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                h.value,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const Divider(height: 32),
                  // Response Headers
                  Text(
                    'Response Headers (${entry.responseHeaders.length})',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (entry.responseHeaders.isEmpty)
                    Text(
                      'No response headers recorded',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    )
                  else
                    ...entry.responseHeaders.entries.map(
                      (h) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${h.key}: ',
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                h.value.join(', '),
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (entry.bodyContent != null &&
                      entry.bodyContent!.isNotEmpty) ...[
                    const Divider(height: 32),
                    Text(
                      'Persisted Request Body',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SelectableText(
                        entry.bodyContent!,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Delete from History'),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _deleteEntry(entry.id, ref);
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final HistoryEntryEntity entry;
  final VoidCallback onTap;
  final VoidCallback onReplay;
  final VoidCallback onCopyCurl;
  final VoidCallback onDelete;

  const _HistoryCard({
    required this.entry,
    required this.onTap,
    required this.onReplay,
    required this.onCopyCurl,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.dividerColor.withValues(alpha: isDark ? 0.3 : 0.6),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  MethodBadge(method: entry.method),
                  const SizedBox(width: 8),
                  StatusCodeBadge(
                    statusCode: entry.statusCode,
                    statusMessage: entry.statusMessage.isNotEmpty
                        ? entry.statusMessage
                        : null,
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Replay in Builder',
                    icon: const Icon(Icons.replay_rounded, size: 20),
                    onPressed: onReplay,
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 20),
                    onSelected: (val) {
                      if (val == 'replay') {
                        onReplay();
                      } else if (val == 'curl') {
                        onCopyCurl();
                      } else if (val == 'delete') {
                        onDelete();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'replay',
                        child: Row(
                          children: [
                            Icon(Icons.replay_rounded, size: 18),
                            SizedBox(width: 8),
                            Text('Replay'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'curl',
                        child: Row(
                          children: [
                            Icon(Icons.code_rounded, size: 18),
                            SizedBox(width: 8),
                            Text('Copy cURL'),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: Colors.red,
                            ),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                entry.url,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    entry.formattedDuration,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.data_usage_rounded,
                    size: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    entry.formattedSize,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${entry.executedAt.hour.toString().padLeft(2, '0')}:${entry.executedAt.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
