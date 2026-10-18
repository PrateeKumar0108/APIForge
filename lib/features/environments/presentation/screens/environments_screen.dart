import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/environment_entity.dart';
import '../providers/environments_provider.dart';

/// EnvironmentsScreen provides full CRUD for environments, active environment selection,
/// variable management, and secure secret storage.
class EnvironmentsScreen extends ConsumerStatefulWidget {
  const EnvironmentsScreen({super.key});

  @override
  ConsumerState<EnvironmentsScreen> createState() => _EnvironmentsScreenState();
}

class _EnvironmentsScreenState extends ConsumerState<EnvironmentsScreen> {
  void _showCreateEnvironmentDialog(BuildContext context) {
    final nameController = TextEditingController();
    var selectedColor = '0xFF10B981'; // Emerald default

    final colorOptions = [
      {
        'label': 'Emerald',
        'hex': '0xFF10B981',
        'color': const Color(0xFF10B981),
      },
      {'label': 'Blue', 'hex': '0xFF3B82F6', 'color': const Color(0xFF3B82F6)},
      {'label': 'Amber', 'hex': '0xFFF59E0B', 'color': const Color(0xFFF59E0B)},
      {'label': 'Red', 'hex': '0xFFEF4444', 'color': const Color(0xFFEF4444)},
      {
        'label': 'Purple',
        'hex': '0xFF8B5CF6',
        'color': const Color(0xFF8B5CF6),
      },
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          title: const Text('New Environment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Environment Name',
                  hintText: 'e.g. Staging 2, QA, Mock Server',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Accent Color:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: colorOptions.map((opt) {
                  final hex = opt['hex'] as String;
                  final color = opt['color'] as Color;
                  final isSelected = selectedColor == hex;

                  return GestureDetector(
                    onTap: () => setDialogState(() => selectedColor = hex),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 2.5)
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  );
                }).toList(),
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
                if (nameController.text.trim().isNotEmpty) {
                  final repo = ref.read(environmentsRepositoryProvider);
                  await repo.createEnvironment(
                    name: nameController.text.trim(),
                    colorHex: selectedColor,
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showVariablesSheet(BuildContext context, EnvironmentEntity env) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => _EnvironmentVariablesSheet(environment: env),
    );
  }

  void _showDeleteConfirmation(BuildContext context, EnvironmentEntity env) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.methodDelete),
            SizedBox(width: 8),
            Text('Delete Environment?'),
          ],
        ),
        content: Text(
          'Permanently delete "${env.name}" and all associated variables and secure secrets?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.methodDelete,
            ),
            onPressed: () async {
              final repo = ref.read(environmentsRepositoryProvider);
              await repo.deleteEnvironment(env.id);
              if (ref.read(activeEnvironmentIdProvider) == env.id) {
                ref.read(activeEnvironmentIdProvider.notifier).state = null;
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final environmentsAsync = ref.watch(environmentsListProvider);
    final activeId = ref.watch(activeEnvironmentIdProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Environments',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Add Environment',
            icon: const Icon(Icons.add_circle_outline, size: 22),
            onPressed: () => _showCreateEnvironmentDialog(context),
          ),
        ],
      ),
      body: environmentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) =>
            Center(child: Text('Error loading environments: $err')),
        data: (environments) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // No Environment Option
              Card(
                child: ListTile(
                  leading: Icon(
                    activeId == null
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: activeId == null ? theme.colorScheme.primary : null,
                  ),
                  title: const Text(
                    'No Environment',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  subtitle: const Text(
                    'Only request-local variables will be evaluated',
                  ),
                  onTap: () {
                    ref.read(activeEnvironmentIdProvider.notifier).state = null;
                  },
                ),
              ),
              const SizedBox(height: 12),

              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'CONFIGURED ENVIRONMENTS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    color: AppColors.darkTextMuted,
                  ),
                ),
              ),

              ...environments.map((env) {
                final isActive = env.id == activeId;
                Color envColor;
                try {
                  envColor = Color(int.parse(env.colorHex));
                } catch (_) {
                  envColor = AppColors.methodGet;
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      radius: 18,
                      backgroundColor: envColor.withValues(alpha: 0.15),
                      child: Icon(
                        Icons.layers_rounded,
                        color: envColor,
                        size: 18,
                      ),
                    ),
                    title: Row(
                      children: [
                        Text(
                          env.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        if (isActive) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: envColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'ACTIVE',
                              style: TextStyle(
                                color: envColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${env.variables.length} variables configured • Tap to view/edit',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: isActive
                              ? 'Active environment'
                              : 'Set as active',
                          icon: Icon(
                            isActive
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: isActive ? envColor : null,
                            size: 20,
                          ),
                          onPressed: () {
                            ref
                                .read(activeEnvironmentIdProvider.notifier)
                                .state = isActive
                                ? null
                                : env.id;
                          },
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, size: 18),
                          onSelected: (action) {
                            if (action == 'delete') {
                              _showDeleteConfirmation(context, env);
                            }
                          },
                          itemBuilder: (ctx) => [
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
                                    'Delete Environment',
                                    style: TextStyle(
                                      color: AppColors.methodDelete,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    onTap: () => _showVariablesSheet(context, env),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

class _EnvironmentVariablesSheet extends ConsumerStatefulWidget {
  final EnvironmentEntity environment;

  const _EnvironmentVariablesSheet({required this.environment});

  @override
  ConsumerState<_EnvironmentVariablesSheet> createState() =>
      _EnvironmentVariablesSheetState();
}

class _EnvironmentVariablesSheetState
    extends ConsumerState<_EnvironmentVariablesSheet> {
  late List<EnvironmentVariableEntity> _variables;

  @override
  void initState() {
    super.initState();
    _variables = List.from(widget.environment.variables);
  }

  void _addVariable() {
    setState(() {
      _variables.add(EnvironmentVariableEntity(key: '', value: ''));
    });
  }

  void _updateVariable(int index, EnvironmentVariableEntity updated) {
    setState(() {
      _variables[index] = updated;
    });
  }

  void _deleteVariable(int index) {
    setState(() {
      _variables.removeAt(index);
    });
  }

  Future<void> _saveAll() async {
    final repo = ref.read(environmentsRepositoryProvider);
    for (final v in _variables) {
      if (v.key.trim().isNotEmpty) {
        await repo.saveVariable(widget.environment.id, v);
      }
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.environment.name} Variables'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _saveAll,
            child: const Text(
              'Save',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cyanAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.cyanAccent.withValues(alpha: 0.3),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.cyanAccent, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Use {{variableName}} in your URLs, headers, and request bodies. '
                    'Variables marked as secret are stored in hardware-encrypted storage.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_variables.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'No variables configured yet. Click below to add one.',
                ),
              ),
            )
          else
            ...List.generate(_variables.length, (index) {
              final item = _variables[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: item.isEnabled,
                            onChanged: (val) => _updateVariable(
                              index,
                              item.copyWith(isEnabled: val ?? true),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: SizedBox(
                              height: 40,
                              child: TextField(
                                controller:
                                    TextEditingController(text: item.key)
                                      ..selection = TextSelection.collapsed(
                                        offset: item.key.length,
                                      ),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'monospace',
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'Variable Name (e.g. baseUrl)',
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                ),
                                onChanged: (val) => _updateVariable(
                                  index,
                                  item.copyWith(key: val),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 5,
                            child: SizedBox(
                              height: 40,
                              child: TextField(
                                controller:
                                    TextEditingController(text: item.value)
                                      ..selection = TextSelection.collapsed(
                                        offset: item.value.length,
                                      ),
                                obscureText: item.isSecret,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'monospace',
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'Value',
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                ),
                                onChanged: (val) => _updateVariable(
                                  index,
                                  item.copyWith(value: val),
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: item.isSecret
                                ? 'Unmark secret'
                                : 'Mark as secret',
                            icon: Icon(
                              item.isSecret ? Icons.lock : Icons.lock_open,
                              size: 18,
                              color: item.isSecret
                                  ? AppColors.amberAccent
                                  : null,
                            ),
                            onPressed: () => _updateVariable(
                              index,
                              item.copyWith(isSecret: !item.isSecret),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Delete variable',
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () => _deleteVariable(index),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _addVariable,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Variable'),
            ),
          ),
        ],
      ),
    );
  }
}
