import 'package:flutter/material.dart';

import '../../constants/app_sizes.dart';

/// A dropdown field styled to match [AppTextField].
class AppDropdown<T> extends StatelessWidget {
  const AppDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.label,
    this.hint,
    this.itemLabel,
    this.enabled = true,
  });

  final T value;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final String? label;
  final String? hint;
  final String Function(T)? itemLabel;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<T>(
              value: item,
              child: Text(
                itemLabel != null ? itemLabel!(item) : item.toString(),
                style: theme.textTheme.bodyMedium,
              ),
            ),
          )
          .toList(),
      onChanged: enabled ? onChanged : null,
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
      isExpanded: true,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
    );
  }
}
