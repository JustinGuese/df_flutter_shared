import 'package:df_theme/df_theme.dart';
import 'package:flutter/material.dart';

import '../course_models.dart';

class ChecklistChapterView extends StatelessWidget {
  const ChecklistChapterView({
    super.key,
    required this.chapter,
    required this.isChecked,
    required this.onToggle,
  });

  final ChecklistChapter chapter;
  final bool Function(ChecklistItem item) isChecked;
  final void Function(ChecklistItem item, bool checked) onToggle;

  @override
  Widget build(BuildContext context) {
    final df = context.df;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(chapter.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                chapter.title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: df.colors.brand.deep,
                ),
              ),
            ),
          ],
        ),
        if (chapter.intro != null) ...[
          const SizedBox(height: 6),
          Text(
            chapter.intro!,
            style: TextStyle(
              fontSize: 13,
              color: df.colors.textSecondary,
              height: 1.45,
            ),
          ),
        ],
        const SizedBox(height: 12),
        ...chapter.items.map(
          (item) => _ChecklistTile(
            item: item,
            checked: isChecked(item),
            onChanged: (v) => onToggle(item, v),
          ),
        ),
      ],
    );
  }
}

class _ChecklistTile extends StatelessWidget {
  const _ChecklistTile({
    required this.item,
    required this.checked,
    required this.onChanged,
  });

  final ChecklistItem item;
  final bool checked;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final df = context.df;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: df.colors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: df.cardShadow,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onChanged(!checked),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: Checkbox(
                  value: checked,
                  onChanged: (v) => onChanged(v ?? false),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: df.colors.textPrimary,
                        fontWeight: FontWeight.w600,
                        decoration: checked ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (item.why != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.why!,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.4,
                          color: df.colors.textTertiary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
