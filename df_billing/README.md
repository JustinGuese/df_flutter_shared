# df_billing

Subscription entitlement and checkout launching — the state layer behind
[`df_paywall`](../df_paywall), which is UI-only.

`df_billing` answers *"is this user premium?"* and *"open the payment page"*.
`df_paywall` answers *"what does the upsell look like"*.

No Stripe SDK. Every DF app bills through hosted Payment Links plus a backend
webhook, so the client only ever needs to open a URL — which also keeps this
package working on web and desktop.

## Install

```yaml
dependencies:
  df_billing:
    git:
      url: https://github.com/JustinGuese/df_flutter_shared.git
      path: df_billing
      ref: main
```

## Use

**1. Tell it how to read entitlement from your backend.**

```dart
ProviderScope(
  overrides: [
    dfSubscriptionFetcherProvider.overrideWithValue(
      () => ref.read(apiProvider).subscriptionStatus(),
    ),
  ],
  child: const MyApp(),
);
```

**2. Gate content.**

```dart
if (ref.watch(dfIsPremiumProvider)) ...
```

**3. Open checkout.**

```dart
const links = DfCheckoutLinks(
  live: {'subscription': 'https://buy.stripe.com/…'},
  test: {'subscription': 'https://buy.stripe.com/test_…'},
);

final result = await DfCheckout.open(
  url: links.url('subscription'),
  userId: user?.uid,
  email: user?.email,
);

switch (result.failure) {
  case DfCheckoutFailure.authRequired:
    context.push('/register?next=/premium');
  case DfCheckoutFailure.notConfigured:
  case DfCheckoutFailure.launchFailed:
    DfSnackbar.error(context, 'Could not open the payment page.');
  case null:
    break;
}
```

`DfCheckout` returns a result rather than showing anything itself, so copy and
navigation stay in the app.

## Behaviour worth knowing

**Entitlement is cached and survives an outage.** If the backend is unreachable,
the last known status is kept rather than dropping to free. Downgrading on a
network blip locks paying users out of content they already bought. With no
cached value it does fall back to free — granting premium to an unknown user is
the worse error. Call `clearCache()` on sign-out, or the next person on that
device inherits the previous user's entitlement.

**Status refreshes on app resume.** That is what makes hosted checkout work: the
user leaves for Stripe in an external browser and comes back, and their new
subscription has to appear without a manual reload.

**Checkout requires a user id.** It is encoded as `client_reference_id`
(`<uid>|<productSlug>`) so the webhook can attribute the payment. Without one,
`open` returns `authRequired` instead of opening an unattributable checkout —
taking money the backend cannot match to a user is worse than not taking it.

**Test vs live** is chosen by, in order: `--dart-define=USE_BILLING=test|live`,
then your `isTestEnvironment` callback (typically a staging-host check), then
`kDebugMode`. That last fallback matters — an earlier hand-rolled version keyed
only off the hostname, so debug builds on localhost silently pointed at live
Stripe.
