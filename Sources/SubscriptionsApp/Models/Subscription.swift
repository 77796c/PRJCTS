#if canImport(SwiftData)
import Foundation
import SwiftData

@Model
public final class Subscription {
    public enum BillingPeriod: Codable, Hashable, Sendable {
        case weekly
        case monthly
        case yearly
        case custom(days: Int)

        private enum CodingKeys: CodingKey {
            case type
            case days
        }

        private enum Kind: String, Codable {
            case weekly
            case monthly
            case yearly
            case custom
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let kind = try container.decode(Kind.self, forKey: .type)

            switch kind {
            case .weekly:
                self = .weekly
            case .monthly:
                self = .monthly
            case .yearly:
                self = .yearly
            case .custom:
                let days = try container.decode(Int.self, forKey: .days)
                self = .custom(days: max(1, days))
            }
        }

        public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)

            switch self {
            case .weekly:
                try container.encode(Kind.weekly, forKey: .type)
            case .monthly:
                try container.encode(Kind.monthly, forKey: .type)
            case .yearly:
                try container.encode(Kind.yearly, forKey: .type)
            case .custom(let days):
                try container.encode(Kind.custom, forKey: .type)
                try container.encode(max(1, days), forKey: .days)
            }
        }

        public var displayName: String {
            switch self {
            case .weekly:
                return "Weekly"
            case .monthly:
                return "Monthly"
            case .yearly:
                return "Yearly"
            case .custom(let days):
                return "Every \(days) days"
            }
        }

        public func approximateDays(averageDaysInMonth: Double = Subscription.averageDaysInMonth) -> Double {
            switch self {
            case .weekly:
                return 7
            case .monthly:
                return averageDaysInMonth
            case .yearly:
                return 365.25
            case .custom(let days):
                return max(Double(days), 1)
            }
        }

        public func monthlyCostMultiplier(averageDaysInMonth: Double = Subscription.averageDaysInMonth) -> Double {
            let periodDays = max(1, approximateDays(averageDaysInMonth: averageDaysInMonth))
            return averageDaysInMonth / periodDays
        }

        public func advance(date: Date, calendar: Calendar = .current) -> Date {
            switch self {
            case .weekly:
                return calendar.date(byAdding: .weekOfYear, value: 1, to: date) ?? date
            case .monthly:
                return calendar.date(byAdding: .month, value: 1, to: date) ?? date
            case .yearly:
                return calendar.date(byAdding: .year, value: 1, to: date) ?? date
            case .custom(let days):
                let clampedDays = max(days, 1)
                return calendar.date(byAdding: .day, value: clampedDays, to: date) ?? date
            }
        }
    }

    public static let averageDaysInMonth: Double = 30.4375
    public static let defaultReminderLeadTime: TimeInterval = 24 * 60 * 60

    public var name: String
    public var price: Decimal
    public var currency: String
    public var billingPeriod: BillingPeriod
    public var nextChargeDate: Date
    public var category: String?
    public var notes: String?
    public var providerURL: URL?
    public var isArchived: Bool
    public var createdAt: Date
    public var updatedAt: Date
    public var reminderLeadTime: TimeInterval
    public var remindersEnabled: Bool

    public init(
        name: String,
        price: Decimal,
        currency: String = "USD",
        billingPeriod: BillingPeriod,
        nextChargeDate: Date,
        category: String? = nil,
        notes: String? = nil,
        providerURL: URL? = nil,
        isArchived: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        reminderLeadTime: TimeInterval = Subscription.defaultReminderLeadTime,
        remindersEnabled: Bool = false
    ) {
        self.name = name
        self.price = price
        self.currency = currency.uppercased()
        self.billingPeriod = billingPeriod
        self.nextChargeDate = nextChargeDate
        self.category = category
        self.notes = notes
        self.providerURL = providerURL
        self.isArchived = isArchived
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.reminderLeadTime = max(0, reminderLeadTime)
        self.remindersEnabled = remindersEnabled
    }
}

public extension Subscription {
    func normalizedMonthlyCost(averageDaysInMonth: Double = Subscription.averageDaysInMonth) -> Decimal {
        let multiplier = billingPeriod.monthlyCostMultiplier(averageDaysInMonth: averageDaysInMonth)
        return price.scaled(by: multiplier)
    }

    func upcomingRenewal(after referenceDate: Date = Date(), calendar: Calendar = .current) -> Date {
        guard referenceDate > nextChargeDate else {
            return nextChargeDate
        }

        var candidate = nextChargeDate
        let maxIterations = 10_000

        for _ in 0..<maxIterations {
            let advanced = billingPeriod.advance(date: candidate, calendar: calendar)
            if advanced > referenceDate {
                return advanced
            }
            candidate = advanced
        }

        return candidate
    }

    func reminderTriggerDate(from referenceDate: Date = Date(), calendar: Calendar = .current) -> Date? {
        guard remindersEnabled else { return nil }
        let renewalDate = upcomingRenewal(after: referenceDate, calendar: calendar)
        return calendar.date(byAdding: .second, value: -Int(reminderLeadTime), to: renewalDate)
    }

    static func sampleData(referenceDate: Date = Date(), calendar: Calendar = .current) -> [Subscription] {
        let safeCalendar = calendar

        return [
            Subscription(
                name: "Music Plus",
                price: 9.99,
                currency: "USD",
                billingPeriod: .monthly,
                nextChargeDate: safeCalendar.date(byAdding: .day, value: 5, to: referenceDate) ?? referenceDate,
                category: "Entertainment",
                notes: "Family plan",
                providerURL: URL(string: "https://music.example.com"),
                remindersEnabled: true
            ),
            Subscription(
                name: "Cloud Storage",
                price: 99.0,
                currency: "USD",
                billingPeriod: .yearly,
                nextChargeDate: safeCalendar.date(byAdding: .month, value: 9, to: referenceDate) ?? referenceDate,
                category: "Productivity",
                notes: "1 TB tier",
                providerURL: URL(string: "https://cloud-storage.example.com"),
                reminderLeadTime: 7 * 24 * 60 * 60,
                remindersEnabled: true
            ),
            Subscription(
                name: "Gym Membership",
                price: 15.0,
                currency: "EUR",
                billingPeriod: .weekly,
                nextChargeDate: safeCalendar.date(byAdding: .day, value: 2, to: referenceDate) ?? referenceDate,
                category: "Health"
            ),
            Subscription(
                name: "Gardening Service",
                price: 120.0,
                currency: "USD",
                billingPeriod: .custom(days: 45),
                nextChargeDate: safeCalendar.date(byAdding: .day, value: 20, to: referenceDate) ?? referenceDate,
                category: "Home",
                notes: "Includes lawn care"
            )
        ]
    }
}

private extension Decimal {
    func scaled(by multiplier: Double) -> Decimal {
        guard multiplier != 1 else { return self }
        let decimalMultiplier = NSDecimalNumber(value: multiplier)
        let decimalSelf = NSDecimalNumber(decimal: self)
        return decimalSelf.multiplying(by: decimalMultiplier).decimalValue
    }
}
#endif
