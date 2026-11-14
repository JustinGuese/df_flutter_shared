import 'package:flutter/foundation.dart';

/// User-facing and debug copy for [df_billing] components.
///
/// Defaults are English. Pass custom strings or use [DfBillingStrings.de] for
/// localization.
@immutable
class DfBillingStrings {
  const DfBillingStrings({
    this.simulateProTitle = 'Simulate Pro Mode',
    this.simulateProSubtitle =
        'Bypass store/backend entitlement checks for local testing',
    this.simulatorDialogTitle = '🧪 Test Paywall (Debug)',
    this.simulatorDialogMessage =
        'Products are not published in store yet ("product not found").\n\nWould you like to simulate a successful Pro purchase?',
    this.simulatorConfirmButtonText = 'Simulate Pro Purchase 🎉',
    this.cancelButtonText = 'Cancel',
    this.simulationEnabledMessage = 'Pro mode simulation enabled 🎉',
    this.simulationDisabledMessage = 'Pro mode simulation disabled',
    this.simulationSuccessMessage = 'Pro mode simulated successfully! 🎉',
  });

  /// German strings.
  const DfBillingStrings.de({
    this.simulateProTitle = 'Pro-Modus simulieren',
    this.simulateProSubtitle =
        'Store-/Backend-Berechtigungsprüfungen für lokale Tests umgehen',
    this.simulatorDialogTitle = '🧪 Test-Paywall (Debug)',
    this.simulatorDialogMessage =
        'Produkte sind noch nicht im Store veröffentlicht („Produkt nicht gefunden“).\n\nMöchtest du einen erfolgreichen Pro-Kauf simulieren?',
    this.simulatorConfirmButtonText = 'Pro-Kauf simulieren 🎉',
    this.cancelButtonText = 'Abbrechen',
    this.simulationEnabledMessage = 'Pro-Modus-Simulation aktiviert 🎉',
    this.simulationDisabledMessage = 'Pro-Modus-Simulation deaktiviert',
    this.simulationSuccessMessage = 'Pro-Modus erfolgreich simuliert! 🎉',
  });

  final String simulateProTitle;
  final String simulateProSubtitle;
  final String simulatorDialogTitle;
  final String simulatorDialogMessage;
  final String simulatorConfirmButtonText;
  final String cancelButtonText;
  final String simulationEnabledMessage;
  final String simulationDisabledMessage;
  final String simulationSuccessMessage;
}
