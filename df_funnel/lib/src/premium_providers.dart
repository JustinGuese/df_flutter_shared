import 'dart:async';

import 'package:df_billing/df_billing.dart';
import 'package:df_firebase_auth/df_firebase_auth.dart';
import 'package:df_revenuecat/df_revenuecat.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Callback invoked when auth/RevenueCat synchronization completes on sign-in.
typedef DfAuthSyncCallback = FutureOr<void> Function();

/// Combines RevenueCat Pro and backend subscriptions into a single premium state.
///
/// Entitlement is unlocked if:
/// - RevenueCat reports Pro (valid for anonymous or authenticated users)
/// - OR user is signed in AND app backend subscription reports premium.
///
/// If signed out, backend subscription status is ignored and returns false.
final dfEffectivePremiumProvider = Provider<bool>((ref) {
  final rcPro = ref.watch(dfRevenueCatIsProProvider);
  if (rcPro) return true;
  final user = ref.watch(currentUserProvider);
  if (user == null) return false;
  return ref.watch(dfIsPremiumProvider);
});

/// Seam for delegating RevenueCat operations during auth sync.
///
/// By default, delegates to static methods on [DfRevenueCat]. Can be overridden
/// in tests via [dfRevenueCatAuthSyncHandlerProvider].
class DfRevenueCatAuthSyncHandler {
  const DfRevenueCatAuthSyncHandler();

  /// Identifies the user in RevenueCat.
  Future<void> logIn(String uid) => DfRevenueCat.logIn(uid);

  /// Checks whether the user has active Pro entitlement.
  Future<bool> isPro() => DfRevenueCat.isPro();

  /// Restores previous purchases.
  Future<bool> restore() => DfRevenueCat.restore();

  /// Logs out of RevenueCat.
  Future<void> logOut() => DfRevenueCat.logOut();
}

/// Provider supplying the [DfRevenueCatAuthSyncHandler], overridable in tests.
final dfRevenueCatAuthSyncHandlerProvider =
    Provider<DfRevenueCatAuthSyncHandler>((ref) {
  return const DfRevenueCatAuthSyncHandler();
});

void _setupAuthRevenueCatSync(
  Ref ref,
  DfAuthSyncCallback? onSynced,
) {
  final handler = ref.watch(dfRevenueCatAuthSyncHandlerProvider);

  ref.listen<AsyncValue<User?>>(
    authStateChangesProvider,
    (previous, next) async {
      if (next.isLoading) return;

      final prevUser = previous?.value;
      final nextUser = next.value;

      if (nextUser != null) {
        if (prevUser?.uid != nextUser.uid) {
          await handler.logIn(nextUser.uid);
          final pro = await handler.isPro();
          if (!pro) {
            await handler.restore();
          }
          ref.invalidate(dfSubscriptionProvider);
          if (onSynced != null) {
            await onSynced();
          }
        }
      } else if (prevUser != null) {
        await handler.logOut();
        try {
          await ref.read(dfSubscriptionProvider.notifier).clearCache();
        } catch (_) {}
        try {
          ref.read(dfDebugPremiumOverrideProvider.notifier).set(null);
        } catch (_) {}
        ref.invalidate(dfSubscriptionProvider);
      }
    },
    fireImmediately: true,
  );
}

final _dfAuthRevenueCatSyncFamily =
    Provider.family<void, DfAuthSyncCallback?>((ref, onSynced) {
  _setupAuthRevenueCatSync(ref, onSynced);
});

/// Family provider for auth/RevenueCat synchronization.
final dfAuthRevenueCatSyncFamily = _dfAuthRevenueCatSyncFamily;

/// Synchronizes Firebase Auth changes with RevenueCat and backend subscriptions.
///
/// On sign-in:
/// - identifies the user with RevenueCat (`logIn(uid)`)
/// - restores purchases if not pro
/// - invalidates [dfSubscriptionProvider]
/// - calls [onSynced] once
///
/// On sign-out:
/// - logs out of RevenueCat (`logOut()`)
/// - clears cached subscription status and resets debug override
/// - invalidates [dfSubscriptionProvider]
Provider<void> dfAuthRevenueCatSyncProvider({DfAuthSyncCallback? onSynced}) {
  return _dfAuthRevenueCatSyncFamily(onSynced);
}
