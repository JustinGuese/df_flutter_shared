import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'chapter_renderers/checklist_view.dart';
import 'chapter_renderers/quiz_view.dart';
import 'chapter_renderers/reading_view.dart';
import 'chapter_renderers/red_flags_view.dart';
import 'course_models.dart';
import 'course_progress_notifier.dart';

/// Full-screen course viewer for a [CourseModel].
///
/// One chapter per page, navigated via Back / Weiter with a progress bar.
/// Chapters are filtered by [tier] before rendering.
///
/// Progress (checklist toggles + quiz pass) is persisted by
/// [CourseProgressNotifier].
///
/// [stepGateBuilder] receives the chapter index the user is trying to reach.
/// Return a widget (e.g. paywall) to block navigation, or null to allow.
class CourseScreen extends ConsumerStatefulWidget {
  const CourseScreen({
    super.key,
    required this.course,
    required this.tier,
    required this.riskLevelLabel,
    required this.riskLevelColor,
    this.onProgressChanged,
    this.onFirstOpen,
    this.stepGateBuilder,
    this.onCtaAction,
  });

  final CourseModel course;
  final CourseRiskTier tier;
  final String riskLevelLabel;
  final Color riskLevelColor;
  final void Function(Set<String> completedItemIds)? onProgressChanged;
  final VoidCallback? onFirstOpen;
  final Widget? Function(int chapterIndex)? stepGateBuilder;
  final void Function(String action)? onCtaAction;

  @override
  ConsumerState<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends ConsumerState<CourseScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Widget? _gateWidget;

  late List<CourseChapter> _pages;

  @override
  void initState() {
    super.initState();
    _pages = widget.course.chaptersForTier(widget.tier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onFirstOpen?.call();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool _isBlockingQuiz(CourseChapter? chapter, Set<String> completed) {
    if (chapter is! QuizChapter) return false;
    return !completed.contains(_itemId(chapter, 'passed'));
  }

  String _itemId(CourseChapter chapter, String suffix) =>
      '${widget.course.moduleKey}_${chapter.id}_$suffix';

  void _toggle(CourseChapter chapter, String suffix, bool checked) {
    final notifier = ref.read(courseProgressNotifierProvider.notifier);
    final id = _itemId(chapter, suffix);
    if (checked) {
      notifier.markComplete(widget.course.moduleKey, id);
    } else {
      notifier.markIncomplete(widget.course.moduleKey, id);
    }
    widget.onProgressChanged?.call(
      notifier.completedItemIds(widget.course.moduleKey),
    );
  }

  void _markQuizPassed(CourseChapter chapter) {
    final notifier = ref.read(courseProgressNotifierProvider.notifier);
    final id = _itemId(chapter, 'passed');
    notifier.markComplete(widget.course.moduleKey, id);
    widget.onProgressChanged?.call(
      notifier.completedItemIds(widget.course.moduleKey),
    );
  }

  void _goTo(int page) {
    final gate = widget.stepGateBuilder?.call(page);
    if (gate != null) {
      setState(() => _gateWidget = gate);
      return;
    }
    setState(() {
      _gateWidget = null;
      _currentPage = page;
    });
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final progressState = ref.watch(courseProgressNotifierProvider);
    final completed = progressState[widget.course.moduleKey] ?? <String>{};
    final totalPages = _pages.length;
    final ratio = totalPages == 0 ? 0.0 : (_currentPage + 1) / totalPages;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Column(
        children: [
          _Header(
            course: widget.course,
            riskLevelLabel: widget.riskLevelLabel,
            riskLevelColor: widget.riskLevelColor,
            chapterIndex: _currentPage,
            chapterCount: totalPages,
            ratio: ratio,
          ),
          Expanded(
            child: _gateWidget != null
                ? SingleChildScrollView(child: _gateWidget!)
                : PageView.builder(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: totalPages,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemBuilder: (context, i) => SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: _renderChapter(_pages[i], completed),
                    ),
                  ),
          ),
          _BottomNav(
            current: _currentPage,
            total: totalPages,
            onBack: _currentPage > 0 ? () => _goTo(_currentPage - 1) : null,
            onNext:
                _currentPage < totalPages - 1 &&
                    !_isBlockingQuiz(_pages[_currentPage], completed)
                ? () => _goTo(_currentPage + 1)
                : null,
            onFinish:
                _currentPage == totalPages - 1 &&
                    !_isBlockingQuiz(_pages[_currentPage], completed)
                ? () => Navigator.of(context).maybePop()
                : null,
            primaryColor: widget.course.gradient.last,
            disabledHint:
                _isBlockingQuiz(
                  _pages.isEmpty ? null : _pages[_currentPage],
                  completed,
                )
                ? 'Bitte Quiz erfolgreich abschließen'
                : null,
          ),
        ],
      ),
    );
  }

  Widget _renderChapter(CourseChapter chapter, Set<String> completed) {
    switch (chapter) {
      case ReadingChapter r:
        return ReadingChapterView(chapter: r);
      case ChecklistChapter c:
        return ChecklistChapterView(
          chapter: c,
          isChecked: (item) =>
              completed.contains(_itemId(c, 'item_${item.id}')),
          onToggle: (item, checked) =>
              _toggle(chapter, 'item_${item.id}', checked),
        );
      case RedFlagsChapter rf:
        return RedFlagsChapterView(
          chapter: rf,
          onCta: rf.ctaAction == null
              ? null
              : () => widget.onCtaAction?.call(rf.ctaAction!),
        );
      case QuizChapter q:
        final passed = completed.contains(_itemId(q, 'passed'));
        return QuizChapterView(
          chapter: q,
          initiallyPassed: passed,
          onPassed: () => _markQuizPassed(q),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.course,
    required this.riskLevelLabel,
    required this.riskLevelColor,
    required this.chapterIndex,
    required this.chapterCount,
    required this.ratio,
  });

  final CourseModel course;
  final String riskLevelLabel;
  final Color riskLevelColor;
  final int chapterIndex;
  final int chapterCount;
  final double ratio;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: course.gradient,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: riskLevelColor.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: riskLevelColor.withValues(alpha: 0.7),
                      ),
                    ),
                    child: Text(
                      riskLevelLabel,
                      style: TextStyle(
                        color: riskLevelColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Text(course.emoji, style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (course.subtitle.isNotEmpty)
                            Text(
                              course.subtitle,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 11,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: ratio.clamp(0.0, 1.0),
                          minHeight: 5,
                          backgroundColor: Colors.white.withValues(alpha: 0.25),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      chapterCount == 0
                          ? '–'
                          : '${chapterIndex + 1}/$chapterCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.current,
    required this.total,
    required this.primaryColor,
    this.onBack,
    this.onNext,
    this.onFinish,
    this.disabledHint,
  });

  final int current;
  final int total;
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final VoidCallback? onFinish;
  final Color primaryColor;
  final String? disabledHint;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (disabledHint != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  disabledHint!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            Row(
              children: [
                if (onBack != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onBack,
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                      label: const Text('Zurück'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF334155),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                if (onBack != null) const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onNext ?? onFinish,
                    icon: Icon(
                      onFinish != null
                          ? Icons.check_rounded
                          : Icons.arrow_forward_rounded,
                      size: 18,
                    ),
                    label: Text(onFinish != null ? 'Fertig' : 'Weiter'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
