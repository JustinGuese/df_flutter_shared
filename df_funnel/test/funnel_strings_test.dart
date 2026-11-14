import 'package:df_funnel/df_funnel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DfSubscriptionSettingsStrings.de', () {
    test('provides non-empty German strings', () {
      const de = DfSubscriptionSettingsStrings.de();
      expect(de.sectionHeader, 'Abonnement');
      expect(de.manageSubscriptionTitle, 'Abonnement verwalten');
      expect(de.customerCenterTitle, 'Kundencenter');
      expect(de.restorePurchasesTitle, 'Käufe wiederherstellen');
      expect(
        de.restoreSuccessMessage,
        'Käufe erfolgreich wiederhergestellt! 🎉',
      );
      expect(de.restoreNotFoundMessage, isNotEmpty);
      expect(de.storeLinkFallbackMessage, isNotEmpty);
      expect(de.webFallbackMessage, isNotEmpty);
    });

    test('error and fallback formatters include target details', () {
      const de = DfSubscriptionSettingsStrings.de();
      expect(
        de.restoreError('Netzwerkfehler'),
        'Fehler beim Wiederherstellen: Netzwerkfehler',
      );
      expect(de.customerCenterError('404'), 'Kundencenter-Fehler: 404');
      expect(
        de.storeFallback('https://example.com'),
        'Bitte verwalte Abonnements in den Einstellungen deines Geräts (https://example.com)',
      );
    });
  });

  group('DfFunnelStrings.de', () {
    test('provides non-empty German copy for funnel components', () {
      const de = DfFunnelStrings.de();
      expect(de.proPillLabel, 'Pro kostenlos testen');
      expect(de.heroEyebrow, 'PRO');
      expect(de.upsellCta, 'Auf Pro upgraden');
      expect(de.upsellLater, 'Vielleicht später');
      expect(de.lockedTitle, 'Mit Pro freischalten');
      expect(de.lockedAction, 'Upgraden');
      expect(de.perkZeroAdsTitle, 'Keine Werbung');
      expect(de.perkAiAnalystTitle, 'KI-Nachrichtenanalyst');
    });

    test('custom overrides work alongside German defaults', () {
      const custom = DfFunnelStrings.de(proPillLabel: 'Premium testen');
      expect(custom.proPillLabel, 'Premium testen');
      expect(custom.upsellCta, 'Auf Pro upgraden');
    });
  });
}
