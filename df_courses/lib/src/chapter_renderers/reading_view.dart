import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../course_models.dart';

class ReadingChapterView extends StatelessWidget {
  const ReadingChapterView({super.key, required this.chapter});

  final ReadingChapter chapter;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
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
                    color: Color(0xFF0C445A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          MarkdownBody(
            data: chapter.markdown,
            styleSheet: MarkdownStyleSheet(
              p: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Color(0xFF334155),
              ),
              h1: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0C445A),
              ),
              h2: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0C445A),
              ),
              h3: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0C445A),
              ),
              listBullet: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Color(0xFF334155),
              ),
              strong: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF0C445A),
              ),
            ),
          ),
          if (chapter.bulletItems != null && chapter.bulletItems!.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...chapter.bulletItems!.map((b) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 7, right: 8),
                        child: Icon(Icons.circle,
                            size: 5, color: Color(0xFF94A3B8)),
                      ),
                      Expanded(
                        child: Text(
                          b,
                          style: const TextStyle(
                            fontSize: 13.5,
                            height: 1.45,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }
}
