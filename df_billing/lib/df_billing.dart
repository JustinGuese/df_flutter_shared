/// Subscription entitlement and checkout launching.
///
/// The state layer behind `df_paywall`, which is UI-only. This package answers
/// "is this user premium?" and "open the payment page"; df_paywall answers
/// "what does the upsell look like".
///
/// ```dart
/// // 1. Tell df_billing how to read entitlement from your backend.
/// ProviderScope(
///   overrides: [
///     dfSubscriptionFetcherProvider.overrideWithValue(
///       () => ref.read(apiProvider).subscriptionStatus(),
///     ),
///   ],
///   child: const MyApp(),
/// );
///
/// // 2. Gate content.
/// if (ref.watch(dfIsPremiumProvider)) { ... }
///
/// // 3. Open checkout.
/// final result = await DfCheckout.open(
///   url: links.url('subscription'),
///   userId: user?.uid,
///   email: user?.email,
/// );
/// if (result.failure == DfCheckoutFailure.authRequired) {
///   context.push('/register?next=/premium');
/// }
/// ```
library;

export 'src/checkout_launcher.dart';
export 'src/checkout_links.dart';
export 'src/subscription_provider.dart';
export 'src/subscription_status.dart';
