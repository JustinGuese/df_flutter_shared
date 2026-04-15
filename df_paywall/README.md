# df_paywall

Generic subscription paywall UI for Flutter apps. Pure UI package — no Stripe SDK, no Riverpod, no app-specific logic. You wire in your own checkout callbacks; the widgets handle the visuals, loading states, and copy.

Used by [DataFortress.cloud](https://datafortress.cloud/) apps.

---

## Installation

```yaml
dependencies:
  df_paywall:
    path: ../df_paywall  # or git source
```

```dart
import 'package:df_paywall/df_paywall.dart';
```

---

## Design philosophy

All copy, colors, and branding are injected via `PaywallConfig` — the widgets are fully generic. The app layer creates one `PaywallConfig` constant and thin wrapper widgets that call the actual payment service. This keeps `df_paywall` reusable across apps without modification.

---

## Quick start

**1. Define your config** (one per app):

```dart
const kMyAppPaywallConfig = PaywallConfig(
  productName: 'MyApp Plus',
  heroEmoji: '⭐',
  trialHeadline: '7 Tage kostenlos testen',
  priceLabel: '9,99 €/Monat',
  cancellationNote: 'Jederzeit kündbar',
  features: [
    'Alle Premium-Inhalte freigeschaltet',
    'Personalisierte Empfehlungen',
    'Unbegrenzter Verlauf',
    'Neue Inhalte automatisch inklusive',
  ],
  credibilityText: 'Entwickelt nach aktuellen Qualitätsstandards',
  ctaText: 'Jetzt kostenlos starten →',
  dismissText: 'Später entscheiden',
  gradient: [Color(0xFF0E6B82), Color(0xFF0C445A)],
  accentColor: Color(0xFF0E6B82),
);
```

**2. Create app-side thin wrappers** that inject your payment service:

```dart
// my_app/lib/features/subscription/widgets/my_upsell_sheet.dart
void showMyUpsellSheet(BuildContext context, {String? targetItem, required WidgetRef ref}) {
  showPaywallUpsellSheet(
    context,
    config: kMyAppPaywallConfig,
    targetCourse: targetItem,
    onCta: (item) async {
      final url = await ref.read(subscriptionServiceProvider).createCheckoutSession(targetCourse: item);
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    },
  );
}
```

---

## API reference

### `PaywallConfig`

Immutable configuration class. Create one `const` instance per app and pass it everywhere.

| Field | Type | Description |
|-------|------|-------------|
| `productName` | `String` | Product name in headings, e.g. `"NaviCare Plus"` |
| `heroEmoji` | `String` | Emoji shown in gradient hero circle, e.g. `"⭐"` |
| `trialHeadline` | `String` | Subheading under product name, e.g. `"7 Tage kostenlos testen"` |
| `priceLabel` | `String` | Price string, e.g. `"9,99 €/Monat"` |
| `cancellationNote` | `String` | Shown next to price, e.g. `"Jederzeit kündbar"` |
| `features` | `List<String>` | Bullet feature rows in the feature list |
| `credibilityText` | `String` | Small text below features — use verifiable claims, not fake numbers |
| `ctaText` | `String` | CTA button label (default: `"Jetzt kostenlos starten →"`) |
| `dismissText` | `String` | Dismiss link label — keep neutral (default: `"Später entscheiden"`) |
| `gradient` | `List<Color>` | Hero gradient colors (default: DataFortress teal) |
| `accentColor` | `Color` | Checkmarks, buttons, badges (default: `Color(0xFF0E6B82)`) |

---

### `PaywallSubscriptionInfo`

Describes the user's current subscription state. Pass to `PaywallPremiumScreen`.

```dart
PaywallSubscriptionInfo(
  status: 'trialing',           // "free" | "trialing" | "active" | "past_due" | "canceled"
  isPremium: true,              // trialing or active
  currentPeriodEnd: DateTime(...),
  trialEnd: DateTime(...),
)

// Convenience constructor for unauthenticated / error states:
const PaywallSubscriptionInfo.free()
```

**Computed properties:**

| Property | Type | Description |
|----------|------|-------------|
| `isPremium` | `bool` | `true` when status is `trialing` or `active` |
| `isTrialing` | `bool` | `true` when status is `trialing` |
| `trialDaysRemaining` | `int?` | Days until trial ends; `null` if not trialing |

---

### `showPaywallUpsellSheet`

Modal bottom sheet upsell. Triggered at high-intent moments (e.g. after completing a free sample, from an assessment result screen).

```dart
showPaywallUpsellSheet(
  context,
  config: kMyAppPaywallConfig,
  targetCourse: 'course-key',   // optional — forwarded to onCta for deep-link return
  onCta: (targetCourse) async {
    final url = await checkoutService.createSession(targetCourse: targetCourse);
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  },
);
```

**Behaviour:**
- CTA shows a loading spinner while `onCta` runs (prevents double-tap)
- Errors from `onCta` are surfaced as a `SnackBar`
- Dismiss button uses `cfg.dismissText` — neutral copy, no guilt

---

### `PaywallUpsellInline`

Inline widget shown *in place of* locked content (e.g. inside a step viewer). Does not pop or navigate — renders directly as a child.

```dart
PaywallUpsellInline(
  stepTitle: 'Bei Risiko — Professionelle Maßnahmen',
  stepEmoji: '🩺',
  config: kMyAppPaywallConfig,
  onCta: () async {
    final url = await checkoutService.createSession();
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  },
);
```

**Shows:**
- Step preview (emoji + title + 3 blurred placeholder content bars)
- Lock label + first 3 features from config
- CTA button with loading state

Use this as the `stepGateBuilder` return value in `LearningCourseScreen` (from `df_onboarding`):

```dart
LearningCourseScreen(
  course: course,
  stepGateBuilder: (stepIndex) {
    if (stepIndex == 0 || isPremium) return null;
    return MyUpsellInline(
      stepTitle: course.steps[stepIndex].title,
      stepEmoji: course.steps[stepIndex].emoji,
    );
  },
)
```

---

### `PaywallPremiumScreen`

Full-page screen for `/premium` route. Renders two layouts based on `subscriptionInfo.isPremium`:

**Not premium** — upsell layout: hero gradient, price card, feature card, CTA button.

**Premium** — membership view: confirmation header, optional trial countdown, "Manage subscription" button (for Stripe Billing Portal, invoice downloads, cancellation).

```dart
PaywallPremiumScreen(
  config: kMyAppPaywallConfig,
  subscriptionInfo: PaywallSubscriptionInfo(
    status: userStatus,
    isPremium: userIsPremium,
    currentPeriodEnd: periodEnd,
    trialEnd: trialEnd,
  ),
  onUpgrade: () async {
    final url = await checkoutService.createSession();
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  },
  onManageSubscription: () async {        // optional — hide button if null
    final url = await checkoutService.createPortalSession();
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  },
)
```

---

## Integration pattern

```
df_paywall (generic UI, this package)
    ↓ injected via onCta callbacks
app layer thin wrappers (wire Riverpod + payment service)
    ↓ consumed by
feature screens (course viewer, assessment results, settings)
```

The app layer creates:
- `kMyAppPaywallConfig` — one const with all copy
- `showMyUpsellSheet(context, {ref})` — calls `showPaywallUpsellSheet` with Stripe callback
- `MyUpsellInline({stepTitle, stepEmoji, moduleKey})` — calls `PaywallUpsellInline` with Stripe callback
- `MyPremiumScreen` — calls `PaywallPremiumScreen` with Stripe callbacks and Riverpod subscription state

`df_paywall` itself has **no Riverpod, no Stripe, no platform channel** dependencies — only the Flutter SDK.

---

## Copy guidelines (apply in all apps)

- **Never guilt-trip on dismiss**: use `"Später entscheiden"` not `"Nein danke, ich bleibe kostenlos"`
- **Lead with the trial**: always "7 Tage kostenlos" before the price
- **No fake social proof**: use verifiable claims in `credibilityText` (standards references, not user counts)
- **Neutral dismiss**: `dismissText` should never imply the user is making a mistake
