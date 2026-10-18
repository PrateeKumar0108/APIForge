import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/networking/request_models.dart';
import '../../../../core/networking/secret_redactor.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/status_code_badge.dart';
import 'json_syntax_highlighter.dart';

/// Full-featured Response Inspector providing status codes, latency,
/// headers inspection, formatted JSON syntax highlighting, and error diagnostics.
class ResponseInspectorWidget extends StatefulWidget {
  final HttpResponseData? response;
  final AppFailure? failure;
  final bool isLoading;
  final VoidCallback? onRetry;
  final VoidCallback? onCancel;

  const ResponseInspectorWidget({
    super.key,
    this.response,
    this.failure,
    this.isLoading = false,
    this.onRetry,
    this.onCancel,
  });

  @override
  State<ResponseInspectorWidget> createState() =>
      _ResponseInspectorWidgetState();
}

class _ResponseInspectorWidgetState extends State<ResponseInspectorWidget>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _headersSearchController =
      TextEditingController();
  bool _revealRedactedHeaders = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _headersSearchController.dispose();
    super.dispose();
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 1. In-flight Loading State
    if (widget.isLoading) {
      return _buildLoadingState(theme);
    }

    // 2. Fatal Network/Protocol Failure State
    if (widget.failure != null) {
      return _buildFailureState(widget.failure!, theme);
    }

    // 3. Empty State (No request dispatched yet)
    if (widget.response == null) {
      return _buildEmptyState(theme);
    }

    // 4. Response Received State
    final response = widget.response!;
    return Column(
      children: [
        // Summary Bar (Status, Duration, Size, Actions)
        _buildSummaryHeader(response, theme),

        // Inspector Tabs (Pretty, Raw, Headers, Timings)
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Pretty'),
                  if (response.isJson) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.cyanAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'JSON',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppColors.cyanAccent,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Tab(text: 'Raw'),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Headers'),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlueLight.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${response.headers.length}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Tab(text: 'Overview'),
          ],
        ),

        // Inspector Tab Views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildPrettyView(response, theme),
              _buildRawView(response, theme),
              _buildHeadersView(response, theme),
              _buildOverviewView(response, theme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryHeader(HttpResponseData response, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          StatusCodeBadge(
            statusCode: response.statusCode,
            statusMessage: response.statusMessage,
          ),
          const SizedBox(width: 12),
          // Latency Chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.3,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.timer_outlined,
                  size: 13,
                  color: AppColors.darkTextMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  response.formattedDuration,
                  style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Size Chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.3,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.data_usage_rounded,
                  size: 13,
                  color: AppColors.darkTextMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  response.formattedSize,
                  style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Copy Response Body Action
          IconButton(
            tooltip: 'Copy Response Body',
            icon: const Icon(Icons.copy_rounded, size: 18),
            onPressed: () => _copyToClipboard(
              response.isJson ? response.formattedBody : response.body,
              'Response body',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrettyView(HttpResponseData response, ThemeData theme) {
    if (response.body.trim().isEmpty) {
      return Center(
        child: Text(
          'Empty response body (0 bytes received).',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      );
    }

    final isDark = theme.brightness == Brightness.dark;
    final highlighter = JsonSyntaxHighlighter(isDark: isDark);

    if (response.isJson) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SelectableText.rich(
          highlighter.highlight(response.body),
          style: const TextStyle(
            fontSize: 12.5,
            height: 1.45,
            fontFamily: 'monospace',
          ),
        ),
      );
    }

    // Fallback when response is HTML, XML, or plain text
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.amberAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: AppColors.amberAccent.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 14,
                  color: AppColors.amberAccent,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Content is not valid JSON (${response.contentType ?? "unknown type"}). Displaying raw formatted text.',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.amberAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SelectableText(
            response.body,
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.45,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRawView(HttpResponseData response, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: SelectableText(
        response.body,
        style: const TextStyle(
          fontSize: 12.5,
          height: 1.45,
          fontFamily: 'monospace',
        ),
      ),
    );
  }

  Widget _buildHeadersView(HttpResponseData response, ThemeData theme) {
    final query = _headersSearchController.text.trim().toLowerCase();
    final entries = response.headers.entries.where((entry) {
      if (query.isEmpty) return true;
      return entry.key.toLowerCase().contains(query) ||
          entry.value.any((v) => v.toLowerCase().contains(query));
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: TextField(
                    controller: _headersSearchController,
                    decoration: const InputDecoration(
                      hintText: 'Filter headers...',
                      prefixIcon: Icon(Icons.search, size: 16),
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () {
                  setState(
                    () => _revealRedactedHeaders = !_revealRedactedHeaders,
                  );
                },
                icon: Icon(
                  _revealRedactedHeaders
                      ? Icons.visibility_off
                      : Icons.visibility,
                  size: 16,
                ),
                label: Text(
                  _revealRedactedHeaders ? 'Mask Secrets' : 'Reveal Secrets',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: entries.isEmpty
              ? Center(
                  child: Text(
                    'No headers match "$query"',
                    style: theme.textTheme.bodySmall,
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: entries.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    final isSensitive = SecretRedactor.isSensitiveKey(
                      entry.key,
                    );
                    final valueString = entry.value.join(', ');
                    final displayValue = isSensitive && !_revealRedactedHeaders
                        ? '[REDACTED]'
                        : valueString;

                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        entry.key,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          fontFamily: 'monospace',
                        ),
                      ),
                      subtitle: Text(
                        displayValue,
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          color: isSensitive && !_revealRedactedHeaders
                              ? AppColors.amberAccent
                              : null,
                        ),
                      ),
                      trailing: IconButton(
                        tooltip: 'Copy value',
                        icon: const Icon(Icons.copy, size: 14),
                        onPressed: () => _copyToClipboard(
                          valueString,
                          'Header ${entry.key}',
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildOverviewView(HttpResponseData response, ThemeData theme) {
    final rows = [
      {
        'label': 'Status Code',
        'value': '${response.statusCode} ${response.statusMessage}',
      },
      {'label': 'Round-trip Latency', 'value': response.formattedDuration},
      {
        'label': 'Content Length',
        'value':
            '${response.contentLengthBytes} bytes (${response.formattedSize})',
      },
      {
        'label': 'Content-Type',
        'value': response.contentType ?? 'None specified',
      },
      {'label': 'Timestamp', 'value': response.timestamp.toIso8601String()},
      {
        'label': 'Payload Format',
        'value': response.isJson
            ? 'JSON (Parsed successfully)'
            : 'Text / Non-JSON',
      },
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: rows.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final row = rows[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 140,
                  child: Text(
                    row['label']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: AppColors.darkTextMuted,
                    ),
                  ),
                ),
                Expanded(
                  child: SelectableText(
                    row['value']!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              'Sending Request...',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Waiting for remote server response and headers.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
            if (widget.onCancel != null) ...[
              const SizedBox(height: 20),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.methodDelete,
                ),
                onPressed: widget.onCancel,
                icon: const Icon(Icons.cancel, size: 16),
                label: const Text('Cancel Request'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFailureState(AppFailure failure, ThemeData theme) {
    IconData icon;
    String advice;

    switch (failure) {
      case NetworkFailure():
        icon = Icons.wifi_off_rounded;
        advice =
            'Check your Wi-Fi/cellular connection, DNS configuration, and destination server host address.';
      case TimeoutFailure():
        icon = Icons.timer_off_outlined;
        advice =
            'The destination host did not respond before timeout. Check server load, reverse proxy, or firewall.';
      case TlsFailure():
        icon = Icons.gpp_bad_outlined;
        advice =
            'TLS certificate verification failed. The remote server may use an untrusted or expired certificate.';
      case CancelledFailure():
        icon = Icons.cancel_outlined;
        advice =
            'The request was aborted by the user before network completion.';
      case ValidationFailure():
        icon = Icons.rule_folder_outlined;
        advice = 'Verify the URL format and required scheme before executing.';
      default:
        icon = Icons.error_outline_rounded;
        advice =
            'An unexpected failure occurred while processing the network call.';
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Card(
          color: AppColors.methodDelete.withValues(alpha: 0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: AppColors.methodDelete.withValues(alpha: 0.3),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 40, color: AppColors.methodDelete),
                const SizedBox(height: 12),
                Text(
                  failure.message,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.methodDelete,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (failure.technicalDetails != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    failure.technicalDetails!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 16),
                Text(
                  advice,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                if (widget.onRetry != null && failure is! CancelledFailure) ...[
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: widget.onRetry,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Retry Request'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.alt_route_rounded,
                size: 36,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Response Yet',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter a target URL above and tap "Send" to inspect HTTP status codes, latency, headers, and formatted JSON.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
