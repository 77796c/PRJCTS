import Foundation
import SwiftData

@MainActor
struct PreviewData {
    static var container: ModelContainer = {
        let schema = Schema([
            Subscription.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

        do {
            let container = try ModelContainer(for: schema, configurations: [configuration])
            let context = container.mainContext
            let calendar = Calendar.current
            let today = Date()

            let subscriptions: [Subscription] = [
                Subscription(
                    name: "Netflix",
                    price: 15.99,
                    currency: "USD",
                    billingPeriod: .monthly,
                    nextChargeDate: calendar.date(byAdding: .day, value: 5, to: today)!,
                    category: "Entertainment",
                    notes: "Premium plan with 4K streaming"
                ),
                Subscription(
                    name: "Spotify",
                    price: 9.99,
                    currency: "USD",
                    billingPeriod: .monthly,
                    nextChargeDate: calendar.date(byAdding: .day, value: 10, to: today)!,
                    category: "Entertainment",
                    notes: "Individual premium plan"
                ),
                Subscription(
                    name: "Adobe Creative Cloud",
                    price: 54.99,
                    currency: "USD",
                    billingPeriod: .monthly,
                    nextChargeDate: calendar.date(byAdding: .day, value: 15, to: today)!,
                    category: "Productivity"
                ),
                Subscription(
                    name: "Amazon Prime",
                    price: 139.0,
                    currency: "USD",
                    billingPeriod: .yearly,
                    nextChargeDate: calendar.date(byAdding: .day, value: 45, to: today)!,
                    category: "Shopping"
                ),
                Subscription(
                    name: "Gym Membership",
                    price: 15.0,
                    currency: "USD",
                    billingPeriod: .weekly,
                    nextChargeDate: calendar.date(byAdding: .day, value: 2, to: today)!,
                    category: "Health"
                ),
                Subscription(
                    name: "Design Toolkit",
                    price: 29.99,
                    currency: "USD",
                    billingPeriod: .custom,
                    customBillingDays: 45,
                    nextChargeDate: calendar.date(byAdding: .day, value: 18, to: today)!,
                    category: "Productivity"
                ),
                Subscription(
                    name: "Deprecated Service",
                    price: 5.99,
                    currency: "USD",
                    billingPeriod: .monthly,
                    nextChargeDate: calendar.date(byAdding: .day, value: 12, to: today)!,
                    category: "Other",
                    isArchived: true
                )
            ]

            subscriptions.forEach(context.insert)
            try context.save()
            return container
        } catch {
            fatalError("Failed to create preview container: \(error)")
        }
    }()

    static var sampleSubscriptions: [Subscription] {
        let calendar = Calendar.current
        let today = Date()

        return [
            Subscription(
                name: "Netflix",
                price: 15.99,
                currency: "USD",
                billingPeriod: .monthly,
                nextChargeDate: calendar.date(byAdding: .day, value: 5, to: today)!,
                category: "Entertainment"
            ),
            Subscription(
                name: "Spotify",
                price: 9.99,
                currency: "USD",
                billingPeriod: .monthly,
                nextChargeDate: calendar.date(byAdding: .day, value: 10, to: today)!,
                category: "Entertainment"
            ),
            Subscription(
                name: "Amazon Prime",
                price: 139.0,
                currency: "USD",
                billingPeriod: .yearly,
                nextChargeDate: calendar.date(byAdding: .day, value: 90, to: today)!,
                category: "Shopping"
            )
        ]
    }
}
