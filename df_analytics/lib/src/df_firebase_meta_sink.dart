import 'dart:async';

import 'package:df_analytics_core/df_analytics_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

import 'meta/meta_conversion_tracking.dart';

/// Which Meta conversion an analytics event also counts as.
class DfMetaConversion {
  const DfMetaConversion(this.event, {this.contentType});

  final DfMetaEvent event;

  /// The app's own name for the action, e.g. `'diary_entry'`.
  final String? contentType;
}

/// Conversions every app reports unless it overrides them: a new account is
/// Meta's `CompleteRegistration`.
const Map<String, DfMetaConversion> dfDefaultMetaConversions = {
  DfEvents.signUp: DfMetaConversion(DfMetaEvent.completeRegistration),
};

/// Sends a Meta conversion. Matches [trackMetaConversion].
typedef DfMetaReporter =
    void Function(
      DfMetaEvent event, {
      String? contentType,
      String? registrationMethod,
    });

/// The Firebase Analytics calls [DfFirebaseMetaSink] makes — the seam tests
/// replace, since `FirebaseAnalytics.instance` needs a real Firebase app.
abstract interface class DfFirebaseCalls {
  Future<void> logEvent(String name, Map<String, Object> parameters);
  Future<void> logScreenView(String screenName, String? screenClass);
  Future<void> setUserId(String? id);
}

/// The standard sink: every event goes to Firebase Analytics (GA4); only the
/// events listed in [metaConversions] also go to Meta.
///
/// Meta is kept to conversions on purpose. Screen views and funnel steps are
/// what GA4 is for; sending them to Meta only dilutes the signal its ad
/// optimiser learns from.
class DfFirebaseMetaSink implements DfAnalyticsSink {
  DfFirebaseMetaSink({
    Map<String, DfMetaConversion> metaConversions = const {},
    this.sendUserId = false,
    @visibleForTesting DfFirebaseCalls? firebase,
    @visibleForTesting DfMetaReporter? reportMeta,
  }) : metaConversions = {...dfDefaultMetaConversions, ...metaConversions},
       _firebase = firebase ?? _FirebaseAnalyticsCalls(),
       _reportMeta = reportMeta ?? trackMetaConversion;

  /// Event name → Meta conversion, with [dfDefaultMetaConversions] underneath.
  final Map<String, DfMetaConversion> metaConversions;

  /// Whether the signed-in account id is sent to GA4 as its user id. Never sent
  /// to Meta.
  final bool sendUserId;

  final DfFirebaseCalls _firebase;
  final DfMetaReporter _reportMeta;

  @override
  void track(String name, Map<String, Object> parameters) {
    _send(name, _firebase.logEvent(name, parameters));

    final conversion = metaConversions[name];
    if (conversion == null) return;
    final method = parameters[DfEventParams.method];
    _reportMeta(
      conversion.event,
      contentType: conversion.contentType,
      registrationMethod:
          conversion.event == DfMetaEvent.completeRegistration &&
              method is String
          ? method
          : null,
    );
  }

  @override
  void screenView(String screenName, {String? screenClass}) {
    _send('screen_view', _firebase.logScreenView(screenName, screenClass));
  }

  @override
  void identify(String? userId) {
    if (!sendUserId) return;
    _send('set_user_id', _firebase.setUserId(userId));
  }

  /// Firebase calls are fire-and-forget, but their errors still need catching
  /// or they surface as unhandled async exceptions.
  void _send(String label, Future<void> call) {
    unawaited(
      call.catchError((Object e) {
        if (kDebugMode) debugPrint('[analytics] $label failed: $e');
      }),
    );
  }
}

class _FirebaseAnalyticsCalls implements DfFirebaseCalls {
  FirebaseAnalytics get _analytics => FirebaseAnalytics.instance;

  @override
  Future<void> logEvent(String name, Map<String, Object> parameters) =>
      _analytics.logEvent(name: name, parameters: parameters);

  @override
  Future<void> logScreenView(String screenName, String? screenClass) =>
      _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      );

  @override
  Future<void> setUserId(String? id) => _analytics.setUserId(id: id);
}
