# Subscription Tracker

A SwiftData-based subscription tracking application for iOS and macOS.

## Features

- **SwiftData Models**: Modern data persistence with SwiftData
- **Subscription Management**: Track recurring subscriptions with various billing periods
- **Cost Normalization**: Automatically calculate monthly costs across different billing cycles
- **Renewal Tracking**: Calculate upcoming renewal dates and days until next charge
- **Reminder System**: Configurable per-subscription reminders with adjustable lead times and global defaults
- **Archive Support**: Archive old or cancelled subscriptions

## Models

### Subscription

The core model for tracking subscriptions with the following properties:

- `name`: Subscription service name
- `price`: Cost per billing period
- `currency`: Currency code (default: USD)
- `billingPeriod`: Enum for billing frequency (weekly, monthly, yearly, custom)
- `customBillingDays`: Custom billing period in days (for custom billing)
- `nextChargeDate`: Date of next charge
- `category`: Subscription category (e.g., Entertainment, Productivity)
- `notes`: Additional notes
- `providerURL`: Optional URL to provider website
- `isArchived`: Archive status
- `createdAt`: Creation timestamp
- `updatedAt`: Last update timestamp
- `reminderLeadTime`: Days before renewal to show reminder
- `remindersEnabled`: Whether reminders are enabled

### BillingPeriod

Enum representing billing frequencies:
- `weekly`: Every 7 days
- `monthly`: Every 30 days
- `yearly`: Every 365 days
- `custom`: Custom number of days (specified in `customBillingDays`)

## Helper Methods

### Cost Normalization

- `normalizeToMonthlyCost()`: Converts any billing period to equivalent monthly cost
- `monthlyCost`: Computed property for monthly cost

### Renewal Calculations

- `calculateNextRenewal(after:)`: Calculate the next renewal date after a given date
- `daysUntilRenewal(from:)`: Calculate days remaining until next renewal
- `shouldShowReminder(from:)`: Determine if reminder should be shown based on lead time
- `updateNextChargeDate()`: Update the next charge date to the next renewal

## Usage

### Creating a Subscription

```swift
let subscription = Subscription(
    name: "Netflix",
    price: 15.99,
    currency: "USD",
    billingPeriod: .monthly,
    nextChargeDate: Date(),
    category: "Entertainment",
    notes: "Premium plan",
    reminderLeadTime: 3,
    remindersEnabled: true
)
```

### Calculating Monthly Cost

```swift
let monthlyCost = subscription.monthlyCost
// or
let monthlyCost = subscription.normalizeToMonthlyCost()
```

### Checking Renewal Status

```swift
if let days = subscription.daysUntilRenewal() {
    print("Renews in \(days) days")
}

if subscription.shouldShowReminder() {
    print("Reminder: Subscription renewing soon!")
}
```

## Testing

The project includes comprehensive unit tests for:
- Cost normalization across all billing periods
- Renewal date calculations
- Reminder logic
- Default values
- Edge cases (zero/nil custom billing days)

Run tests with:
```bash
swift test
```

### Notification Testing in Simulator

1. Launch the app in the iOS Simulator and open the **Settings** tab.
2. Enable **Enable renewal reminders** and, if prompted, grant notification access.
3. Adjust the default lead time if desired, then add or edit a subscription with reminders enabled.
4. Return to **Settings ▸ Pending Reminders (Debug)** and tap **Refresh Pending Reminders** to verify the scheduled notification.
5. Use **Features ▸ Trigger Notification** from the simulator menu or advance the simulator time to confirm the reminder fires on schedule.

## Requirements

- iOS 17.0+ / macOS 14.0+
- Swift 5.9+
- SwiftData

## License

MIT License
