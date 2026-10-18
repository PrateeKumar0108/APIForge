import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/method_badge.dart';
import '../../../import_export/domain/services/collection_export_service.dart';
import '../../../import_export/domain/services/collection_import_service.dart';
import '../../../request_builder/presentation/providers/request_builder_provider.dart';
import '../../domain/models/collection_entity.dart';
import '../providers/collections_provider.dart';

/// CollectionsScreen provides full management of request collections,
/// folders, saved endpoints, search, and deletion confirmation dialogs.
class CollectionsScreen extends ConsumerStatefulWidget {
  const CollectionsScreen({super.key});

  @override
  ConsumerState<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends ConsumerState<CollectionsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showImportCollectionDialog(BuildContext context) {
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

  Future<void> _exportCollection(
    BuildContext context,
    CollectionEntity collection,
  ) async {
    final repo = ref.read(collectionsRepositoryProvider);
    final requests = await repo.getRequests(collection.id);
    final jsonString = CollectionExportService.exportCollection(
      collection: collection,
      requests: requests,
    );

    await Clipboard.setData(ClipboardData(text: jsonString));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Exported "${collection.name}" (${requests.length} requests) to clipboard (secrets sanitized).',
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showCreateCollectionDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Collection'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Collection Name',
                  hintText: 'e.g. Stripe API, User Service',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Collection name is required.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'Brief summary of endpoints in this collection',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final repo = ref.read(collectionsRepositoryProvider);
                await repo.createCollection(
                  name: nameController.text.trim(),
                  description: descController.text.trim().isNotEmpty
                      ? descController.text.trim()
                      : null,
                );
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.methodDelete,
            ),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.methodDelete,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final collectionsAsync = ref.watch(collectionsListProvider);
    final repo = ref.read(collectionsRepositoryProvider);
    final searchQuery = ref.watch(collectionSearchQueryProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Collections',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Import Collection',
            icon: const Icon(Icons.file_download_outlined, size: 22),
            onPressed: () => _showImportCollectionDialog(context),
          ),
          IconButton(
            tooltip: 'New Collection',
            icon: const Icon(Icons.create_new_folder_outlined, size: 22),
            onPressed: () => _showCreateCollectionDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search input bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SizedBox(
              height: 42,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search collections & requests...',
                  prefixIcon: const Icon(Icons.search, size: 18),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 16),
                          onPressed: () {
                            _searchController.clear();
                            ref
                                    .read(
                                      collectionSearchQueryProvider.notifier,
                                    )
                                    .state =
                                '';
                          },
                        )
                      : null,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (val) {
                  ref.read(collectionSearchQueryProvider.notifier).state = val;
                },
              ),
            ),
          ),

          // Collections List
          Expanded(
            child: collectionsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) =>
                  Center(child: Text('Failed to load collections: $err')),
              data: (collections) {
                final filtered = collections.where((c) {
                  if (searchQuery.trim().isEmpty) return true;
                  return c.name.toLowerCase().contains(
                        searchQuery.toLowerCase(),
                      ) ||
                      (c.description ?? '').toLowerCase().contains(
                        searchQuery.toLowerCase(),
                      );
                }).toList();

                if (filtered.isEmpty) {
                  if (searchQuery.isNotEmpty) {
                    return Center(
                      child: Text(
                        'No collections match "$searchQuery"',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    );
                  }

                  return EmptyState(
                    icon: Icons.folder_open_rounded,
                    title: 'No Collections Yet',
                    description:
                        'Create collections to organize API endpoints by feature, service, or workflow.',
                    actionLabel: 'Create Collection',
                    onAction: () => _showCreateCollectionDialog(context),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final collection = filtered[index];
                    return _CollectionCard(
                      collection: collection,
                      onExport: () => _exportCollection(context, collection),
                      onDelete: () {
                        _showDeleteConfirmation(
                          context: context,
                          title: 'Delete Collection?',
                          message:
                              'This will permanently delete "${collection.name}" and all saved requests within it.',
                          onConfirm: () => repo.deleteCollection(collection.id),
                        );
                      },
                      onDuplicateRequest: (requestId) async {
                        await repo.duplicateRequest(requestId);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Request duplicated.'),
                            ),
                          );
                        }
                      },
                      onDeleteRequest: (request) {
                        _showDeleteConfirmation(
                          context: context,
                          title: 'Delete Request?',
                          message:
                              'Permanently remove "${request.name}" from this collection?',
                          onConfirm: () => repo.deleteRequest(request.id),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CollectionCard extends ConsumerWidget {
  final CollectionEntity collection;
  final VoidCallback onExport;
  final VoidCallback onDelete;
  final ValueChanged<String> onDuplicateRequest;
  final ValueChanged<SavedRequestEntity> onDeleteRequest;

  const _CollectionCard({
    required this.collection,
    required this.onExport,
    required this.onDelete,
    required this.onDuplicateRequest,
    required this.onDeleteRequest,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final requestsAsync = ref.watch(collectionRequestsProvider(collection.id));

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: true,
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.primaryBlueLight.withValues(alpha: 0.15),
          child: const Icon(
            Icons.folder,
            color: AppColors.primaryBlueLight,
            size: 18,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                collection.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${collection.requestCount}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle:
            collection.description != null && collection.description!.isNotEmpty
            ? Text(
                collection.description!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, size: 18),
          onSelected: (val) {
            if (val == 'export') onExport();
            if (val == 'delete') onDelete();
          },
          itemBuilder: (ctx) => [
            const PopupMenuItem(
              value: 'export',
              child: Row(
                children: [
                  Icon(Icons.file_upload_outlined, size: 18),
                  SizedBox(width: 8),
                  Text('Export (APIForge v1)'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: AppColors.methodDelete,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Delete Collection',
                    style: TextStyle(color: AppColors.methodDelete),
                  ),
                ],
              ),
            ),
          ],
        ),
        children: [
          requestsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (err, _) => Padding(
              padding: const EdgeInsets.all(8),
              child: Text('Error loading requests: $err'),
            ),
            data: (requests) {
              if (requests.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No requests saved in this collection yet.\nUse "Save Request" in the Builder to add one.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: requests.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (ctx, idx) {
                  final req = requests[idx];
                  return ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 2,
                    ),
                    leading: MethodBadge(method: req.method, fontSize: 10),
                    title: Text(
                      req.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    subtitle: Text(
                      req.url,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                      ),
                    ),
                    trailing: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, size: 16),
                      onSelected: (action) {
                        if (action == 'duplicate') {
                          onDuplicateRequest(req.id);
                        } else if (action == 'delete') {
                          onDeleteRequest(req);
                        }
                      },
                      itemBuilder: (popupCtx) => [
                        const PopupMenuItem(
                          value: 'duplicate',
                          child: Row(
                            children: [
                              Icon(Icons.copy_rounded, size: 16),
                              SizedBox(width: 8),
                              Text('Duplicate'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                size: 16,
                                color: AppColors.methodDelete,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Delete',
                                style: TextStyle(color: AppColors.methodDelete),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      // Load request into builder and navigate there
                      ref
                          .read(requestBuilderProvider.notifier)
                          .loadRequest(req.toHttpRequestData());
                      context.go('/builder');
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
