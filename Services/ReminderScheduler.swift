import Foundation

struct ReminderScheduler {
    struct ScheduleInfo {
        let fireDate: Date
        let renewalDate: Date
    }

    static func scheduleInfo(for subscription: Subscription, now: Date = Date(), calendar: Calendar = .current) -> ScheduleInfo? {
        guard subscription.remindersEnabled, !subscription.isArchived else {
            return nil
        }

        guard let nextRenewal = nextRenewalDate(for: subscription, relativeTo: now, calendar: calendar) else {
            return nil
        }

        let leadTime = max(subscription.reminderLeadTime, 0)
        guard let reminderAnchor = calendar.date(byAdding: .day, value: -leadTime, to: nextRenewal) else {
            return nil
        }

        var components = calendar.dateComponents([.year, .month, .day], from: reminderAnchor)
        components.hour = 9
        components.minute = 0
        components.second = 0

        guard let reminderDate = calendar.date(from: components) else {
            return nil
        }

        let minimumFireDate = calendar.date(byAdding: .minute, value: 1, to: now) ?? now.addingTimeInterval(60)
        let fireDate = reminderDate < now ? minimumFireDate : reminderDate

        return ScheduleInfo(fireDate: fireDate, renewalDate: nextRenewal)
    }

    private static func nextRenewalDate(for subscription: Subscription, relativeTo now: Date, calendar: Calendar) -> Date? {
        var candidate = subscription.nextChargeDate

        if candidate > now {
            return candidate
        }

        for _ in 0..<48 {
            guard let advanced = advanceRenewalDate(candidate, for: subscription, calendar: calendar) else {
                return nil
            }
            candidate = advanced
            if candidate > now {
                return candidate
            }
        }

        return candidate > now ? candidate : nil
    }

    private static func advanceRenewalDate(_ date: Date, for subscription: Subscription, calendar: Calendar) -> Date? {
        switch subscription.billingPeriod {
        case .weekly:
            return calendar.date(byAdding: .day, value: 7, to: date)
        case .monthly:
            return calendar.date(byAdding: .month, value: 1, to: date)
        case .yearly:
            return calendar.date(byAdding: .year, value: 1, to: date)
        case .custom:
            guard let days = subscription.customBillingDays, days > 0 else {
                return nil
            }
            return calendar.date(byAdding: .day, value: days, to: date)
        }
    }
}
