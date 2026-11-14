import 'package:flutter/foundation.dart';

/// User-facing copy for AI consent dialog components.
@immutable
class AiConsentStrings {
  const AiConsentStrings({
    this.dialogTitle = 'AI Data Processing',
    this.privacyPolicyPrefix = 'For full details, see our ',
    this.privacyPolicyLink = 'Privacy Policy',
    this.privacyPolicySuffix = '.',
    this.declineButton = 'Decline',
    this.agreeButton = 'I Agree',
  });

  /// German strings constructor.
  const AiConsentStrings.de({
    this.dialogTitle = 'KI-Datenverarbeitung',
    this.privacyPolicyPrefix =
        'Ausführliche Informationen findest du in unserer ',
    this.privacyPolicyLink = 'Datenschutzerklärung',
    this.privacyPolicySuffix = '.',
    this.declineButton = 'Ablehnen',
    this.agreeButton = 'Zustimmen',
  });

  final String dialogTitle;
  final String privacyPolicyPrefix;
  final String privacyPolicyLink;
  final String privacyPolicySuffix;
  final String declineButton;
  final String agreeButton;
}

/// Alias matching `df_*` prefix convention.
typedef DfAiConsentStrings = AiConsentStrings;
