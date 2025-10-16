#if canImport(SwiftUI) && canImport(StoreKit)
import SwiftUI
#if canImport(SubuddyCore)
import SubuddyCore
#endif

@main
struct SubuddyApp: App {
    @StateObject private var storeKitManager = StoreKitManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(storeKitManager)
        }
    }
}
#endif
