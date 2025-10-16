# Subuddy

This repository hosts the Subuddy sample application that demonstrates integrating a non-consumable StoreKit 2 product to unlock an ad-free experience.

## Features

- StoreKit configuration file prepared for local testing with a non-consumable `com.subuddy.adfree` product priced at $2.99 USD.
- `StoreKitManager` built on StoreKit 2 to request products, perform purchases, and restore transactions.
- Entitlement state persisted across launches using an `EntitlementStore` abstraction that defaults to `UserDefaults`.
- SwiftUI banner placeholder that is hidden as soon as the entitlement is detected.
- Settings entry points to purchase or restore the ad-free experience.

## Testing

### Unit Tests

A focused unit test suite is located under `Tests/SubuddyCoreTests`. The tests cover entitlement persistence through the `UserDefaultsEntitlementStore`. Run the suite with:

```
swift test
```

You can also attach the Swift package to an Xcode workspace and execute the `SubuddyCoreTests` bundle on an iOS 16+ simulator.

### Manual QA

1. Launch the Subuddy app with the "Subuddy.storekit" configuration (App/StoreKit/Subuddy.storekit) active.
2. Confirm the banner placeholder is visible on first launch.
3. Tap **Remove Ads** on the banner and follow the simulated purchase flow; the banner should disappear immediately.
4. Remove and reinstall the app or relaunch the simulator to verify the ad-free state persists.
5. Use the Settings screen to invoke **Restore Purchases** and ensure entitlements are reapplied if needed.

### Local StoreKit Testing

1. In Xcode, select **Product ▸ Scheme ▸ Edit Scheme…** and enable the StoreKit configuration.
2. Add `App/StoreKit/Subuddy.storekit` to the scheme's **Run ▸ Options** tab.
3. Use **Debug ▸ StoreKit ▸ Manage Transactions…** to inspect and reset the simulated purchase state.

## Notes

The StoreKit integration employs best-effort transaction verification for local testing. In production, replace the inline verification helper with a full receipt validation implementation backed by App Store server APIs.
