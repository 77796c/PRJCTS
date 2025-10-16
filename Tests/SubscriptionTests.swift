import XCTest
import SwiftData
@testable import SubscriptionTracker

final class SubscriptionTests: XCTestCase {
    
    func testMonthlyNormalization() {
        let subscription = Subscription(
            name: "Test Monthly",
            price: 10.00,
            billingPeriod: .monthly,
            nextChargeDate: Date()
        )
        
        XCTAssertEqual(subscription.normalizeToMonthlyCost(), 10.00, accuracy: 0.01)
    }
    
    func testWeeklyNormalization() {
        let subscription = Subscription(
            name: "Test Weekly",
            price: 5.00,
            billingPeriod: .weekly,
            nextChargeDate: Date()
        )
        
        let expectedMonthlyCost = Decimal(5.00) * Decimal(52) / Decimal(12)
        XCTAssertEqual(subscription.normalizeToMonthlyCost(), expectedMonthlyCost, accuracy: 0.01)
    }
    
    func testYearlyNormalization() {
        let subscription = Subscription(
            name: "Test Yearly",
            price: 120.00,
            billingPeriod: .yearly,
            nextChargeDate: Date()
        )
        
        XCTAssertEqual(subscription.normalizeToMonthlyCost(), 10.00, accuracy: 0.01)
    }
    
    func testCustomNormalization() {
        let subscription = Subscription(
            name: "Test Custom",
            price: 30.00,
            billingPeriod: .custom,
            customBillingDays: 45,
            nextChargeDate: Date()
        )
        
        let averageDaysInMonth = Decimal(30.44)
        let expectedMonthlyCost = Decimal(30.00) * averageDaysInMonth / Decimal(45)
        XCTAssertEqual(subscription.normalizeToMonthlyCost(), expectedMonthlyCost, accuracy: 0.01)
    }
    
    func testCustomNormalizationWithNoDays() {
        let subscription = Subscription(
            name: "Test Custom No Days",
            price: 30.00,
            billingPeriod: .custom,
            customBillingDays: nil,
            nextChargeDate: Date()
        )
        
        XCTAssertEqual(subscription.normalizeToMonthlyCost(), 0.00)
    }
    
    func testCustomNormalizationWithZeroDays() {
        let subscription = Subscription(
            name: "Test Custom Zero Days",
            price: 30.00,
            billingPeriod: .custom,
            customBillingDays: 0,
            nextChargeDate: Date()
        )
        
        XCTAssertEqual(subscription.normalizeToMonthlyCost(), 0.00)
    }
    
    func testCalculateNextRenewalMonthly() {
        let calendar = Calendar.current
        let today = Date()
        let nextCharge = calendar.date(byAdding: .day, value: 10, to: today)!
        
        let subscription = Subscription(
            name: "Test",
            price: 10.00,
            billingPeriod: .monthly,
            nextChargeDate: nextCharge
        )
        
        XCTAssertEqual(subscription.calculateNextRenewal(after: today), nextCharge)
    }
    
    func testCalculateNextRenewalWeekly() {
        let calendar = Calendar.current
        let today = Date()
        let pastDate = calendar.date(byAdding: .day, value: -5, to: today)!
        
        let subscription = Subscription(
            name: "Test",
            price: 10.00,
            billingPeriod: .weekly,
            nextChargeDate: pastDate
        )
        
        let expectedNext = calendar.date(byAdding: .day, value: 7, to: pastDate)!
        XCTAssertEqual(subscription.calculateNextRenewal(after: today), expectedNext)
    }
    
    func testCalculateNextRenewalYearly() {
        let calendar = Calendar.current
        let today = Date()
        let pastDate = calendar.date(byAdding: .day, value: -30, to: today)!
        
        let subscription = Subscription(
            name: "Test",
            price: 100.00,
            billingPeriod: .yearly,
            nextChargeDate: pastDate
        )
        
        let expectedNext = calendar.date(byAdding: .year, value: 1, to: pastDate)!
        XCTAssertEqual(subscription.calculateNextRenewal(after: today), expectedNext)
    }
    
