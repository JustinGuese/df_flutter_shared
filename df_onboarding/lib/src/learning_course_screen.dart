import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'learning_course_model.dart';
import 'learning_progress_notifier.dart';
import 'learning_step_model.dart';

/// Full-screen stepped course viewer for a single [LearningCourseModel].
///
/// Each section (sofortUmsetzbar, beiRisiko, warnsignale, notfall) is its own
/// page navigated via Back / Weiter buttons with a progress bar at the top.
/// The Warnsignale step embeds an inline QuickCheck (no bottom sheet).
///
/// [onProgressChanged] is called after every checkbox toggle so the consuming
/// app can sync to the backend.
class LearningCourseScreen extends ConsumerStatefulWidget {
  const LearningCourseScreen({
    super.key,
    required this.course,
    this.onProgressChanged,
    this.onFirstOpen,
  });

  final LearningCourseModel course;
  final void Function(Set<String> completedItemIds)? onProgressChanged;
  final VoidCallback? onFirstOpen;

  @override
  ConsumerState<LearningCourseScreen> createState() =>
      _LearningCourseScreenState();
}

class _LearningCourseScreenState extends ConsumerState<LearningCourseScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Warnsignale quick-check state (ephemeral, not persisted)
  List<bool> _warnsignaleChecked = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onFirstOpen?.call();
      final warnsignale = _stepOf(CourseSectionType.warnsignale);
      if (warnsignale != null) {
        _warnsignaleChecked = List.filled(warnsignale.items.length, false);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  LearningStepModel? _stepOf(CourseSectionType type) {
    try {
      return widget.course.steps.firstWhere((s) => s.type == type);
    } catch (_) {
      return null;
    }
  }

  List<LearningStepModel> get _pages =>
      widget.course.steps.where((s) => s.items.isNotEmpty).toList();

  int get _sofortTotal =>
      _stepOf(CourseSectionType.sofortUmsetzbar)?.items.length ?? 0;

  String _itemId(CourseSectionType type, int index) =>
      '${widget.course.key}_${type.name}_$index';

  void _toggle(String itemId, bool checked) {
    final notifier = ref.read(learningProgressNotifierProvider.notifier);
    if (checked) {
      notifier.markComplete(widget.course.key, itemId);
    } else {
      notifier.markIncomplete(widget.course.key, itemId);
    }
    widget.onProgressChanged
        ?.call(notifier.completedItemIds(widget.course.key));
  }

  void _goTo(int page) {
    setState(() => _currentPage = page);
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final progressState = ref.watch(learningProgressNotifierProvider);
    final completed = progressState[widget.course.key] ?? {};
    final ratio = _sofortTotal > 0 ? completed.length / _sofortTotal : 0.0;
    final pages = _pages;
    final totalPages = pages.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Column(
        children: [
          _buildHeader(context, ratio, completed.length),
          _buildStepIndicator(totalPages),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: totalPages,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (context, i) {
                final step = pages[i];
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: _buildStep(context, step, completed),
                );
              },
            ),
          ),
          _buildBottomNav(context, totalPages, completed),
        ],
      ),
    );
  }

  // ─── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, double ratio, int done) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.course.gradient,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button row
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 20),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: widget.course.riskLevelColor.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color:
                              widget.course.riskLevelColor.withValues(alpha: 0.7)),
                    ),
                    child: Text(
                      widget.course.riskLevelLabel,
                      style: TextStyle(
                        color: widget.course.riskLevelColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              // Emoji + title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(widget.course.emoji,
                        style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.course.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: ratio.clamp(0.0, 1.0),
                          backgroundColor: Colors.white.withValues(alpha: 0.3),
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.white),
                          minHeight: 5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '$done/$_sofortTotal',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
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

  // ─── Step dots ─────────────────────────────────────────────────────────────

  Widget _buildStepIndicator(int totalPages) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalPages, (i) {
          final active = i == _currentPage;
          final past = i < _currentPage;
          return GestureDetector(
            onTap: () => _goTo(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: active ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: active
                    ? widget.course.gradient.first
                    : past
                        ? widget.course.gradient.first.withValues(alpha: 0.35)
                        : Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ─── Step content ──────────────────────────────────────────────────────────

  Widget _buildStep(
      BuildContext context, LearningStepModel step, Set<String> completed) {
    switch (step.type) {
      case CourseSectionType.sofortUmsetzbar:
        return _buildSofortPage(step, completed);
      case CourseSectionType.beiRisiko:
        return _buildReadOnlyPage(step, const Color(0xFFD97706), '•');
      case CourseSectionType.warnsignale:
        return _buildWarnsignalePage(step);
      case CourseSectionType.notfall:
        return _buildNotfallPage(step);
    }
  }

  Widget _buildSofortPage(LearningStepModel step, Set<String> completed) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(step.emoji, step.title, const Color(0xFF059669)),
            const SizedBox(height: 6),
            Text(
              'Haken Sie Maßnahmen ab, sobald Sie diese umgesetzt haben.',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const Divider(height: 20),
            ...step.items.asMap().entries.map((e) {
              final itemId = _itemId(step.type, e.key);
              final done = completed.contains(itemId);
              return CheckboxListTile(
                value: done,
                onChanged: (val) => _toggle(itemId, val ?? false),
                title: Text(
                  e.value,
                  style: TextStyle(
                    fontSize: 13,
                    decoration: done ? TextDecoration.lineThrough : null,
                    color: done ? Colors.grey : Colors.black87,
                  ),
                ),
                activeColor: const Color(0xFF059669),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                dense: true,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyPage(
      LearningStepModel step, Color accentColor, String bullet) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(step.emoji, step.title, accentColor),
            const Divider(height: 20),
            ...step.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$bullet  ',
                        style: TextStyle(
                            color: accentColor, fontWeight: FontWeight.w700)),
                    Expanded(
                        child: Text(item,
                            style:
                                const TextStyle(fontSize: 13, height: 1.5))),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarnsignalePage(LearningStepModel step) {
    final anyChecked = _warnsignaleChecked.any((c) => c);
    return Column(
      children: [
        // Bullet list of warning signs
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeader(
                    step.emoji, step.title, const Color(0xFFEA580C)),
                const Divider(height: 20),
                ...step.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('⚠️  ',
                            style: TextStyle(fontSize: 13)),
                        Expanded(
                            child: Text(item,
                                style: const TextStyle(
                                    fontSize: 13, height: 1.5))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Inline quick-check
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text('🔍', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Sind aktuell Warnsignale vorhanden?',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Haken Sie an, was aktuell zutrifft:',
                  style:
                      TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const Divider(height: 16),
                ...step.items.asMap().entries.map((e) {
                  if (e.key >= _warnsignaleChecked.length) {
                    return const SizedBox.shrink();
                  }
                  return CheckboxListTile(
                    value: _warnsignaleChecked[e.key],
                    onChanged: (val) => setState(
                        () => _warnsignaleChecked[e.key] = val ?? false),
                    title: Text(e.value,
                        style: const TextStyle(fontSize: 13)),
                    activeColor: const Color(0xFFEA580C),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  );
                }),
                if (anyChecked) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            color: Color(0xFFDC2626), size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Bitte suchen Sie jetzt professionelle Hilfe auf.',
                            style: TextStyle(
                              color: Color(0xFFDC2626),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotfallPage(LearningStepModel step) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      color: const Color(0xFFFEF2F2),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(step.emoji, step.title, const Color(0xFFDC2626)),
            const Divider(height: 20),
            ...step.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🚨  ', style: TextStyle(fontSize: 13)),
                    Expanded(
                        child: Text(item,
                            style: const TextStyle(
                                fontSize: 13,
                                height: 1.5,
                                color: Colors.black87))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFDC2626).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: const Color(0xFFDC2626).withValues(alpha: 0.4)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: Color(0xFFDC2626), size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Bitte suchen Sie jetzt professionelle Hilfe auf.',
                      style: TextStyle(
                        color: Color(0xFFDC2626),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Bottom navigation ─────────────────────────────────────────────────────

  Widget _buildBottomNav(
      BuildContext context, int totalPages, Set<String> completed) {
    final isFirst = _currentPage == 0;
    final isLast = _currentPage == totalPages - 1;
    final pages = _pages;
    final stepLabel = pages.isNotEmpty
        ? pages[_currentPage].title
        : '';

    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Step label
          Text(
            'Schritt ${_currentPage + 1} von $totalPages — $stepLabel',
            style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (!isFirst)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _goTo(_currentPage - 1),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 14),
                    label: const Text('Zurück'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0E6B82),
                      side: const BorderSide(color: Color(0xFF0E6B82)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                  ),
                ),
              if (!isFirst) const SizedBox(width: 12),
              Expanded(
                flex: isFirst ? 1 : 1,
                child: FilledButton.icon(
                  onPressed: isLast
                      ? () => Navigator.of(context).maybePop()
                      : () => _goTo(_currentPage + 1),
                  icon: Icon(
                    isLast
                        ? Icons.check_circle_outline_rounded
                        : Icons.arrow_forward_ios_rounded,
                    size: 14,
                  ),
                  label: Text(isLast ? 'Fertig' : 'Weiter'),
                  style: FilledButton.styleFrom(
                    backgroundColor: isLast
                        ? const Color(0xFF059669)
                        : const Color(0xFF0E6B82),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Shared ────────────────────────────────────────────────────────────────

  Widget _sectionHeader(String emoji, String title, Color color) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
