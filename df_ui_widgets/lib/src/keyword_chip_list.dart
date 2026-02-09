import 'package:flutter/material.dart';

class KeywordChipList extends StatelessWidget {
  const KeywordChipList({
    super.key,
    required this.title,
    required this.keywords,
    this.icon,
    this.chipColor,
    this.chipTextColor,
    this.emptyStateText =
        'No keywords yet. Leave blank to let AI fill this for you.',
    this.isLoading = false,
    this.titleColor,
    this.iconColor,
    this.emptyTextColor,
  });

  final String title;
  final List<String> keywords;
  final IconData? icon;
  final Color? chipColor;
  final Color? chipTextColor;
  final String emptyStateText;
  final bool isLoading;
  final Color? titleColor;
  final Color? iconColor;
  final Color? emptyTextColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveChipColor = chipColor ?? theme.colorScheme.primaryContainer;
    final effectiveChipTextColor =
        chipTextColor ?? theme.colorScheme.onPrimaryContainer;
    final showEmptyState = keywords.isEmpty && !isLoading;

    Widget body;
    if (isLoading) {
      body = const _AiPulseIndicator();
    } else if (showEmptyState) {
      body = Text(
        emptyStateText,
        style: theme.textTheme.bodySmall?.copyWith(
          color: emptyTextColor ?? theme.colorScheme.outline,
        ),
      );
    } else {
      body = Wrap(
        spacing: 8,
        runSpacing: 8,
        children: keywords
            .map(
              (keyword) => Chip(
                backgroundColor: effectiveChipColor,
                label: Text(
                  keyword,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: effectiveChipTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
            .toList(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null)
              Icon(
                icon,
                color: iconColor ?? theme.colorScheme.primary,
              ),
            if (icon != null) const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: titleColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: body,
        ),
      ],
    );
  }
}

class _AiPulseIndicator extends StatefulWidget {
  const _AiPulseIndicator();

  @override
  State<_AiPulseIndicator> createState() => _AiPulseIndicatorState();
}

class _AiPulseIndicatorState extends State<_AiPulseIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
      lowerBound: 0.2,
      upperBound: 1,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FadeTransition(
      opacity: _controller,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Icon(
              Icons.auto_awesome,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Analyzing with AI…',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
