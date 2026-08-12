import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'subscription_status.dart';

/// Fetches entitlement from the app's own backend.
///
/// The app supplies this — df_billing does not know your API. Throw on failure;
/// [DfSubscriptionNotifier] decides what a failure means.
typedef DfSubscriptionFetcher = Future<DfSubscriptionStatus> Function();

/// Must be overridden by the app.
final dfSubscriptionFetcherProvider = Provider<DfSubscriptionFetcher>((ref) {
  throw UnimplementedError(
    'Override dfSubscriptionFetcherProvider with a call to your entitlement '
    'endpoint, e.g. () => ref.read(apiProvider).getSubscriptionStatus().',
  );
});

/// Forces premium on or off, bypassing the backend. Null uses the real status.
///
/// For demos and for local work on premium screens without a live Stripe
/// account. Never set this from anything but debug UI.
final dfDebugPremiumOverrideProvider =
    NotifierProvider<DfDebugPremiumOverride, bool?>(DfDebugPremiumOverride.new);

class DfDebugPremiumOverride extends Notifier<bool?> {
  @override
  bool? build() => null;

  // ignore: use_setters_to_change_properties
  void set(bool? value) => state = value;
}

/// True when premium content should be unlocked.
///
/// The one thing feature code should read. While the status is still loading
/// this reports the last known value rather than false, so a paying user does
/// not see a paywall flash on every cold start.
final dfIsPremiumProvider = Provider<bool>((ref) {
  final override = ref.watch(dfDebugPremiumOverrideProvider);
  if (override != null) return override;
  final async = ref.watch(dfSubscriptionProvider);
  return async.value?.isPremium ?? false;
});

final dfSubscriptionProvider =
    AsyncNotifierProvider<DfSubscriptionNotifier, DfSubscriptionStatus>(
      DfSubscriptionNotifier.new,
    );

/// Entitlement state, cached across launches and refreshed on resume.
///
/// Refreshing on resume is what makes the hosted-checkout flow work: the user
/// leaves for a Stripe page in an external browser and comes back, and their
/// new subscription has to be visible without a manual reload.
class DfSubscriptionNotifier extends AsyncNotifier<DfSubscriptionStatus>
    with WidgetsBindingObserver {
  static const _cacheKey = 'df_billing_last_status_v1';

  DfSubscriptionStatus? _lastKnown;

  @override
  Future<DfSubscriptionStatus> build() async {
    WidgetsBinding.instance.addObserver(this);
    ref.onDispose(() => WidgetsBinding.instance.removeObserver(this));

    _lastKnown = await _readCache();
    return _fetch();
  }

  Future<DfSubscriptionStatus> _fetch() async {
    final override = ref.read(dfDebugPremiumOverrideProvider);
    if (override != null) {
      return override
          ? DfSubscriptionStatus(
              status: 'active',
              isPremium: true,
              currentPeriodEnd: DateTime.now().add(const Duration(days: 30)),
            )
          : const DfSubscriptionStatus.free();
    }

    try {
      final status = await ref.read(dfSubscriptionFetcherProvider)();
      _lastKnown = status;
      await _writeCache(status);
      return status;
    } catch (_) {
      // Keep the last known entitlement instead of dropping to free.
      //
      // Downgrading on a network blip locks paying users out of content they
      // have already bought — the failure mode that actually generates support
      // mail. The backend remains the authority; this only covers the window
      // where it is unreachable. With no cached value we do fall back to free,
      // since granting premium to an unknown user is the worse error.
      return _lastKnown ?? const DfSubscriptionStatus.free();
    }
  }

  Future<DfSubscriptionStatus?> _readCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw == null) return null;
      return DfSubscriptionStatus.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeCache(DfSubscriptionStatus status) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonEncode(status.toJson()));
    } catch (_) {
      // A cache write failing must not fail the entitlement check.
    }
  }

  /// Re-reads entitlement, keeping the current value visible while it loads.
  ///
  /// Deliberately does not flip to `AsyncLoading` first. This runs on every
  /// app resume, and emitting a loading state would blank the premium UI for a
  /// frame each time the user switches back to the app.
  Future<void> refresh() async {
    state = await AsyncValue.guard(_fetch);
  }

  /// Clears the cached entitlement. Call on sign-out, or the next user on this
  /// device inherits the previous one's premium status.
  Future<void> clearCache() async {
    _lastKnown = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
    } catch (_) {
      // Best effort.
    }
  }

  @override
  // Named `lifecycle` rather than the inherited `state`, which would shadow
  // this notifier's own `state` field inside the method body.
  // ignore: avoid_renaming_method_parameters
  void didChangeAppLifecycleState(AppLifecycleState lifecycle) {
    if (lifecycle == AppLifecycleState.resumed) {
      unawaited(refresh());
    }
  }
}
