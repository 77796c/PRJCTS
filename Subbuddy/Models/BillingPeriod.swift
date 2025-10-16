import Foundation

enum BillingPeriod: String, Codable, CaseIterable {
    case weekly
    case monthly
    case yearly
    case custom

    var displayName: String {
        switch self {
        case .weekly:
            return "Weekly"
        case .monthly:
            return "Monthly"
        case .yearly:
            return "Yearly"
        case .custom:
            return "Custom"
        }
    }

    var daysInPeriod: Int? {
        switch self {
        case .weekly:
            return 7
        case .monthly:
            return 30
        case .yearly:
            return 365
        case .custom:
            return nil
        }
    }
}
