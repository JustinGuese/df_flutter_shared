import 'package:flutter/material.dart';

import '../course_models.dart';

class RedFlagsChapterView extends StatelessWidget {
  const RedFlagsChapterView({super.key, required this.chapter, this.onCta});

  final RedFlagsChapter chapter;
  final VoidCallback? onCta;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFCA5A5)),
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
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF991B1B),
                  ),
                ),
              ),
            ],
          ),
          if (chapter.intro != null) ...[
            const SizedBox(height: 8),
            Text(
              chapter.intro!,
              style: const TextStyle(
                fontSize: 13,
                height: 1.45,
                color: Color(0xFF7F1D1D),
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
                  const Padding(
                    padding: EdgeInsets.only(top: 2, right: 8),
                    child: Icon(
                      Icons.warning_amber_rounded,
                      size: 18,
                      color: Color(0xFFDC2626),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      s,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: Color(0xFF7F1D1D),
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
                  backgroundColor: const Color(0xFFDC2626),
                  foregroundColor: Colors.white,
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
