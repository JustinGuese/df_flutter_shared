import 'package:flutter/material.dart';

/// A widget that displays character count for a TextEditingController
/// Updates automatically using ValueListenableBuilder for better performance
class CharacterCounter extends StatelessWidget {
  final TextEditingController controller;
  final int maxLength;
  final TextStyle? style;

  const CharacterCounter({
    super.key,
    required this.controller,
    required this.maxLength,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        final currentLength = value.text.length;
        final isOverLimit = currentLength > maxLength;
        final theme = Theme.of(context);
        
        return Text(
          '$currentLength/$maxLength',
          style: style ??
              theme.textTheme.bodySmall?.copyWith(
                color: isOverLimit
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
        );
      },
    );
  }
}

/// Extension to easily get character count string from TextEditingController
extension TextEditingControllerExtension on TextEditingController {
  String characterCount(int maxLength) {
    return '${text.length}/$maxLength';
  }
}
