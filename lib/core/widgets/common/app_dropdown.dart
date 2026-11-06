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

  /// Currently selected item; null = "not chosen yet" (shows [hint]).
  final T? value;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final String? label;
  final String? hint;
  final String Function(T)? itemLabel;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // An empty catalog (or a stale selection missing from a changed catalog)
    // would otherwise throw "There should be exactly one item with [value]".
    if (items.isEmpty) {
      return DropdownButtonFormField<T>(
        items: const [],
        onChanged: null,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint ?? 'No options available',
        ),
        icon: const Icon(Icons.keyboard_arrow_down_rounded),
        isExpanded: true,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      );
    }

    // A null [value] is a valid "not chosen yet" state — show the hint
    // instead of silently selecting the first item. Non-null values that
    // are missing from the catalog still fall back to the first item.
    final safeValue =
        value == null ? null : (items.contains(value) ? value : items.first);

    // `value` remains the controlled-selection API; `initialValue` is for
    // one-shot form defaults and would break parent-driven dropdowns.
    return DropdownButtonFormField<T>(
      // ignore: deprecated_member_use
      value: safeValue,
      hint: safeValue == null
          ? Text(hint ?? 'Select an option')
          : null,
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