    func testCalculateNextRenewalCustom() {
        let calendar = Calendar.current
        let today = Date()
        let pastDate = calendar.date(byAdding: .day, value: -10, to: today)!
        
        let subscription = Subscription(
            name: "Test",
            price: 20.00,
            billingPeriod: .custom,
            customBillingDays: 30,
            nextChargeDate: pastDate
        )
        
        let expectedNext = calendar.date(byAdding: .day, value: 30, to: pastDate)!
        XCTAssertEqual(subscription.calculateNextRenewal(after: today), expectedNext)
    }
    
    func testDaysUntilRenewal() {
        let calendar = Calendar.current
        let today = Date()
        let futureDate = calendar.date(byAdding: .day, value: 15, to: today)!
        
        let subscription = Subscription(
            name: "Test",
            price: 10.00,
            billingPeriod: .monthly,
            nextChargeDate: futureDate
        )
        
        let days = subscription.daysUntilRenewal(from: today)
        XCTAssertNotNil(days)
        XCTAssertEqual(days, 15)
    }
    
    func testShouldShowReminderWhenEnabled() {
        let calendar = Calendar.current
        let today = Date()
        let futureDate = calendar.date(byAdding: .day, value: 2, to: today)!
        
        let subscription = Subscription(
            name: "Test",
            price: 10.00,
            billingPeriod: .monthly,
            nextChargeDate: futureDate,
            reminderLeadTime: 3,
            remindersEnabled: true
        )
        
        XCTAssertTrue(subscription.shouldShowReminder(from: today))
    }
    
    func testShouldNotShowReminderWhenDisabled() {
        let calendar = Calendar.current
        let today = Date()
        let futureDate = calendar.date(byAdding: .day, value: 2, to: today)!
        
        let subscription = Subscription(
            name: "Test",
            price: 10.00,
            billingPeriod: .monthly,
            nextChargeDate: futureDate,
            reminderLeadTime: 3,
            remindersEnabled: false
        )
        
        XCTAssertFalse(subscription.shouldShowReminder(from: today))
    }
    
    func testShouldNotShowReminderWhenTooFar() {
        let calendar = Calendar.current
        let today = Date()
        let futureDate = calendar.date(byAdding: .day, value: 10, to: today)!
        
        let subscription = Subscription(
            name: "Test",
            price: 10.00,
            billingPeriod: .monthly,
            nextChargeDate: futureDate,
            reminderLeadTime: 3,
            remindersEnabled: true
        )
        
        XCTAssertFalse(subscription.shouldShowReminder(from: today))
    }
    
    func testDefaultValues() {
        let subscription = Subscription(
            name: "Test",
            price: 10.00,
            billingPeriod: .monthly,
            nextChargeDate: Date()
        )
        
        XCTAssertEqual(subscription.currency, "USD")
        XCTAssertEqual(subscription.category, "Other")
        XCTAssertEqual(subscription.notes, "")
        XCTAssertNil(subscription.providerURL)
        XCTAssertFalse(subscription.isArchived)
        XCTAssertEqual(subscription.reminderLeadTime, 3)
        XCTAssertTrue(subscription.remindersEnabled)
    }
    
    func testUpdateNextChargeDate() {
        let calendar = Calendar.current
        let today = Date()
        let pastDate = calendar.date(byAdding: .day, value: -5, to: today)!
        
        let subscription = Subscription(
            name: "Test",
            price: 10.00,
            billingPeriod: .weekly,
            nextChargeDate: pastDate
        )
        
        let originalUpdatedAt = subscription.updatedAt
        
        Thread.sleep(forTimeInterval: 0.1)
        
        subscription.updateNextChargeDate()
        
        let expectedNext = calendar.date(byAdding: .day, value: 7, to: pastDate)!
        XCTAssertEqual(subscription.nextChargeDate, expectedNext)
        XCTAssertGreaterThan(subscription.updatedAt, originalUpdatedAt)
    }
}

extension Decimal {
    func rounded(toPlaces places: Int) -> Decimal {
        var result = self
        var rounded = Decimal()
        NSDecimalRound(&rounded, &result, places, .plain)
        return rounded
    }
}

func XCTAssertEqual(_ expression1: Decimal, _ expression2: Decimal, accuracy: Decimal, _ message: @autoclosure () -> String = "", file: StaticString = #filePath, line: UInt = #line) {
    let difference = abs(expression1 - expression2)
    if difference > accuracy {
        XCTFail("\(message()) - \(expression1) is not equal to \(expression2) +/- \(accuracy)", file: file, line: line)
    }
}
