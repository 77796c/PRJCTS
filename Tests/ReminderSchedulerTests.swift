import XCTest
@testable import SubscriptionTracker

final class ReminderSchedulerTests: XCTestCase {
    private var testCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }

    func testScheduleInfoUsesLeadTimeForReminderDate() {
        let calendar = testCalendar
        let now = calendar.date(from: DateComponents(year: 2024, month: 1, day: 1, hour: 8, minute: 0, second: 0))!
        let nextCharge = calendar.date(byAdding: .day, value: 5, to: now)!

        let subscription = Subscription(
            name: "Test",
            price: 9.99,
            billingPeriod: .monthly,
            nextChargeDate: nextCharge,
            reminderLeadTime: 3,
            remindersEnabled: true
        )

        let info = ReminderScheduler.scheduleInfo(for: subscription, now: now, calendar: calendar)

        XCTAssertNotNil(info)
        XCTAssertEqual(info?.renewalDate, nextCharge)

        let expectedAnchor = calendar.date(byAdding: .day, value: 2, to: now)!
        var expectedComponents = calendar.dateComponents([.year, .month, .day], from: expectedAnchor)
        expectedComponents.hour = 9
        expectedComponents.minute = 0
        expectedComponents.second = 0
        let expectedFireDate = calendar.date(from: expectedComponents)!

        XCTAssertEqual(info?.fireDate, expectedFireDate)
    }

    func testScheduleInfoFallsBackToSoonestWhenLeadTimeHasPassed() {
        let calendar = testCalendar
        let now = calendar.date(from: DateComponents(year: 2024, month: 6, day: 1, hour: 12, minute: 0, second: 0))!
        let nextCharge = calendar.date(byAdding: .day, value: 1, to: now)!

        let subscription = Subscription(
            name: "Test",
            price: 4.99,
            billingPeriod: .monthly,
            nextChargeDate: nextCharge,
            reminderLeadTime: 3,
            remindersEnabled: true
        )

        let info = ReminderScheduler.scheduleInfo(for: subscription, now: now, calendar: calendar)

        XCTAssertNotNil(info)
        let minimumFireDate = calendar.date(byAdding: .minute, value: 1, to: now)!
        XCTAssertEqual(info?.fireDate, minimumFireDate)
    }

    func testArchivedSubscriptionDoesNotProduceSchedule() {
        let calendar = testCalendar
        let now = calendar.date(from: DateComponents(year: 2024, month: 2, day: 10, hour: 9, minute: 0))!
        let nextCharge = calendar.date(byAdding: .day, value: 10, to: now)!

        let subscription = Subscription(
            name: "Archived",
            price: 12.0,
            billingPeriod: .monthly,
            nextChargeDate: nextCharge,
            reminderLeadTime: 3,
            remindersEnabled: true,
            isArchived: true
        )

        XCTAssertNil(ReminderScheduler.scheduleInfo(for: subscription, now: now, calendar: calendar))
    }

    func testWeeklySubscriptionAdvancesUntilFutureRenewal() {
        let calendar = testCalendar
        let now = calendar.date(from: DateComponents(year: 2024, month: 3, day: 20, hour: 8, minute: 0))!
        let pastCharge = calendar.date(byAdding: .day, value: -21, to: now)!

        let subscription = Subscription(
            name: "Weekly",
            price: 5.0,
            billingPeriod: .weekly,
            nextChargeDate: pastCharge,
            reminderLeadTime: 2,
            remindersEnabled: true
        )

        let info = ReminderScheduler.scheduleInfo(for: subscription, now: now, calendar: calendar)
        XCTAssertNotNil(info)
        XCTAssertTrue(info!.renewalDate > now)
    }
}
