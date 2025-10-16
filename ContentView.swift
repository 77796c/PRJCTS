import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab: AppTab = .subscriptions

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                SubscriptionsListView(selectedTab: $selectedTab)
            }
            .tabItem {
                Label("Subscriptions", systemImage: "list.bullet.rectangle")
            }
            .tag(AppTab.subscriptions)

            NavigationStack {
                ReminderSettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape")
            }
            .tag(AppTab.settings)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(PreviewData.container)
        .environmentObject(NotificationManager())
}
