# df_funnel

Cohesive onboarding, paywall, and auth funnel with unified premium state.

`df_funnel` coordinates the user journey from first launch to conversion:
- Launch funnel: onboarding carousel, paywall presentation, and sign-in gates.
- Unified premium state across RevenueCat and backend entitlement.
- UI components: locked content overlays, upsell sheets, and prompt interruptions.

## Install

```yaml
dependencies:
  df_funnel:
    git:
      url: https://github.com/JustinGuese/df_flutter_shared.git
      path: df_funnel
      ref: main
```

## Contracts

### `DfFunnelStep`
Ordered steps in the launch flow:
- `onboarding`: Welcome carousel or introductory walk-through.
- `paywall`: Subscription offering screen.
- `login`: User authentication / account recovery.

### `DfLoginMode`
Specifies how authentication is enforced during launch:
- `required`: Blocks navigation until the user is signed in.
- `optional`: Shows sign-in screen with an explicit skip option.
- `deferred`: Skips authentication at launch; auth is triggered only when accessing gated features.

### `DfFunnelConfig`
Controls step ordering, persistence keys, and placement strings. Also provides seams (`paywallPresenter`, `entitlementReader`) for testing and customization.
