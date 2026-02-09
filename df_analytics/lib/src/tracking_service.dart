import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform, kDebugMode, debugPrint;

/// Service for handling App Tracking Transparency (ATT) on iOS.
class TrackingService {
  TrackingService._();

  static final TrackingService instance = TrackingService._();

  bool get isAvailable {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) return false;
    return true;
  }

  Future<TrackingStatus?> requestTrackingAuthorization() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) {
      if (kDebugMode) {
        debugPrint('ATT is iOS-only, skipping on non-iOS platform');
      }
      return null;
    }

    try {
      final status = await AppTrackingTransparency.requestTrackingAuthorization();
      if (kDebugMode) {
        debugPrint('ATT status: $status');
      }
      return status;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to request ATT: $e');
      }
      return null;
    }
  }

  Future<TrackingStatus?> getTrackingStatus() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) {
      return null;
    }

    try {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      return status;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to get ATT status: $e');
      }
      return null;
    }
  }

  Future<String?> getAdvertisingIdentifier() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) {
      return null;
    }

    try {
      final idfa = await AppTrackingTransparency.getAdvertisingIdentifier();
      return idfa;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to get IDFA: $e');
      }
      return null;
    }
  }
}
