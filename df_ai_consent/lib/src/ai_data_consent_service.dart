import 'package:shared_preferences/shared_preferences.dart';

/// Manages AI data consent state via [SharedPreferences].
///
/// Each app should create its own singleton instance with a unique [consentKey].
class AiDataConsentService {
  AiDataConsentService({required this.consentKey});

  final String consentKey;
  bool? _cachedConsent;

  Future<bool> hasConsented() async {
    if (_cachedConsent != null) return _cachedConsent!;
    final prefs = await SharedPreferences.getInstance();
    _cachedConsent = prefs.getBool(consentKey) ?? false;
    return _cachedConsent!;
  }

  Future<void> grantConsent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(consentKey, true);
    _cachedConsent = true;
  }

  Future<void> revokeConsent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(consentKey, false);
    _cachedConsent = false;
  }
}
