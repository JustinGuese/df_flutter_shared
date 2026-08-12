import 'package:flutter/foundation.dart';

/// User-facing copy for [CourseScreen] and its chapter renderers.
///
/// Defaults are English: a shared package must not impose a language on the
/// apps that consume it. Pass a localized instance to override.
@immutable
class CourseStrings {
  const CourseStrings({
    this.backLabel = 'Back',
    this.nextLabel = 'Next',
    this.doneLabel = 'Done',
    this.quizLockedLabel = 'Pass the quiz to continue',
    this.checkAnswersLabel = 'Check answers',
    this.questionLabel = 'Question',
    this.passingScoreLabel = 'Pass mark',
    this.quizPassedLabel = 'Passed',
    this.quizFailedLabel = 'Not passed yet',
    this.retryLabel = 'Try again',
    this.quizScoreLabel = '{correct} of {total} correct · {percent}%',
  });

  /// Substitutes `{correct}`, `{total}` and `{percent}` in [quizScoreLabel].
  ///
  /// Placeholders rather than interpolation at the call site, so a translation
  /// can order the numbers however its grammar needs.
  String score(
    String template, {
    required int correct,
    required int total,
    required int percent,
  }) => template
      .replaceAll('{correct}', '$correct')
      .replaceAll('{total}', '$total')
      .replaceAll('{percent}', '$percent');

  /// Bottom-nav button that returns to the previous chapter.
  final String backLabel;

  /// Bottom-nav button that advances to the next chapter.
  final String nextLabel;

  /// Bottom-nav button shown in place of [nextLabel] on the last chapter.
  final String doneLabel;

  /// Hint shown when a quiz chapter blocks forward navigation until passed.
  final String quizLockedLabel;

  /// Submit button on a quiz chapter.
  final String checkAnswersLabel;

  /// Prefix rendered before each quiz question's number, e.g. '$questionLabel 1: ...'.
  final String questionLabel;

  /// Prefix for the quiz pass threshold, rendered as `'<label>: 70%'`.
  final String passingScoreLabel;

  /// Result heading when the learner met the pass mark.
  final String quizPassedLabel;

  /// Result heading when they did not. Phrased as "not yet" rather than a
  /// failure — the quiz can be retaken.
  final String quizFailedLabel;

  /// Button that resets the quiz.
  final String retryLabel;

  /// Score summary. See [score] for the placeholders.
  final String quizScoreLabel;
}
