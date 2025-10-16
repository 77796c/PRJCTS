import SwiftUI
import SwiftData

struct ReminderSettingsView: View {
    @EnvironmentObject private var notificationManager: NotificationManager
    @AppStorage(AppStorageKey.globalRemindersEnabled) private var remindersEnabled = true
    @AppStorage(AppStorageKey.defaultReminderLeadTime) private var defaultReminderLeadTime = 3
    @Query(sort: [SortDescriptor(\Subscription.nextChargeDate, order: .forward)]) private var subscriptions: [Subscription]

    var body: some View {
        Form {
            reminderPreferencesSection
            notificationAccessSection
            pendingRemindersSection
            tipsSection
        }
        .navigationTitle("Settings")
        .task {
            await notificationManager.refreshAuthorizationState()
            await notificationManager.reloadScheduledReminders()
        }
        .onChange(of: remindersEnabled, handleGlobalToggleChange)
    }

    private var reminderPreferencesSection: some View {
        Section("Reminder Preferences") {
            Toggle("Enable renewal reminders", isOn: $remindersEnabled)

            Stepper(value: $defaultReminderLeadTime, in: 0...30) {
                Text("Default reminder \(leadTimeDescription(defaultReminderLeadTime)) before renewal")
            }

            Text("New subscriptions inherit these defaults. Adjust individual reminders from each subscription.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private var notificationAccessSection: some View {
        Section("Notification Access") {
            HStack {
                Label("Authorization", systemImage: symbol(for: notificationManager.authorizationState))
                Spacer()
                Text(notificationManager.authorizationState.description)
                    .foregroundStyle(color(for: notificationManager.authorizationState))
            }

            switch notificationManager.authorizationState {
            case .denied:
                Text("Notifications are disabled at the system level. Enable them in Settings to continue receiving reminders.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            case .notDetermined:
                Text("We'll prompt for permission the first time a reminder needs to be scheduled.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            default:
                EmptyView()
            }

            if let error = notificationManager.lastErrorMessage {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }

            Button("Request Notification Access") {
                Task {
                    let granted = await notificationManager.requestAuthorization()
                    if granted {
                        await notificationManager.rescheduleAll(for: subscriptions)
                    }
                }
            }
            .disabled(notificationManager.authorizationState == .denied || notificationManager.authorizationState.isAuthorized)
        }
    }

    private var pendingRemindersSection: some View {
        Section("Pending Reminders (Debug)") {
            if notificationManager.scheduledReminders.isEmpty {
                Text("No reminders are currently scheduled")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(notificationManager.scheduledReminders) { reminder in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(reminder.title)
                            .font(.subheadline)
                        if let fireDate = reminder.fireDate {
                            Text(fireDate.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Text(reminder.message)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 2)
                }
            }

            Button("Refresh Pending Reminders") {
                Task { await notificationManager.reloadScheduledReminders() }
            }
            .font(.footnote.weight(.semibold))
        }
    }

    private var tipsSection: some View {
        Section("Tips") {
            Label("Control per-subscription reminders from the detail view or edit form.", systemImage: "lightbulb")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private func handleGlobalToggleChange(_ isEnabled: Bool) {
        Task {
            if isEnabled {
                let granted = await notificationManager.ensureAuthorization()
                guard granted else {
                    remindersEnabled = false
                    return
                }
                await notificationManager.rescheduleAll(for: subscriptions)
            } else {
                await notificationManager.cancelReminders(for: subscriptions)
            }
        }
    }

    private func leadTimeDescription(_ days: Int) -> String {
        if days == 0 {
            return "on the same day"
        } else if days == 1 {
            return "1 day"
        } else {
            return "\(days) days"
        }
    }

    private func symbol(for state: NotificationManager.AuthorizationState) -> String {
        switch state {
        case .authorized, .provisional, .ephemeral:
            return "bell.fill"
        case .denied:
            return "bell.slash"
        case .notDetermined:
            return "bell.badge"
        }
    }

    private func color(for state: NotificationManager.AuthorizationState) -> Color {
        switch state {
        case .authorized, .provisional, .ephemeral:
            return .green
        case .notDetermined:
            return .orange
        case .denied:
            return .red
        }
    }
}

#Preview {
    NavigationStack {
        ReminderSettingsView()
            .modelContainer(PreviewData.container)
            .environmentObject(NotificationManager())
    }
}
