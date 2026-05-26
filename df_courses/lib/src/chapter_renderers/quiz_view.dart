import 'dart:math';

import 'package:flutter/material.dart';

import '../course_models.dart';

class QuizChapterView extends StatefulWidget {
  const QuizChapterView({
    super.key,
    required this.chapter,
    required this.initiallyPassed,
    required this.onPassed,
  });

  final QuizChapter chapter;
  final bool initiallyPassed;
  final VoidCallback onPassed;

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
        .map((q) => QuizQuestion(
              id: q.id,
              text: q.text,
              options: [...q.options]..shuffle(_rng),
            ))
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
    final passed =
        _submitted && _scorePct >= widget.chapter.passingScore;
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
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0C445A),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Bestehensgrenze: ${widget.chapter.passingScore}%',
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 12),
        ...List.generate(_questions.length, (qIdx) {
          final q = _questions[qIdx];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Frage ${qIdx + 1}: ${q.text}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
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
                      bg = const Color(0xFFECFDF5);
                      border = const Color(0xFF10B981);
                      trailing = const Icon(Icons.check_circle_rounded,
                          color: Color(0xFF10B981), size: 18);
                    } else if (isSelected) {
                      bg = const Color(0xFFFEF2F2);
                      border = const Color(0xFFEF4444);
                      trailing = const Icon(Icons.cancel_rounded,
                          color: Color(0xFFEF4444), size: 18);
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
                          color: bg ??
                              (isSelected
                                  ? const Color(0xFFEFF6FF)
                                  : const Color(0xFFF8FAFC)),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: border ??
                                (isSelected
                                    ? const Color(0xFF3B82F6)
                                    : const Color(0xFFE2E8F0)),
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
                                  ? const Color(0xFF3B82F6)
                                  : const Color(0xFF94A3B8),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                opt.text,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  height: 1.4,
                                  color: Color(0xFF334155),
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
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      q.options[_selected[qIdx]!].explain!,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF334155),
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
                backgroundColor: const Color(0xFF0E6B82),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Antworten prüfen'),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: passed
                  ? const Color(0xFFECFDF5)
                  : const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: passed
                    ? const Color(0xFF10B981)
                    : const Color(0xFFEF4444),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  passed
                      ? Icons.check_circle_rounded
                      : Icons.replay_rounded,
                  color: passed
                      ? const Color(0xFF10B981)
                      : const Color(0xFFEF4444),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        passed ? 'Bestanden!' : 'Noch nicht bestanden',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: passed
                              ? const Color(0xFF065F46)
                              : const Color(0xFF7F1D1D),
                        ),
                      ),
                      Text(
                        '$_correctCount von ${_questions.length} richtig · $_scorePct%',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!passed)
                  TextButton(
                    onPressed: _reset,
                    child: const Text('Erneut'),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
