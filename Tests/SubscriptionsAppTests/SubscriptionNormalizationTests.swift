#if canImport(SwiftData)
import Foundation
import XCTest
@testable import SubscriptionsApp

final class SubscriptionNormalizationTests: XCTestCase {
    func testNormalizedMonthlyCostForWeeklySubscription() {
        let calendar = Calendar(identifier: .gregorian)
        let nextCharge = calendar.date(from: DateComponents(year: 2024, month: 1, day: 1))!

        let subscription = Subscription(
            name: "Weekly Snack Box",
            price: 10,
            currency: "USD",
            billingPeriod: .weekly,
            nextChargeDate: nextCharge
        )

        let monthlyCost = subscription.normalizedMonthlyCost()
        let expected = 10 * Subscription.averageDaysInMonth / 7

        XCTAssertEqual(monthlyCost.doubleValue, expected, accuracy: 0.0001)
    }

    func testUpcomingRenewalAdvancesBeyondReferenceDate() {
        let calendar = Calendar(identifier: .gregorian)
        let initialCharge = calendar.date(from: DateComponents(year: 2024, month: 1, day: 1))!
        let referenceDate = calendar.date(from: DateComponents(year: 2024, month: 3, day: 15))!

        let subscription = Subscription(
            name: "News",
            price: 19.99,
            currency: "USD",
            billingPeriod: .monthly,
            nextChargeDate: initialCharge
        )

        let upcoming = subscription.upcomingRenewal(after: referenceDate, calendar: calendar)
        let components = calendar.dateComponents([.year, .month, .day], from: upcoming)

        XCTAssertEqual(components.year, 2024)
        XCTAssertEqual(components.month, 4)
        XCTAssertEqual(components.day, 1)
    }

    func testReminderTriggerDateRespectsLeadTime() {
        let calendar = Calendar(identifier: .gregorian)
        let nextCharge = calendar.date(from: DateComponents(year: 2024, month: 6, day: 10))!
        let referenceDate = calendar.date(from: DateComponents(year: 2024, month: 6, day: 1))!

        let subscription = Subscription(
            name: "Pro Tools",
            price: 49.0,
            currency: "USD",
            billingPeriod: .yearly,
            nextChargeDate: nextCharge,
            reminderLeadTime: 3 * 24 * 60 * 60,
            remindersEnabled: true
        )

        let reminderDate = subscription.reminderTriggerDate(from: referenceDate, calendar: calendar)
        XCTAssertNotNil(reminderDate)

        if let reminderDate {
            let components = calendar.dateComponents([.year, .month, .day], from: reminderDate)
            XCTAssertEqual(components.year, 2024)
            XCTAssertEqual(components.month, 6)
            XCTAssertEqual(components.day, 7)
        }
    }

    func testCustomBillingPeriodNormalization() {
        let calendar = Calendar(identifier: .gregorian)
        let nextCharge = calendar.date(from: DateComponents(year: 2024, month: 1, day: 1))!

        let subscription = Subscription(
            name: "Cleaning Service",
            price: 150,
            currency: "USD",
            billingPeriod: .custom(days: 45),
            nextChargeDate: nextCharge
        )

        let monthlyCost = subscription.normalizedMonthlyCost()
        let expected = 150 * Subscription.averageDaysInMonth / 45

        XCTAssertEqual(monthlyCost.doubleValue, expected, accuracy: 0.0001)
    }
}

private extension Decimal {
    var doubleValue: Double {
        NSDecimalNumber(decimal: self).doubleValue
    }
}
#endif
