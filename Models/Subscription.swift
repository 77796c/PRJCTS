import Foundation
import SwiftData

@Model
final class Subscription {
    var id: UUID
    var name: String
    var price: Decimal
    var currency: String
    var billingPeriod: BillingPeriod
    var customBillingDays: Int?
    var nextChargeDate: Date
    var category: String
    var notes: String
    var providerURL: String?
    var isArchived: Bool
    var createdAt: Date
    var updatedAt: Date
    var reminderLeadTime: Int
    var remindersEnabled: Bool
    
    init(
        id: UUID = UUID(),
        name: String,
        price: Decimal,
        currency: String = "USD",
        billingPeriod: BillingPeriod,
        customBillingDays: Int? = nil,
        nextChargeDate: Date,
        category: String = "Other",
        notes: String = "",
        providerURL: String? = nil,
        isArchived: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        reminderLeadTime: Int = 3,
        remindersEnabled: Bool = true
    ) {
        self.id = id
        self.name = name
        self.price = price
        self.currency = currency
        self.billingPeriod = billingPeriod
        self.customBillingDays = customBillingDays
        self.nextChargeDate = nextChargeDate
        self.category = category
        self.notes = notes
        self.providerURL = providerURL
        self.isArchived = isArchived
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.reminderLeadTime = reminderLeadTime
        self.remindersEnabled = remindersEnabled
    }
    
    var monthlyCost: Decimal {
        normalizeToMonthlyCost()
    }
    
    func normalizeToMonthlyCost() -> Decimal {
        switch billingPeriod {
        case .weekly:
            return price * Decimal(52) / Decimal(12)
        case .monthly:
            return price
        case .yearly:
            return price / Decimal(12)
        case .custom:
            guard let days = customBillingDays, days > 0 else {
                return 0
            }
            let averageDaysInMonth = Decimal(30.44)
            return price * averageDaysInMonth / Decimal(days)
        }
    }
    
    func calculateNextRenewal(after date: Date = Date()) -> Date? {
        if nextChargeDate > date {
            return nextChargeDate
        }
        
        let calendar = Calendar.current
        
        switch billingPeriod {
        case .weekly:
            return calendar.date(byAdding: .day, value: 7, to: nextChargeDate)
        case .monthly:
            return calendar.date(byAdding: .month, value: 1, to: nextChargeDate)
        case .yearly:
            return calendar.date(byAdding: .year, value: 1, to: nextChargeDate)
        case .custom:
            guard let days = customBillingDays, days > 0 else {
                return nil
            }
            return calendar.date(byAdding: .day, value: days, to: nextChargeDate)
        }
    }
    
    func daysUntilRenewal(from date: Date = Date()) -> Int? {
        guard let renewal = calculateNextRenewal(after: date) else {
            return nil
        }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: date, to: renewal)
        return components.day
    }
    
    func shouldShowReminder(from date: Date = Date()) -> Bool {
        guard remindersEnabled else {
            return false
        }
        
        guard let days = daysUntilRenewal(from: date) else {
            return false
        }
        
        return days >= 0 && days <= reminderLeadTime
    }
    
    func updateNextChargeDate() {
        if let nextRenewal = calculateNextRenewal(after: Date()) {
            nextChargeDate = nextRenewal
            updatedAt = Date()
        }
    }
}
