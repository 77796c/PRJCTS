import Foundation
import SwiftData

#if canImport(UserNotifications)
import UserNotifications

@MainActor
final class NotificationManager: ObservableObject {
    enum AuthorizationState: Equatable {
        case notDetermined
        case denied
        case authorized
        case provisional
        case ephemeral

        init(_ status: UNAuthorizationStatus) {
            switch status {
            case .notDetermined:
                self = .notDetermined
            case .denied:
                self = .denied
            case .authorized:
                self = .authorized
            case .provisional:
                self = .provisional
            case .ephemeral:
                self = .ephemeral
            @unknown default:
                self = .authorized
            }
        }

        var isAuthorized: Bool {
            switch self {
            case .authorized, .provisional, .ephemeral:
                return true
            case .notDetermined, .denied:
                return false
            }
        }

        var description: String {
            switch self {
            case .notDetermined:
                return "Not Determined"
            case .denied:
                return "Denied"
            case .authorized:
                return "Authorized"
            case .provisional:
                return "Provisional"
            case .ephemeral:
                return "Ephemeral"
            }
        }
    }

    struct ScheduledReminder: Identifiable, Equatable {
        let id: String
        let title: String
        let message: String
        let fireDate: Date?
    }

    @Published private(set) var authorizationState: AuthorizationState = .notDetermined
    @Published private(set) var scheduledReminders: [ScheduledReminder] = []
    @Published private(set) var lastErrorMessage: String?

    private let center: UNUserNotificationCenter
    private let defaults: UserDefaults
    private let calendar: Calendar

    private lazy var reminderDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    init(center: UNUserNotificationCenter = .current(), defaults: UserDefaults = .standard, calendar: Calendar = .current) {
        self.center = center
        self.defaults = defaults
        self.calendar = calendar

        Task {
            await refreshAuthorizationState()
            await reloadScheduledReminders()
        }
    }

    func refreshAuthorizationState() async {
        let settings = await center.notificationSettings()
        authorizationState = AuthorizationState(settings.authorizationStatus)
    }

    @discardableResult
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            await refreshAuthorizationState()
            lastErrorMessage = nil
            return granted
        } catch {
            lastErrorMessage = error.localizedDescription
            await refreshAuthorizationState()
            return false
        }
    }

    @discardableResult
    func ensureAuthorization() async -> Bool {
        switch authorizationState {
        case .authorized, .provisional, .ephemeral:
            return true
        case .notDetermined:
            return await requestAuthorization()
        case .denied:
            return false
        }
    }

    func scheduleReminder(for subscription: Subscription) async {
        await cancelReminder(forID: subscription.id)

        guard shouldSchedule(for: subscription) else {
            return
        }

        guard await ensureAuthorization() else {
            return
        }

        guard let scheduleInfo = ReminderScheduler.scheduleInfo(for: subscription, now: Date(), calendar: calendar) else {
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "\(subscription.name) renews soon"
        content.body = reminderBody(for: subscription, renewalDate: scheduleInfo.renewalDate)
        content.sound = .default

        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: scheduleInfo.fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: identifier(forID: subscription.id), content: content, trigger: trigger)

        do {
            try await center.add(request)
            lastErrorMessage = nil
        } catch {
            lastErrorMessage = error.localizedDescription
        }

        await reloadScheduledReminders()
    }

    func rescheduleAll(for subscriptions: [Subscription]) async {
        let identifiers = subscriptions.map { identifier(forID: $0.id) }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)

        for subscription in subscriptions {
            await scheduleReminder(for: subscription)
        }
    }

    func cancelReminder(for subscription: Subscription) async {
        await cancelReminder(forID: subscription.id)
    }

    func cancelReminder(forID id: UUID) async {
        center.removePendingNotificationRequests(withIdentifiers: [identifier(forID: id)])
        await reloadScheduledReminders()
    }

    func cancelReminders(for subscriptions: [Subscription]) async {
        let identifiers = subscriptions.map { identifier(forID: $0.id) }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
        await reloadScheduledReminders()
    }

    func reloadScheduledReminders() async {
        let requests = await fetchPendingRequests()
        scheduledReminders = requests
            .map { request in
                let trigger = request.trigger as? UNCalendarNotificationTrigger
                return ScheduledReminder(
                    id: request.identifier,
                    title: request.content.title,
                    message: request.content.body,
                    fireDate: trigger?.nextTriggerDate()
                )
            }
            .sorted(by: { lhs, rhs in
                switch (lhs.fireDate, rhs.fireDate) {
                case let (lhsDate?, rhsDate?):
                    return lhsDate < rhsDate
                case (_?, nil):
                    return true
                case (nil, _?):
                    return false
                default:
                    return lhs.id < rhs.id
                }
            })
    }

    private func shouldSchedule(for subscription: Subscription) -> Bool {
        guard globalRemindersEnabled else {
            return false
        }
        return subscription.remindersEnabled && !subscription.isArchived
    }

    private var globalRemindersEnabled: Bool {
        if defaults.object(forKey: AppStorageKey.globalRemindersEnabled) == nil {
            return true
        }
        return defaults.bool(forKey: AppStorageKey.globalRemindersEnabled)
    }

    private func reminderBody(for subscription: Subscription, renewalDate: Date) -> String {
        let dateString = reminderDateFormatter.string(from: renewalDate)
        return "Your \(subscription.name) subscription renews on \(dateString)."
    }

    private func identifier(for subscription: Subscription) -> String {
        identifier(forID: subscription.id)
    }

    private func identifier(forID id: UUID) -> String {
        "subscription-\(id.uuidString)"
    }

    private func fetchPendingRequests() async -> [UNNotificationRequest] {
        await withCheckedContinuation { continuation in
            center.getPendingNotificationRequests { requests in
                continuation.resume(returning: requests)
            }
        }
    }
}

#else

@MainActor
final class NotificationManager: ObservableObject {
    enum AuthorizationState: Equatable {
        case notDetermined
        case denied
        case authorized
        case provisional
        case ephemeral

        var isAuthorized: Bool {
            switch self {
            case .authorized, .provisional, .ephemeral:
                return true
            case .notDetermined, .denied:
                return false
            }
        }

        var description: String {
            switch self {
            case .notDetermined:
                return "Not Determined"
            case .denied:
                return "Denied"
            case .authorized:
                return "Authorized"
            case .provisional:
                return "Provisional"
            case .ephemeral:
                return "Ephemeral"
            }
        }
    }

    struct ScheduledReminder: Identifiable, Equatable {
        let id: String
        let title: String
        let message: String
        let fireDate: Date?
    }

    @Published private(set) var authorizationState: AuthorizationState = .authorized
    @Published private(set) var scheduledReminders: [ScheduledReminder] = []
    @Published private(set) var lastErrorMessage: String?

    init() {}

    func refreshAuthorizationState() async {}

    @discardableResult
    func requestAuthorization() async -> Bool { true }

    @discardableResult
    func ensureAuthorization() async -> Bool { true }

    func scheduleReminder(for subscription: Subscription) async {}

    func rescheduleAll(for subscriptions: [Subscription]) async {}

    func cancelReminder(for subscription: Subscription) async {}

    func cancelReminder(forID id: UUID) async {}

    func cancelReminders(for subscriptions: [Subscription]) async {}

    func reloadScheduledReminders() async {}
}

#endif
