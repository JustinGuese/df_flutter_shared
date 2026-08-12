import 'package:df_theme/df_theme.dart';
import 'package:flutter/material.dart';

import '../course_models.dart';

class RedFlagsChapterView extends StatelessWidget {
  const RedFlagsChapterView({super.key, required this.chapter, this.onCta});

  final RedFlagsChapter chapter;
  final VoidCallback? onCta;

  @override
  Widget build(BuildContext context) {
    final df = context.df;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: df.colors.error.bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: df.colors.error.soft),
      ),
      child: Column(
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
                    color: df.colors.error.deep,
                  ),
                ),
              ),
            ],
          ),
          if (chapter.intro != null) ...[
            const SizedBox(height: 8),
            Text(
              chapter.intro!,
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: df.colors.error.deep,
              ),
            ),
          ],
          const SizedBox(height: 12),
          ...chapter.signals.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2, right: 8),
                    child: Icon(
                      Icons.warning_amber_rounded,
                      size: 18,
                      color: df.colors.error.base,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      s,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: df.colors.error.deep,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (chapter.ctaLabel != null) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onCta,
                icon: const Icon(Icons.call_rounded, size: 18),
                label: Text(chapter.ctaLabel!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: df.colors.error.base,
                  foregroundColor: df.colors.textOnBrand,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
