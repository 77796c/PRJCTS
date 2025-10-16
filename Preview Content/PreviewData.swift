import Foundation
import SwiftData

@MainActor
struct PreviewData {
    static var container: ModelContainer = {
        let schema = Schema([
            Subscription.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        
        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            let context = container.mainContext
            
            let calendar = Calendar.current
            let today = Date()
            
            let netflix = Subscription(
                name: "Netflix",
                price: 15.99,
                currency: "USD",
                billingPeriod: .monthly,
                nextChargeDate: calendar.date(byAdding: .day, value: 5, to: today)!,
                category: "Entertainment",
                notes: "Premium plan with 4K streaming",
                providerURL: "https://netflix.com",
                reminderLeadTime: 3,
                remindersEnabled: true
            )
            
            let spotify = Subscription(
                name: "Spotify",
                price: 9.99,
                currency: "USD",
                billingPeriod: .monthly,
                nextChargeDate: calendar.date(byAdding: .day, value: 10, to: today)!,
                category: "Entertainment",
                notes: "Individual premium plan",
                providerURL: "https://spotify.com",
                reminderLeadTime: 3,
                remindersEnabled: true
            )
            
            let adobeCreativeCloud = Subscription(
                name: "Adobe Creative Cloud",
                price: 52.99,
                currency: "USD",
                billingPeriod: .monthly,
                nextChargeDate: calendar.date(byAdding: .day, value: 15, to: today)!,
                category: "Productivity",
                notes: "All apps subscription",
                providerURL: "https://adobe.com",
                reminderLeadTime: 5,
                remindersEnabled: true
            )
            
            let amazonPrime = Subscription(
                name: "Amazon Prime",
                price: 139.00,
                currency: "USD",
                billingPeriod: .yearly,
                nextChargeDate: calendar.date(byAdding: .day, value: 90, to: today)!,
                category: "Shopping",
                notes: "Free shipping and Prime Video",
                providerURL: "https://amazon.com/prime",
                reminderLeadTime: 7,
                remindersEnabled: true
            )
            
            let gymMembership = Subscription(
                name: "Gym Membership",
                price: 15.00,
                currency: "USD",
                billingPeriod: .weekly,
                nextChargeDate: calendar.date(byAdding: .day, value: 3, to: today)!,
                category: "Health",
                notes: "Local gym subscription",
                reminderLeadTime: 2,
                remindersEnabled: true
            )
            
            let customService = Subscription(
                name: "Custom Service",
                price: 29.99,
                currency: "USD",
                billingPeriod: .custom,
                customBillingDays: 45,
                nextChargeDate: calendar.date(byAdding: .day, value: 20, to: today)!,
                category: "Other",
                notes: "Billed every 45 days",
                reminderLeadTime: 5,
                remindersEnabled: true
            )
            
            let archivedService = Subscription(
                name: "Old Service",
                price: 5.99,
                currency: "USD",
                billingPeriod: .monthly,
                nextChargeDate: calendar.date(byAdding: .day, value: 30, to: today)!,
                category: "Other",
                notes: "Cancelled subscription",
                isArchived: true,
                reminderLeadTime: 3,
                remindersEnabled: false
            )
            
            context.insert(netflix)
            context.insert(spotify)
            context.insert(adobeCreativeCloud)
            context.insert(amazonPrime)
            context.insert(gymMembership)
            context.insert(customService)
            context.insert(archivedService)
            
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
                price: 139.00,
                currency: "USD",
                billingPeriod: .yearly,
                nextChargeDate: calendar.date(byAdding: .day, value: 90, to: today)!,
                category: "Shopping"
            )
        ]
    }
}
