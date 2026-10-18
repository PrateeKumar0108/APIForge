import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../collections/presentation/providers/collections_provider.dart';
import '../../../history/presentation/providers/history_provider.dart';
import '../../../import_export/domain/services/collection_import_service.dart';

/// SettingsScreen manages application configuration, themes,
/// local database retention policies, and security preferences.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeModeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Appearance', theme),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Theme Mode',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<ThemeMode>(
                      segments: const [
                        ButtonSegment(
                          value: ThemeMode.dark,
                          icon: Icon(Icons.dark_mode_outlined, size: 16),
                          label: Text('Dark'),
                        ),
                        ButtonSegment(
                          value: ThemeMode.light,
                          icon: Icon(Icons.light_mode_outlined, size: 16),
                          label: Text('Light'),
                        ),
                        ButtonSegment(
                          value: ThemeMode.system,
                          icon: Icon(Icons.brightness_auto_outlined, size: 16),
                          label: Text('System'),
                        ),
                      ],
                      selected: {currentTheme},
                      onSelectionChanged: (newSelection) {
                        ref
                            .read(themeModeProvider.notifier)
                            .setThemeMode(newSelection.first);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Privacy & Security', theme),
          Card(
            child: Column(
              children: [
                const SwitchListTile(
                  title: Text('Redact Secrets in Logs'),
                  subtitle: Text(
                    'Always masks Bearer tokens, passwords, and sensitive keys',
                  ),
                  value: true,
                  onChanged: null, // Enforced policy
                ),
                const Divider(height: 1),
                Consumer(
                  builder: (context, ref, _) {
                    final persistBody = ref.watch(
                      historyPersistRequestBodyProvider,
                    );
                    return SwitchListTile(
                      title: const Text('Persist Request Bodies in History'),
                      subtitle: const Text(
                        'Off by default to prevent accidental credential storage',
                      ),
                      value: persistBody,
                      onChanged: (val) {
                        ref
                                .read(
                                  historyPersistRequestBodyProvider.notifier,
                                )
                                .state =
                            val;
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Storage & History', theme),
          Card(
            child: Column(
              children: [
                Consumer(
                  builder: (context, ref, _) {
                    final retention = ref.watch(historyRetentionLimitProvider);
                    return ListTile(
                      leading: const Icon(Icons.storage_outlined),
                      title: const Text('History Retention Limit'),
                      subtitle: Text(
                        'Keep last $retention requests (FIFO trimming)',
                      ),
                      trailing: DropdownButton<int>(
                        value: retention,
                        underline: const SizedBox.shrink(),
                        items: const [
                          DropdownMenuItem(value: 25, child: Text('25')),
                          DropdownMenuItem(value: 50, child: Text('50')),
                          DropdownMenuItem(value: 100, child: Text('100')),
                          DropdownMenuItem(value: 200, child: Text('200')),
                          DropdownMenuItem(value: 500, child: Text('500')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            ref
                                    .read(
                                      historyRetentionLimitProvider.notifier,
                                    )
                                    .state =
                                val;
                            ref
                                .read(historyRepositoryProvider)
                                .pruneOldEntries(maxRetention: val);
                          }
                        },
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.file_download_outlined),
                  title: const Text('Import Collection'),
                  subtitle: const Text(
                    'Postman Collection v2.1 or APIForge JSON v1',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showImportCollectionDialog(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('About APIForge', theme),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.bolt, color: Colors.amber, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'APIForge Mobile',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Version 1.0.0+1 • Offline-first REST client for developers, engineers, and students.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  void _showImportCollectionDialog(BuildContext context, WidgetRef ref) {
    final textController = TextEditingController();
    String? errorText;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.file_download_outlined, size: 22),
                SizedBox(width: 8),
                Text('Import Collection'),
              ],
            ),
            content: SizedBox(
              width: 480,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Paste APIForge JSON v1 or Postman Collection v2.1 below:',
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: textController,
                      maxLines: 8,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                      decoration: InputDecoration(
                        hintText: '{\n  "info": { ... },\n  "item": [ ... ]\n}',
                        errorText: errorText,
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      icon: const Icon(Icons.paste_rounded, size: 16),
                      label: const Text('Paste from Clipboard'),
                      onPressed: () async {
                        final data = await Clipboard.getData(
                          Clipboard.kTextPlain,
                        );
                        if (data?.text != null && data!.text!.isNotEmpty) {
                          setState(() {
                            textController.text = data.text!;
                            errorText = null;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  final text = textController.text.trim();
                  if (text.isEmpty) {
                    setState(
                      () => errorText = 'Please paste a JSON collection.',
                    );
                    return;
                  }
                  try {
                    final result = CollectionImportService.parseCollection(
                      text,
                    );
                    final repo = ref.read(collectionsRepositoryProvider);
                    final created =
                        await CollectionImportService.persistImportedCollection(
                          repository: repo,
                          importResult: result,
                        );
                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Imported "${created.name}" with ${result.requests.length} requests.',
                          ),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  } catch (e) {
                    setState(() => errorText = e.toString());
                  }
                },
                child: const Text('Import'),
              ),
            ],
          );
        },
      ),
    );
  }
}
