import 'package:df_theme/df_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import '../course_models.dart';

class ReadingChapterView extends StatelessWidget {
  const ReadingChapterView({super.key, required this.chapter});

  final ReadingChapter chapter;

  @override
  Widget build(BuildContext context) {
    final df = context.df;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: df.colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: df.cardShadow,
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
                    color: df.colors.brand.deep,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          MarkdownBody(
            data: chapter.markdown,
            styleSheet: MarkdownStyleSheet(
              p: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: df.colors.textSecondary,
              ),
              h1: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: df.colors.brand.deep,
              ),
              h2: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: df.colors.brand.deep,
              ),
              h3: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: df.colors.brand.deep,
              ),
              listBullet: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: df.colors.textSecondary,
              ),
              strong: TextStyle(
                fontWeight: FontWeight.w700,
                color: df.colors.brand.deep,
              ),
            ),
          ),
          if (chapter.bulletItems != null &&
              chapter.bulletItems!.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...chapter.bulletItems!.map(
              (b) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 7, right: 8),
                      child: Icon(
                        Icons.circle,
                        size: 5,
                        color: df.colors.textDisabled,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        b,
                        style: TextStyle(
                          fontSize: 13.5,
                          height: 1.45,
                          color: df.colors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
