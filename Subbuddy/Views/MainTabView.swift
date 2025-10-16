import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Tab = .dashboard

    var body: some View {
        TabView(selection: $selectedTab) {
            tab(for: .dashboard) {
                DashboardView()
            }

            tab(for: .subscriptions) {
                SubscriptionsView()
            }

            tab(for: .settings) {
                SettingsView()
            }
        }
        .tint(.appAccent)
        .background(Color.appBackground.ignoresSafeArea())
    }

    private func tab<Content: View>(for tab: Tab, @ViewBuilder content: () -> Content) -> some View {
        NavigationStack {
            content()
                .navigationTitle(tab.title)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarBackground(Color.appBackground, for: .navigationBar)
        }
        .tabItem {
            Label(tab.title, systemImage: tab.systemImage)
        }
        .tag(tab)
    }
}

extension MainTabView {
    enum Tab: Hashable {
        case dashboard
        case subscriptions
        case settings

        var title: String {
            switch self {
            case .dashboard:
                return "Dashboard"
            case .subscriptions:
                return "Subscriptions"
            case .settings:
                return "Settings"
            }
        }

        var systemImage: String {
            switch self {
            case .dashboard:
                return "rectangle.grid.2x2"
            case .subscriptions:
                return "creditcard"
            case .settings:
                return "gearshape"
            }
        }
    }
}

#Preview {
    MainTabView()
}
