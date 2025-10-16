import SwiftUI

struct ReminderSettingsView: View {
    @AppStorage(AppStorageKey.globalRemindersEnabled) private var remindersEnabled = true

    var body: some View {
        Form {
            Section("Reminder Preferences") {
                Toggle("Enable renewals reminders", isOn: $remindersEnabled)
                Text(remindersEnabled ? "We'll notify you before each renewal." : "Reminders will be paused until you enable them again.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section("Tips") {
                Label("Control reminder defaults from the Add Subscription form.", systemImage: "lightbulb")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    NavigationStack {
        ReminderSettingsView()
    }
}
