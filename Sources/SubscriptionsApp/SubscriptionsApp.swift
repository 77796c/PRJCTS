#if canImport(SwiftUI) && canImport(SwiftData)
import SwiftData
import SwiftUI

@main
@MainActor
public struct SubscriptionsApp: App {
    private let container: ModelContainer

    public init() {
        do {
            let schema = Schema([Subscription.self])
            let configuration = ModelConfiguration(schema: schema)
            container = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to configure SwiftData ModelContainer: \(error.localizedDescription)")
        }
    }

    public var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(container)
        }
    }
}
#endif
