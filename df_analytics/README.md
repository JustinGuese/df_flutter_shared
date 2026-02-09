# df_analytics

Reusable Flutter package for analytics: Firebase Analytics, App Tracking Transparency, Meta conversion tracking, and installation/consent flow. Used in apps by [DataFortress.cloud](https://datafortress.cloud/).

## Usage

Add path dependency and override `analyticsConfigProvider` if needed. Use `AnalyticsService.instance` for generic events and `logEventWithMeta` for events that also trigger Meta tracking. Use `InstallationTrackingService.instance.requestConsentAndTrack(context)` after onboarding.
