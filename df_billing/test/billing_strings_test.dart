import 'package:df_billing/df_billing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DfBillingStrings', () {
    test('default strings are in English', () {
      const strings = DfBillingStrings();
      expect(strings.simulateProTitle, 'Simulate Pro Mode');
      expect(strings.cancelButtonText, 'Cancel');
      expect(strings.simulatorConfirmButtonText, 'Simulate Pro Purchase 🎉');
    });

    test('German strings (.de) provide valid non-empty copy', () {
      const de = DfBillingStrings.de();
      expect(de.simulateProTitle, 'Pro-Modus simulieren');
      expect(de.simulateProSubtitle, isNotEmpty);
      expect(de.simulatorDialogTitle, '🧪 Test-Paywall (Debug)');
      expect(
        de.simulatorDialogMessage,
        contains('Produkte sind noch nicht im Store'),
      );
      expect(de.simulatorConfirmButtonText, 'Pro-Kauf simulieren 🎉');
      expect(de.cancelButtonText, 'Abbrechen');
      expect(de.simulationEnabledMessage, 'Pro-Modus-Simulation aktiviert 🎉');
      expect(de.simulationDisabledMessage, 'Pro-Modus-Simulation deaktiviert');
      expect(
        de.simulationSuccessMessage,
        'Pro-Modus erfolgreich simuliert! 🎉',
      );
    });

    test('supports custom overrides', () {
      const custom = DfBillingStrings.de(cancelButtonText: 'Schließen');
      expect(custom.cancelButtonText, 'Schließen');
      expect(custom.simulateProTitle, 'Pro-Modus simulieren');
    });
  });
}
