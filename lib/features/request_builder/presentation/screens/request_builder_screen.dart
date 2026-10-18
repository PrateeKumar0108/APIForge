import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/networking/curl_generator.dart';
import '../../../../core/networking/request_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/key_value_editor.dart';
import '../../../../core/widgets/method_badge.dart';
import '../../domain/request_state.dart';
import '../../../authentication/domain/models/auth_config.dart';
import '../../../collections/domain/models/collection_entity.dart';
import '../../../collections/presentation/providers/collections_provider.dart';
import '../../../environments/presentation/providers/environments_provider.dart';
import '../../../response_inspector/presentation/widgets/response_inspector_widget.dart';
import '../providers/request_builder_provider.dart';

enum MobileWorkspaceView { request, response }

/// Interactive Request Builder screen with URL configuration, method selection,
/// headers, params, body formats, cURL export, and responsive tablet/mobile layout.
class RequestBuilderScreen extends ConsumerStatefulWidget {
  const RequestBuilderScreen({super.key});

  @override
  ConsumerState<RequestBuilderScreen> createState() =>
      _RequestBuilderScreenState();
}

class _RequestBuilderScreenState extends ConsumerState<RequestBuilderScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _requestTabController;
  late final TextEditingController _urlController;
  late final TextEditingController _bodyController;
  MobileWorkspaceView _mobileView = MobileWorkspaceView.request;

  final List<String> _methods = const [
    'GET',
    'POST',
    'PUT',
    'PATCH',
    'DELETE',
    'HEAD',
    'OPTIONS',
  ];

  @override
  void initState() {
    super.initState();
    final initialState = ref.read(requestBuilderProvider);
    _requestTabController = TabController(length: 4, vsync: this);
    _urlController = TextEditingController(text: initialState.url);
    _bodyController = TextEditingController(text: initialState.bodyContent);
  }

  @override
  void dispose() {
    _requestTabController.dispose();
    _urlController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _copyCurl() {
    final state = ref.read(requestBuilderProvider);
    final curl = CurlGenerator.generate(state.toRequestData());
    Clipboard.setData(ClipboardData(text: curl));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('cURL command copied to clipboard.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _onSend() {
    final screenWidth = MediaQuery.sizeOf(context).width;
    if (screenWidth < 900) {
      setState(() => _mobileView = MobileWorkspaceView.response);
    }
    final activeEnv = ref.read(activeEnvironmentProvider);
    ref
        .read(requestBuilderProvider.notifier)
        .sendRequest(environmentVariables: activeEnv?.variableMap ?? const {});
  }

  Future<void> _showSaveRequestDialog(BuildContext context) async {
    final state = ref.read(requestBuilderProvider);
    final repo = ref.read(collectionsRepositoryProvider);
    final collections = await repo.getCollections();

    if (!context.mounted) return;

    if (collections.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please create a collection in the Collections tab first.',
          ),
        ),
      );
      return;
    }

    final nameController = TextEditingController(
      text: state.name != 'Untracked Request' ? state.name : state.url,
    );
    var selectedCollectionId = collections.first.id;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          title: const Text('Save Request'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Request Name',
                  hintText: 'e.g. Get User Profile',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedCollectionId,
                decoration: const InputDecoration(labelText: 'Collection'),
                items: collections.map((c) {
                  return DropdownMenuItem(value: c.id, child: Text(c.name));
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setDialogState(() => selectedCollectionId = val);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final requestData = state.toRequestData();
                final savedEntity = SavedRequestEntity.fromHttpRequestData(
                  request: requestData.copyWith(
                    name: nameController.text.trim(),
                  ),
                  collectionId: selectedCollectionId,
                );
                await repo.saveRequest(savedEntity);
                ref
                    .read(requestBuilderProvider.notifier)
                    .loadRequest(
                      requestData.copyWith(name: nameController.text.trim()),
                    );
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Saved "${savedEntity.name}" to collection.',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(requestBuilderProvider);
    final notifier = ref.read(requestBuilderProvider.notifier);
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isWide = screenWidth >= 900;

    // Sync body controller if changed from provider (e.g. format JSON)
    if (_bodyController.text != state.bodyContent) {
      _bodyController.text = state.bodyContent;
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppColors.primaryBlueLight.withValues(alpha: 0.3),
                ),
              ),
              child: const Text(
                'WORKSPACE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: AppColors.primaryBlueLight,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                state.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final activeEnv = ref.watch(activeEnvironmentProvider);
              final allEnvs =
                  ref.watch(environmentsListProvider).valueOrNull ?? [];
              Color envColor = AppColors.darkTextMuted;
              if (activeEnv != null) {
                try {
                  envColor = Color(int.parse(activeEnv.colorHex));
                } catch (_) {
                  envColor = AppColors.methodGet;
                }
              }

              return PopupMenuButton<String?>(
                tooltip: 'Active Environment',
                initialValue: activeEnv?.id,
                onSelected: (envId) {
                  ref.read(activeEnvironmentIdProvider.notifier).state = envId;
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem<String?>(
                    value: null,
                    child: Text('No Environment'),
                  ),
                  ...allEnvs.map((e) {
                    Color c;
                    try {
                      c = Color(int.parse(e.colorHex));
                    } catch (_) {
                      c = AppColors.methodGet;
                    }
                    return PopupMenuItem<String?>(
                      value: e.id,
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(e.name),
                        ],
                      ),
                    );
                  }),
                ],
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 10,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: envColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: envColor.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: envColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        activeEnv?.name ?? 'No Env',
                        style: TextStyle(
                          color: envColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(Icons.arrow_drop_down, size: 14, color: envColor),
                    ],
                  ),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Copy as cURL',
            icon: const Icon(Icons.terminal, size: 20),
            onPressed: _copyCurl,
          ),
          IconButton(
            tooltip: 'Save Request',
            icon: const Icon(Icons.bookmark_border, size: 20),
            onPressed: () => _showSaveRequestDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // URL Bar & Controls
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Method Selector
                    Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: state.method,
                          icon: const Icon(Icons.arrow_drop_down, size: 18),
                          onChanged: (String? newMethod) {
                            if (newMethod != null) {
                              notifier.setMethod(newMethod);
                            }
                          },
                          items: _methods.map((method) {
                            return DropdownMenuItem<String>(
                              value: method,
                              child: MethodBadge(method: method),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // URL Input Field
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: TextField(
                          controller: _urlController,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13,
                          ),
                          decoration: InputDecoration(
                            hintText: 'https://api.example.com/endpoint',
                            prefixIcon: const Icon(Icons.link, size: 18),
                            errorText: state.urlValidationError,
                          ),
                          onChanged: notifier.setUrl,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Send / Cancel Button
                    SizedBox(
                      height: 48,
                      child: state.isLoading
                          ? ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.methodDelete,
                              ),
                              onPressed: notifier.cancelRequest,
                              icon: const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                              label: const Text('Cancel'),
                            )
                          : ElevatedButton.icon(
                              onPressed: _onSend,
                              icon: const Icon(Icons.send_rounded, size: 16),
                              label: const Text('Send'),
                            ),
                    ),
                  ],
                ),

                // Host target / non-idempotent warning
                if ([
                  'POST',
                  'PUT',
                  'PATCH',
                  'DELETE',
                ].contains(state.method)) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        size: 14,
                        color: AppColors.amberAccent,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Executing ${state.method} will modify remote data on the target server.',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.amberAccent,
                        ),
                      ),
                    ],
                  ),
                ],
                if (state.unresolvedVariables.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.amberAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppColors.amberAccent.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.help_outline,
                          size: 14,
                          color: AppColors.amberAccent,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Unresolved variables: {{${state.unresolvedVariables.join('}}, {{')}}} - verify active environment.',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.amberAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Mobile View Selector (Request vs Response)
          if (!isWide)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: SizedBox(
                width: double.infinity,
                child: SegmentedButton<MobileWorkspaceView>(
                  segments: [
                    ButtonSegment(
                      value: MobileWorkspaceView.request,
                      icon: const Icon(Icons.edit_note, size: 16),
                      label: const Text('Request'),
                    ),
                    ButtonSegment(
                      value: MobileWorkspaceView.response,
                      icon: state.isLoading
                          ? const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.output, size: 16),
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Response'),
                          if (state.response != null) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.forStatusCode(
                                  state.response!.statusCode,
                                ).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${state.response!.statusCode}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.forStatusCode(
                                    state.response!.statusCode,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  selected: {_mobileView},
                  onSelectionChanged: (val) {
                    setState(() => _mobileView = val.first);
                  },
                ),
              ),
            ),

          const Divider(height: 1),

          // Workspace Content (Responsive Split or Mobile Tab)
          Expanded(
            child: isWide
                ? Row(
                    children: [
                      // Left Column: Request Builder Tabs
                      Expanded(
                        flex: 5,
                        child: _buildRequestEditor(state, notifier, theme),
                      ),
                      const VerticalDivider(width: 1, thickness: 1),
                      // Right Column: Response Inspector
                      Expanded(
                        flex: 5,
                        child: ResponseInspectorWidget(
                          response: state.response,
                          failure: state.failure,
                          isLoading: state.isLoading,
                          onRetry: _onSend,
                          onCancel: notifier.cancelRequest,
                        ),
                      ),
                    ],
                  )
                : (_mobileView == MobileWorkspaceView.request
                      ? _buildRequestEditor(state, notifier, theme)
                      : ResponseInspectorWidget(
                          response: state.response,
                          failure: state.failure,
                          isLoading: state.isLoading,
                          onRetry: _onSend,
                          onCancel: notifier.cancelRequest,
                        )),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestEditor(
    RequestState state,
    RequestBuilderNotifier notifier,
    ThemeData theme,
  ) {
    return Column(
      children: [
        TabBar(
          controller: _requestTabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Params'),
                  if (state.queryParams.any((p) => p.isEnabled)) ...[
                    const SizedBox(width: 4),
                    _buildCountBadge(
                      state.queryParams.where((p) => p.isEnabled).length,
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Headers'),
                  if (state.headers.any((h) => h.isEnabled)) ...[
                    const SizedBox(width: 4),
                    _buildCountBadge(
                      state.headers.where((h) => h.isEnabled).length,
                    ),
                  ],
                ],
              ),
            ),
            const Tab(text: 'Auth'),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Body'),
                  if (state.bodyType != BodyType.none) ...[
                    const SizedBox(width: 4),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.cyanAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _requestTabController,
            children: [
              _buildParamsTab(state, notifier),
              _buildHeadersTab(state, notifier),
              _buildAuthTab(state, notifier, theme),
              _buildBodyTab(state, notifier, theme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCountBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: AppColors.primaryBlueLight.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildParamsTab(RequestState state, RequestBuilderNotifier notifier) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: KeyValueEditor(
        items: state.queryParams,
        onChanged: notifier.setQueryParams,
        keyHint: 'Parameter Name',
        valueHint: 'Parameter Value',
        emptyMessage:
            'No query parameters configured.\nClick "Add Parameter" to append query keys and values.',
      ),
    );
  }

  Widget _buildHeadersTab(RequestState state, RequestBuilderNotifier notifier) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: KeyValueEditor(
        items: state.headers,
        onChanged: notifier.setHeaders,
        keyHint: 'Header Name',
        valueHint: 'Header Value',
        allowSecrets: true,
        emptyMessage: 'No headers configured.',
      ),
    );
  }

  Widget _buildAuthTab(
    RequestState state,
    RequestBuilderNotifier notifier,
    ThemeData theme,
  ) {
    final auth = state.authConfig;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Type:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(width: 12),
              Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<AuthType>(
                    value: auth.type,
                    items: AuthType.values.map((t) {
                      return DropdownMenuItem(
                        value: t,
                        child: Text(
                          t.displayName,
                          style: const TextStyle(fontSize: 13),
                        ),
                      );
                    }).toList(),
                    onChanged: (newType) {
                      if (newType != null) {
                        notifier.setAuthConfig(auth.copyWith(type: newType));
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (auth.type == AuthType.none)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(Icons.shield_outlined, color: AppColors.darkTextMuted),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This request does not use any authentication credentials.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (auth.type == AuthType.bearer)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bearer Token',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: TextEditingController(text: auth.token)
                        ..selection = TextSelection.collapsed(
                          offset: (auth.token ?? '').length,
                        ),
                      style: const TextStyle(
                        fontSize: 13,
                        fontFamily: 'monospace',
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Enter Bearer Token or {{token}}',
                        prefixIcon: Icon(Icons.key, size: 18),
                      ),
                      onChanged: (val) {
                        notifier.setAuthConfig(auth.copyWith(token: val));
                      },
                    ),
                    const SizedBox(height: 12),
                    const Row(
                      children: [
                        Icon(Icons.lock, size: 13, color: AppColors.cyanAccent),
                        SizedBox(width: 6),
                        Text(
                          'Will be injected as Authorization: Bearer <token>',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.cyanAccent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          else if (auth.type == AuthType.basic)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Basic Authentication',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: TextEditingController(text: auth.username)
                        ..selection = TextSelection.collapsed(
                          offset: (auth.username ?? '').length,
                        ),
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(Icons.person, size: 18),
                      ),
                      onChanged: (val) =>
                          notifier.setAuthConfig(auth.copyWith(username: val)),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: TextEditingController(text: auth.password)
                        ..selection = TextSelection.collapsed(
                          offset: (auth.password ?? '').length,
                        ),
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock, size: 18),
                      ),
                      onChanged: (val) =>
                          notifier.setAuthConfig(auth.copyWith(password: val)),
                    ),
                    const SizedBox(height: 12),
                    const Row(
                      children: [
                        Icon(Icons.lock, size: 13, color: AppColors.cyanAccent),
                        SizedBox(width: 6),
                        Text(
                          'Will be encoded to Base64 and sent as Authorization: Basic ...',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.cyanAccent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          else if (auth.type == AuthType.apiKey)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'API Key Configuration',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: TextEditingController(text: auth.apiKeyName)
                        ..selection = TextSelection.collapsed(
                          offset: (auth.apiKeyName ?? '').length,
                        ),
                      decoration: const InputDecoration(
                        labelText: 'Key Name (e.g. X-API-Key, api_key)',
                        prefixIcon: Icon(Icons.tag, size: 18),
                      ),
                      onChanged: (val) => notifier.setAuthConfig(
                        auth.copyWith(apiKeyName: val),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: TextEditingController(text: auth.apiKeyValue)
                        ..selection = TextSelection.collapsed(
                          offset: (auth.apiKeyValue ?? '').length,
                        ),
                      decoration: const InputDecoration(
                        labelText: 'Key Value (or {{apiKey}})',
                        prefixIcon: Icon(Icons.vpn_key, size: 18),
                      ),
                      onChanged: (val) => notifier.setAuthConfig(
                        auth.copyWith(apiKeyValue: val),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text(
                          'Add to: ',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('Header'),
                          selected:
                              auth.apiKeyLocation == ApiKeyLocation.header,
                          onSelected: (selected) {
                            if (selected) {
                              notifier.setAuthConfig(
                                auth.copyWith(
                                  apiKeyLocation: ApiKeyLocation.header,
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('Query Parameter'),
                          selected: auth.apiKeyLocation == ApiKeyLocation.query,
                          onSelected: (selected) {
                            if (selected) {
                              notifier.setAuthConfig(
                                auth.copyWith(
                                  apiKeyLocation: ApiKeyLocation.query,
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBodyTab(
    RequestState state,
    RequestBuilderNotifier notifier,
    ThemeData theme,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            children: BodyType.values.map((type) {
              final isSelected = state.bodyType == type;
              return ChoiceChip(
                label: Text(type.displayName),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) notifier.setBodyType(type);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          if (state.bodyType == BodyType.none)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'This request does not include a payload body.',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            )
          else if (state.bodyType == BodyType.json ||
              state.bodyType == BodyType.text) ...[
            if (state.bodyType == BodyType.json)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      final success = notifier.formatJsonBody();
                      if (!success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Invalid JSON: Unable to format payload.',
                            ),
                            backgroundColor: AppColors.methodDelete,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.auto_fix_high, size: 16),
                    label: const Text('Prettify JSON'),
                  ),
                ],
              ),
            TextField(
              controller: _bodyController,
              maxLines: 12,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
              decoration: InputDecoration(
                hintText: state.bodyType == BodyType.json
                    ? '{\n  "key": "value"\n}'
                    : 'Enter raw text payload...',
                alignLabelWithHint: true,
              ),
              onChanged: notifier.setBodyContent,
            ),
          ] else if (state.bodyType == BodyType.formUrlEncoded) ...[
            KeyValueEditor(
              items: state.formData,
              onChanged: notifier.setFormData,
              keyHint: 'Field Name',
              valueHint: 'Field Value',
              emptyMessage: 'No form-encoded fields added.',
            ),
          ],
        ],
      ),
    );
  }
}
