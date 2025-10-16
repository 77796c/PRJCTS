import SwiftUI
import SwiftData

#if canImport(UIKit)
import UIKit
#endif

@main
struct SubbuddyApp: App {
    private let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(for: Subscription.self)
        } catch {
            fatalError("Failed to create model container: \(error)")
        }

        configureAppearance()
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .accentColor(.appAccent)
                .background(Color.appBackground.ignoresSafeArea())
        }
        .modelContainer(modelContainer)
    }

    private func configureAppearance() {
        #if canImport(UIKit)
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor(Color.appBackground)
        tabAppearance.shadowColor = nil

        let selectedTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(Color.appAccent)
        ]
        let normalTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(Color.appAccent).withAlphaComponent(0.6)
        ]

        tabAppearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.appAccent)
        tabAppearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedTextAttributes
        tabAppearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color.appAccent).withAlphaComponent(0.6)
        tabAppearance.stackedLayoutAppearance.normal.titleTextAttributes = normalTextAttributes
        tabAppearance.inlineLayoutAppearance = tabAppearance.stackedLayoutAppearance
        tabAppearance.compactInlineLayoutAppearance = tabAppearance.stackedLayoutAppearance

        UITabBar.appearance().standardAppearance = tabAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabAppearance
        }
        UITabBar.appearance().tintColor = UIColor(Color.appAccent)

        let navigationAppearance = UINavigationBarAppearance()
        navigationAppearance.configureWithOpaqueBackground()
        navigationAppearance.backgroundColor = UIColor(Color.appBackground)
        navigationAppearance.shadowColor = nil
        navigationAppearance.titleTextAttributes = selectedTextAttributes
        navigationAppearance.largeTitleTextAttributes = selectedTextAttributes

        UINavigationBar.appearance().standardAppearance = navigationAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationAppearance
        UINavigationBar.appearance().compactAppearance = navigationAppearance
        UINavigationBar.appearance().tintColor = UIColor(Color.appAccent)
        #endif
    }
}
