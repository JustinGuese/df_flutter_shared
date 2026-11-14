import 'package:flutter/foundation.dart';

/// User-facing copy for the tour hub, help button and coach-mark bubbles.
///
/// Defaults are English: a shared package must not impose a language on the
/// apps that consume it. Pass a localized instance to override.
@immutable
class DfTourStrings {
  const DfTourStrings({
    this.skipLabel = 'Skip',
    this.tapForNextLabel = 'Tap for next',
    this.tapToFinishLabel = 'Tap to finish',
    this.hubTitle = 'Your tour',
    this.hubSubtitle =
        'A few short steps through the app — and why each one is worth it.',
    this.hubAllDoneTitle = "You're all set",
    this.hubAllDoneMessage =
        'Every step is complete. Reopen the tour anytime from the help '
        'button.',
    this.replayLabel = 'Replay',
    this.continueLaterLabel = 'Continue later',
    this.closeLabel = 'Close',
    this.defaultCtaLabel = 'View',
    this.helpTooltip = 'Take a tour',
    this.progressLabel = '{done}/{total}',
  });

  /// German strings constructor.
  const DfTourStrings.de({
    this.skipLabel = 'Überspringen',
    this.tapForNextLabel = 'Tippen für weiter',
    this.tapToFinishLabel = 'Tippen zum Abschließen',
    this.hubTitle = 'Deine Tour',
    this.hubSubtitle =
        'Ein paar kurze Schritte durch die App – und warum sich jeder einzelne lohnt.',
    this.hubAllDoneTitle = 'Alles erledigt',
    this.hubAllDoneMessage =
        'Alle Schritte sind abgeschlossen. Du kannst die Tour jederzeit '
        'über den Hilfe-Button erneut öffnen.',
    this.replayLabel = 'Wiederholen',
    this.continueLaterLabel = 'Später fortsetzen',
    this.closeLabel = 'Schließen',
    this.defaultCtaLabel = 'Ansehen',
    this.helpTooltip = 'Tour starten',
    this.progressLabel = '{done}/{total}',
  });

  /// Substitutes `{done}` and `{total}` in [progressLabel].
  String progress({required int done, required int total}) => progressLabel
      .replaceAll('{done}', '$done')
      .replaceAll('{total}', '$total');

  /// The coach-mark overlay's skip button.
  final String skipLabel;

  /// Footer hint on a bubble that isn't the last in its sequence.
  final String tapForNextLabel;

  /// Footer hint on the last bubble in a sequence.
  final String tapToFinishLabel;

  /// Hub sheet heading while steps remain.
  final String hubTitle;

  /// Hub sheet subheading while steps remain.
  final String hubSubtitle;

  /// Hub sheet heading once every step is done.
  final String hubAllDoneTitle;

  /// Hub sheet subheading once every step is done.
  final String hubAllDoneMessage;

  /// Secondary button on an already-done step row, to see it again.
  final String replayLabel;

  /// Hub sheet's dismiss button while steps remain.
  final String continueLaterLabel;

  /// Hub sheet's dismiss button once every step is done.
  final String closeLabel;

  /// Fallback for [TourStep.ctaLabel] when a step doesn't set its own.
  final String defaultCtaLabel;

  /// Tooltip on [TourHelpButton].
  final String helpTooltip;

  /// Progress readout template. See [progress] for the placeholders.
  final String progressLabel;
}
