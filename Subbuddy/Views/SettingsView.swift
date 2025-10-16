import SwiftUI

struct SettingsView: View {
    var body: some View {
        List {
            Section("Account") {
                SettingsRow(icon: "person.crop.circle", title: "Profile", subtitle: "Manage your Subuddy account")
                SettingsRow(icon: "slider.horizontal.3", title: "Preferences", subtitle: "Customize notifications and themes")
            }

            Section("Support") {
                SettingsRow(icon: "message", title: "Contact Support", subtitle: "We're here to help")
                SettingsRow(icon: "lock.shield", title: "Privacy", subtitle: "Review our policies")
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color.appBackground.ignoresSafeArea())
    }
}

private struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(Color.appAccent)
                .frame(width: 36, height: 36)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
