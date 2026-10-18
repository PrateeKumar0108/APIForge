import 'package:flutter/material.dart';
import '../networking/request_models.dart';
import '../theme/app_colors.dart';

/// Reusable table/list editor for query parameters, headers, and form-urlencoded fields.
class KeyValueEditor extends StatelessWidget {
  final List<KeyValuePair> items;
  final ValueChanged<List<KeyValuePair>> onChanged;
  final String keyHint;
  final String valueHint;
  final String emptyMessage;
  final bool allowSecrets;

  const KeyValueEditor({
    super.key,
    required this.items,
    required this.onChanged,
    this.keyHint = 'Key',
    this.valueHint = 'Value',
    this.emptyMessage = 'No items configured. Click below to add one.',
    this.allowSecrets = false,
  });

  void _addItem() {
    final updated = List<KeyValuePair>.from(items)
      ..add(KeyValuePair(key: '', value: ''));
    onChanged(updated);
  }

  void _updateItem(int index, KeyValuePair newItem) {
    final updated = List<KeyValuePair>.from(items);
    updated[index] = newItem;
    onChanged(updated);
  }

  void _removeItem(int index) {
    final updated = List<KeyValuePair>.from(items)..removeAt(index);
    onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              emptyMessage,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = items[index];
              return _KeyValueRow(
                key: ValueKey(item.id),
                item: item,
                keyHint: keyHint,
                valueHint: valueHint,
                allowSecrets: allowSecrets,
                onChanged: (updated) => _updateItem(index, updated),
                onDelete: () => _removeItem(index),
              );
            },
          ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _addItem,
            icon: const Icon(Icons.add, size: 16),
            label: Text('Add $keyHint'),
          ),
        ),
      ],
    );
  }
}

class _KeyValueRow extends StatefulWidget {
  final KeyValuePair item;
  final String keyHint;
  final String valueHint;
  final bool allowSecrets;
  final ValueChanged<KeyValuePair> onChanged;
  final VoidCallback onDelete;

  const _KeyValueRow({
    super.key,
    required this.item,
    required this.keyHint,
    required this.valueHint,
    required this.allowSecrets,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  State<_KeyValueRow> createState() => _KeyValueRowState();
}

class _KeyValueRowState extends State<_KeyValueRow> {
  late final TextEditingController _keyController;
  late final TextEditingController _valueController;

  @override
  void initState() {
    super.initState();
    _keyController = TextEditingController(text: widget.item.key);
    _valueController = TextEditingController(text: widget.item.value);
  }

  @override
  void didUpdateWidget(covariant _KeyValueRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.key != widget.item.key &&
        _keyController.text != widget.item.key) {
      _keyController.text = widget.item.key;
    }
    if (oldWidget.item.value != widget.item.value &&
        _valueController.text != widget.item.value) {
      _valueController.text = widget.item.value;
    }
  }

  @override
  void dispose() {
    _keyController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: widget.item.isEnabled,
          onChanged: (val) {
            widget.onChanged(widget.item.copyWith(isEnabled: val ?? true));
          },
        ),
        Expanded(
          flex: 4,
          child: SizedBox(
            height: 40,
            child: TextField(
              controller: _keyController,
              style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
              decoration: InputDecoration(
                hintText: widget.keyHint,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
              ),
              onChanged: (val) {
                widget.onChanged(widget.item.copyWith(key: val));
              },
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 5,
          child: SizedBox(
            height: 40,
            child: TextField(
              controller: _valueController,
              obscureText: widget.item.isSecret,
              style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
              decoration: InputDecoration(
                hintText: widget.valueHint,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
              ),
              onChanged: (val) {
                widget.onChanged(widget.item.copyWith(value: val));
              },
            ),
          ),
        ),
        if (widget.allowSecrets)
          IconButton(
            tooltip: widget.item.isSecret ? 'Unmask secret' : 'Mask as secret',
            icon: Icon(
              widget.item.isSecret ? Icons.visibility_off : Icons.visibility,
              size: 18,
              color: widget.item.isSecret ? AppColors.amberAccent : null,
            ),
            onPressed: () {
              widget.onChanged(
                widget.item.copyWith(isSecret: !widget.item.isSecret),
              );
            },
          ),
        IconButton(
          tooltip: 'Delete item',
          icon: const Icon(Icons.close, size: 18),
          onPressed: widget.onDelete,
        ),
      ],
    );
  }
}
