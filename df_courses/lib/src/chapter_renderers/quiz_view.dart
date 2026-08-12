import 'dart:math';

import 'package:df_theme/df_theme.dart';
import 'package:flutter/material.dart';

import '../course_models.dart';
import '../course_strings.dart';

class QuizChapterView extends StatefulWidget {
  const QuizChapterView({
    super.key,
    required this.chapter,
    required this.initiallyPassed,
    required this.onPassed,
    this.strings = const CourseStrings(),
  });

  final QuizChapter chapter;
  final bool initiallyPassed;
  final VoidCallback onPassed;

  /// User-facing copy. Defaults to English; pass a localized instance.
  final CourseStrings strings;

  @override
  State<QuizChapterView> createState() => _QuizChapterViewState();
}

class _QuizChapterViewState extends State<QuizChapterView> {
  final _rng = Random();
  late List<QuizQuestion> _questions;
  late List<int?> _selected;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _shuffle();
    if (widget.initiallyPassed) {
      _submitted = true;
    }
  }

  void _shuffle() {
    _questions = [...widget.chapter.questions]..shuffle(_rng);
    _questions = _questions
        .map(
          (q) => QuizQuestion(
            id: q.id,
            text: q.text,
            options: [...q.options]..shuffle(_rng),
          ),
        )
        .toList(growable: false);
    _selected = List.filled(_questions.length, null);
  }

  int get _correctCount {
    var n = 0;
    for (var i = 0; i < _questions.length; i++) {
      final pick = _selected[i];
      if (pick != null && _questions[i].options[pick].correct) {
        n++;
      }
    }
    return n;
  }

  int get _scorePct => _questions.isEmpty
      ? 0
      : (100 * _correctCount / _questions.length).round();

  bool get _allAnswered => !_selected.contains(null);

  void _submit() {
    setState(() => _submitted = true);
    if (_scorePct >= widget.chapter.passingScore) {
      widget.onPassed();
    }
  }

  void _reset() {
    setState(() {
      _submitted = false;
      _shuffle();
    });
  }

  @override
  Widget build(BuildContext context) {
    final df = context.df;
    final passed = _submitted && _scorePct >= widget.chapter.passingScore;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(widget.chapter.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.chapter.title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: df.colors.brand.deep,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${widget.strings.passingScoreLabel}: ${widget.chapter.passingScore}%',
          style: TextStyle(fontSize: 12, color: df.colors.textTertiary),
        ),
        const SizedBox(height: 12),
        ...List.generate(_questions.length, (qIdx) {
          final q = _questions[qIdx];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: df.colors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: df.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.strings.questionLabel} ${qIdx + 1}: ${q.text}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: df.colors.textPrimary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                ...List.generate(q.options.length, (oIdx) {
                  final opt = q.options[oIdx];
                  final isSelected = _selected[qIdx] == oIdx;
                  Color? bg;
                  Color? border;
                  Widget? trailing;
                  if (_submitted) {
                    if (opt.correct) {
                      bg = df.colors.success.bg;
                      border = df.colors.success.base;
                      trailing = Icon(
                        Icons.check_circle_rounded,
                        color: df.colors.success.base,
                        size: 18,
                      );
                    } else if (isSelected) {
                      bg = df.colors.error.bg;
                      border = df.colors.error.base;
                      trailing = Icon(
                        Icons.cancel_rounded,
                        color: df.colors.error.base,
                        size: 18,
                      );
                    }
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: _submitted
                          ? null
                          : () => setState(() => _selected[qIdx] = oIdx),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color:
                              bg ??
                              (isSelected
                                  ? df.colors.info.bg
                                  : df.colors.canvas),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color:
                                border ??
                                (isSelected
                                    ? df.colors.info.base
                                    : df.colors.hairline),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.radio_button_checked_rounded
                                  : Icons.radio_button_unchecked_rounded,
                              size: 18,
                              color: isSelected
                                  ? df.colors.info.base
                                  : df.colors.textDisabled,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                opt.text,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  height: 1.4,
                                  color: df.colors.textSecondary,
                                ),
                              ),
                            ),
                            if (trailing != null) ...[
                              const SizedBox(width: 6),
                              trailing,
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                if (_submitted &&
                    _selected[qIdx] != null &&
                    q.options[_selected[qIdx]!].explain != null) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: df.colors.surfaceSunken,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      q.options[_selected[qIdx]!].explain!,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: df.colors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
        if (!_submitted)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _allAnswered ? _submit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: df.colors.brand.base,
                foregroundColor: df.colors.textOnBrand,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(widget.strings.checkAnswersLabel),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: passed ? df.colors.success.bg : df.colors.error.bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: passed ? df.colors.success.base : df.colors.error.base,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  passed ? Icons.check_circle_rounded : Icons.replay_rounded,
                  color: passed ? df.colors.success.base : df.colors.error.base,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        passed
                            ? widget.strings.quizPassedLabel
                            : widget.strings.quizFailedLabel,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: passed
                              ? df.colors.success.deep
                              : df.colors.error.deep,
                        ),
                      ),
                      Text(
                        widget.strings.score(
                          widget.strings.quizScoreLabel,
                          correct: _correctCount,
                          total: _questions.length,
                          percent: _scorePct,
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          color: df.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!passed)
                  TextButton(
                    onPressed: _reset,
                    child: Text(widget.strings.retryLabel),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
