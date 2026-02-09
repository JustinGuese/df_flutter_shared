import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform, kDebugMode, debugPrint;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'analytics_config.dart';
import 'analytics_service.dart';
import 'tracking_service.dart';
import 'widgets/privacy_tracking_dialog.dart';

import 'meta/meta_pixel_stub.dart'
    if (dart.library.html) 'meta/meta_pixel_web.dart' as meta_pixel;

/// Unified installation tracking service (consent + Firebase + Meta).
class InstallationTrackingService {
  InstallationTrackingService._();

  static final InstallationTrackingService instance =
      InstallationTrackingService._();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      if (!kIsWeb) {
        try {
          await FacebookAppEvents().activateApp();
          if (kDebugMode) {
            debugPrint(
                'Facebook App Events: App activated (attribution enabled)');
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Failed to activate Facebook App Events: $e');
          }
        }
      }

      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to initialize InstallationTrackingService: $e');
      }
    }
  }

  /// Request user consent and track installation if first install.
  Future<bool> requestConsentAndTrack(
    BuildContext context, {
    AnalyticsConfig config = const AnalyticsConfig(),
    Future<bool> Function(BuildContext)? showConsentDialog,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final consentGivenKey = config.consentGivenKey;
      final installationTrackedKey = config.installationTrackedKey;

      final consentGiven = prefs.getBool(consentGivenKey) ?? false;
      final isFirstInstall = prefs.getBool(installationTrackedKey) != true;

      if (isFirstInstall && !consentGiven) {
        if (!context.mounted) return false;
        final showDialog = showConsentDialog ?? PrivacyTrackingDialog.show;
        final userConsented = await showDialog(context);

        if (!userConsented) {
          await prefs.setBool(consentGivenKey, false);
          if (kDebugMode) {
            debugPrint('User declined tracking consent');
          }
          return false;
        }

        bool trackingEnabled = false;
        if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
          final attStatus =
              await TrackingService.instance.requestTrackingAuthorization();
          trackingEnabled = attStatus == TrackingStatus.authorized;

          if (kDebugMode) {
            debugPrint(
                'ATT status: $attStatus, tracking enabled: $trackingEnabled');
          }
        } else {
          trackingEnabled = true;
        }

        if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
          try {
            await FacebookAppEvents()
                .setAdvertiserTracking(enabled: trackingEnabled);
            if (kDebugMode) {
              debugPrint(
                  'Facebook App Events: Advertiser tracking set to $trackingEnabled');
            }
          } catch (e) {
            if (kDebugMode) {
              debugPrint('Failed to set advertiser tracking: $e');
            }
          }
        }

        await prefs.setBool(consentGivenKey, true);
        await _trackInstallation();
        await prefs.setBool(installationTrackedKey, true);

        if (kDebugMode) {
          debugPrint('Installation tracked with user consent');
        }

        return true;
      } else if (isFirstInstall && consentGiven) {
        await _trackInstallation();
        await prefs.setBool(installationTrackedKey, true);
        return true;
      } else {
        if (kDebugMode) {
          debugPrint('Installation already tracked');
        }
        return consentGiven;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to request consent and track: $e');
      }
      return false;
    }
  }

  Future<void> _trackInstallation() async {
    final platform = kIsWeb
        ? 'web'
        : (defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android');

    try {
      AnalyticsService.instance.logInstallation(platform: platform);
      if (kDebugMode) {
        debugPrint('Firebase Analytics: Installation tracked');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to track installation with Firebase Analytics: $e');
      }
    }

    if (kIsWeb) {
      try {
        meta_pixel.trackMetaPixelInstall();
        if (kDebugMode) {
          debugPrint('Meta Pixel: Installation tracked');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Failed to track installation with Meta Pixel: $e');
        }
      }
    }
  }

  Future<void> trackInstallation() async {
    await _trackInstallation();
  }
}
