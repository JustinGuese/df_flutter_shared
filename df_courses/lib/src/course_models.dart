import 'package:flutter/material.dart';

enum CourseRiskTier { low, medium, high }

/// Which risk tiers a chapter is shown for.
///
/// [lowPlus] means "low and above", which is every tier — it is kept only so
/// existing course JSON keeps parsing, and behaves exactly like [any].
enum CourseChapterVisibility {
  any,
  @Deprecated('Identical to CourseChapterVisibility.any; use that instead.')
  lowPlus,
  mediumPlus,
  highOnly,
}

extension CourseChapterVisibilityX on CourseChapterVisibility {
  bool matches(CourseRiskTier tier) {
    switch (this) {
      case CourseChapterVisibility.any:
        return true;
      // ignore: deprecated_member_use_from_same_package
      case CourseChapterVisibility.lowPlus:
        return true;
      case CourseChapterVisibility.mediumPlus:
        return tier == CourseRiskTier.medium || tier == CourseRiskTier.high;
      case CourseChapterVisibility.highOnly:
        return tier == CourseRiskTier.high;
    }
  }
}

enum CourseChapterType { reading, checklist, redFlags, quiz }

@immutable
abstract class CourseChapter {
  const CourseChapter({
    required this.id,
    required this.title,
    required this.emoji,
    required this.visibleFor,
  });

  final String id;
  final String title;
  final String emoji;
  final CourseChapterVisibility visibleFor;

  CourseChapterType get type;

  factory CourseChapter.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    switch (type) {
      case 'reading':
        return ReadingChapter.fromJson(json);
      case 'checklist':
      // NaviCare's authored content predates the generic type name. Accepted so
      // existing course JSON keeps parsing; new content should use 'checklist'.
      case 'maßnahmenChecklist':
      case 'massnahmenChecklist':
        return ChecklistChapter.fromJson(json);
      case 'redFlags':
        return RedFlagsChapter.fromJson(json);
      case 'quiz':
        return QuizChapter.fromJson(json);
      default:
        throw FormatException('Unknown chapter type: $type');
    }
  }
}

CourseChapterVisibility _parseVisibility(String? raw) {
  switch (raw) {
    case 'lowPlus':
      return CourseChapterVisibility.lowPlus;
    case 'mediumPlus':
      return CourseChapterVisibility.mediumPlus;
    case 'highOnly':
      return CourseChapterVisibility.highOnly;
    case 'any':
    case null:
    default:
      return CourseChapterVisibility.any;
  }
}

class ReadingChapter extends CourseChapter {
  const ReadingChapter({
    required super.id,
    required super.title,
    required super.emoji,
    required super.visibleFor,
    required this.markdown,
    this.bulletItems,
  });

  final String markdown;
  final List<String>? bulletItems;

  @override
  CourseChapterType get type => CourseChapterType.reading;

  factory ReadingChapter.fromJson(Map<String, dynamic> json) {
    return ReadingChapter(
      id: json['id'] as String,
      title: json['title'] as String,
      emoji: json['emoji'] as String? ?? '📖',
      visibleFor: _parseVisibility(json['visibleFor'] as String?),
      markdown: json['markdown'] as String? ?? '',
      bulletItems: (json['bullets'] as List?)?.cast<String>(),
    );
  }
}

@immutable
class ChecklistItem {
  const ChecklistItem({required this.id, required this.label, this.why});
  final String id;
  final String label;
  final String? why;

  factory ChecklistItem.fromJson(Map<String, dynamic> json) => ChecklistItem(
    id: json['id'] as String,
    label: json['label'] as String,
    why: json['why'] as String?,
  );
}

class ChecklistChapter extends CourseChapter {
  const ChecklistChapter({
    required super.id,
    required super.title,
    required super.emoji,
    required super.visibleFor,
    required this.intro,
    required this.items,
  });

  final String? intro;
  final List<ChecklistItem> items;

  @override
  CourseChapterType get type => CourseChapterType.checklist;

