import 'package:df_theme/df_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A horizontally scrollable row of selectable filter chips/pills.
///
/// Generalised from the app feed filter bar. Renders items as pills, highlighting
/// the currently [selected] item, and invokes [onSelected] when an item is tapped.
class DfFilterChipBar<T> extends StatelessWidget {
  const DfFilterChipBar({
    super.key,
    required this.items,
    this.selected,
    required this.onSelected,
    this.labelBuilder,
    this.trailing,
    this.height = 56.0,
    this.padding,
    this.spacing,
    this.enableHapticFeedback = true,
  });

  /// The list of items to display as filter chips.
  final List<T> items;

  /// The currently selected item, if any.
  final T? selected;

  /// Callback invoked when a chip is tapped.
  final ValueChanged<T> onSelected;

  /// Converts an item [T] into a display string. Defaults to `item.toString()`.
  final String Function(T item)? labelBuilder;

  /// Optional widget displayed at the trailing end (e.g., sort menu or filter action).
  final Widget? trailing;

  /// Height of the filter chip bar container. Defaults to 56.0.
  final double height;

  /// Outer padding around the bar. Defaults to horizontal `df.spacing.md`, vertical `df.spacing.sm`.
  final EdgeInsetsGeometry? padding;

  /// Horizontal spacing between chips. Defaults to `df.spacing.sm`.
  final double? spacing;

  /// Whether tapping a chip triggers haptic feedback. Defaults to true.
  final bool enableHapticFeedback;

  @override
  Widget build(BuildContext context) {
    final df = context.df;
    final effectivePadding = padding ??
        EdgeInsets.symmetric(
          horizontal: df.spacing.md,
          vertical: df.spacing.sm,
        );
    final effectiveSpacing = spacing ?? df.spacing.sm;

    final listView = ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: items.length,
      separatorBuilder: (_, _) => SizedBox(width: effectiveSpacing),
      itemBuilder: (context, index) {
        final item = items[index];
        final label =
            labelBuilder != null ? labelBuilder!(item) : item.toString();
        final isSelected = item == selected;

        return _DfFilterPill(
          label: label,
          selected: isSelected,
          onTap: () {
            if (enableHapticFeedback) {
              HapticFeedback.selectionClick();
            }
            onSelected(item);
          },
        );
      },
    );

    return SizedBox(
      height: height,
      child: Padding(
        padding: effectivePadding,
        child: trailing != null
            ? Row(
                children: [
                  Expanded(child: listView),
                  SizedBox(width: effectiveSpacing),
                  trailing!,
                ],
              )
            : listView,
      ),
    );
  }
}

class _DfFilterPill extends StatelessWidget {
  const _DfFilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final df = context.df;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: reduceMotion ? Duration.zero : df.motion.fast,
          constraints: const BoxConstraints(minHeight: 44),
          padding: EdgeInsets.symmetric(horizontal: df.spacing.md),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? df.colors.brand.base : Colors.transparent,
            borderRadius: df.shape.radiusPill,
            border: Border.all(
              color: selected ? df.colors.brand.base : df.colors.border,
            ),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: selected
                      ? df.colors.textOnBrand
                      : df.colors.textSecondary,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
          ),
        ),
      ),
    );
  }
}