  factory ChecklistChapter.fromJson(Map<String, dynamic> json) {
    return ChecklistChapter(
      id: json['id'] as String,
      title: json['title'] as String,
      emoji: json['emoji'] as String? ?? '✅',
      visibleFor: _parseVisibility(json['visibleFor'] as String?),
      intro: json['intro'] as String?,
      items: (json['items'] as List)
          .map((e) => ChecklistItem.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}

class RedFlagsChapter extends CourseChapter {
  const RedFlagsChapter({
    required super.id,
    required super.title,
    required super.emoji,
    required super.visibleFor,
    required this.intro,
    required this.signals,
    this.ctaLabel,
    this.ctaAction,
  });

  final String? intro;
  final List<String> signals;
  final String? ctaLabel;
  final String? ctaAction;

  @override
  CourseChapterType get type => CourseChapterType.redFlags;

  factory RedFlagsChapter.fromJson(Map<String, dynamic> json) {
    return RedFlagsChapter(
      id: json['id'] as String,
      title: json['title'] as String,
      emoji: json['emoji'] as String? ?? '🆘',
      visibleFor: _parseVisibility(json['visibleFor'] as String?),
      intro: json['intro'] as String?,
      signals: (json['signals'] as List).cast<String>(),
      ctaLabel: json['ctaLabel'] as String?,
      ctaAction: json['ctaAction'] as String?,
    );
  }
}

@immutable
class QuizOption {
  const QuizOption({required this.text, required this.correct, this.explain});
  final String text;
  final bool correct;
  final String? explain;

  factory QuizOption.fromJson(Map<String, dynamic> json) => QuizOption(
    text: json['text'] as String,
    correct: json['correct'] as bool? ?? false,
    explain: json['explain'] as String?,
  );

  factory QuizOption.fromAny(
    dynamic raw, {
    required bool correct,
    String? explain,
  }) {
    if (raw is String) {
      return QuizOption(text: raw, correct: correct, explain: explain);
    }
    final map = raw as Map<String, dynamic>;
    return QuizOption(
      text: map['text'] as String,
      correct: (map['correct'] as bool?) ?? correct,
      explain: (map['explain'] as String?) ?? explain,
    );
  }
}

@immutable
class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.text,
    required this.options,
  });
  final String id;
  final String text;
  final List<QuizOption> options;

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    final text = (json['text'] as String?) ?? (json['question'] as String);
    final correctIndex = json['correctIndex'] as int?;
    final explanation = json['explanation'] as String?;
    final rawOptions = json['options'] as List;
    final options = <QuizOption>[];
    for (var i = 0; i < rawOptions.length; i++) {
      options.add(
        QuizOption.fromAny(
          rawOptions[i],
          correct: correctIndex != null && correctIndex == i,
          explain: explanation,
        ),
      );
    }
    return QuizQuestion(
      id: json['id'] as String,
      text: text,
      options: List.unmodifiable(options),
    );
  }
}

class QuizChapter extends CourseChapter {
  const QuizChapter({
    required super.id,
    required super.title,
    required super.emoji,
    required super.visibleFor,
    required this.questions,
    required this.passingScore,
  });

  final List<QuizQuestion> questions;
  final int passingScore; // 0-100

  @override
  CourseChapterType get type => CourseChapterType.quiz;

  factory QuizChapter.fromJson(Map<String, dynamic> json) {
    return QuizChapter(
      id: json['id'] as String,
      title: json['title'] as String,
      emoji: json['emoji'] as String? ?? '🎓',
      visibleFor: _parseVisibility(json['visibleFor'] as String?),
      passingScore: json['passingScore'] as int? ?? 80,
      questions: (json['questions'] as List)
          .map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}

/// Top-level JSON keys [CourseModel] models directly. Everything else lands in
/// [CourseModel.meta].
const _knownKeys = <String>{
  'id',
  'moduleKey',
  'title',
  'subtitle',
  'emoji',
  'version',
  'chapters',
};

@immutable
class CourseModel {
  const CourseModel({
    required this.id,
    required this.moduleKey,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.gradient,
    required this.version,
    required this.chapters,
    this.meta = const <String, dynamic>{},
  });

  final String id;

  /// Stable key for this course; also the progress bucket.
  final String moduleKey;
  final String title;
  final String subtitle;
  final String emoji;
  final List<Color> gradient;
  final String version;
  final List<CourseChapter> chapters;

  /// Everything the app knows about a course that this package does not.
  ///
  /// [CourseModel.fromJson] keeps any unrecognised top-level keys here, so an
  /// app can carry domain fields through the shared model without the package
  /// growing a vocabulary for them. This replaces four hardcoded German
  /// nursing fields (`steckbrief`, `gefaehrdetePersonengruppen`,
  /// `screeningInstrument`, `expertStandard`) that no renderer ever read.
  ///
  /// ```dart
  /// final standard = course.meta['expertStandard'] as String? ?? '';
  /// ```
  final Map<String, dynamic> meta;

  /// Filter chapters for the given risk tier.
  List<CourseChapter> chaptersForTier(CourseRiskTier tier) =>
      chapters.where((c) => c.visibleFor.matches(tier)).toList(growable: false);

  factory CourseModel.fromJson(
    Map<String, dynamic> json, {
    required List<Color> gradient,
  }) {
    return CourseModel(
      id: json['id'] as String,
      moduleKey: json['moduleKey'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String? ?? '',
      emoji: json['emoji'] as String? ?? '📚',
      gradient: gradient,
      version: json['version'] as String? ?? '1.0',
      chapters: (json['chapters'] as List)
          .map((e) => CourseChapter.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      // Anything this package does not model is preserved rather than dropped,
      // so apps can round-trip their own fields.
      meta: <String, dynamic>{
        for (final entry in json.entries)
          if (!_knownKeys.contains(entry.key)) entry.key: entry.value,
      },
    );
  }
}
