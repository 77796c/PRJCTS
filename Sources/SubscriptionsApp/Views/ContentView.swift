#if canImport(SwiftUI) && canImport(SwiftData)
import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Subscription.nextChargeDate) private var subscriptions: [Subscription]

    var body: some View {
        NavigationStack {
            List(subscriptions) { subscription in
                SubscriptionRow(subscription: subscription)
            }
            .navigationTitle("Subscriptions")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Add Sample") {
                        addSampleSubscription()
                    }
                }
            }
        }
    }

    private func addSampleSubscription() {
        guard let sample = Subscription.sampleData().first else { return }
        modelContext.insert(sample)
    }
}

private struct SubscriptionRow: View {
    let subscription: Subscription

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(subscription.name)
                .font(.headline)

            HStack(spacing: 8) {
                Text(subscription.price, format: .currency(code: subscription.currency))
                Text("·")
                Text(subscription.billingPeriod.displayName)
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)

            Text(subscription.nextChargeDate, format: .dateTime.month().day().year())
                .font(.footnote)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

#Preview("Subscriptions with sample data") {
    ContentView()
        .modelContainer(.preview(
            inserting: Subscription.sampleData()
        ))
}

private extension ModelContainer {
    @MainActor
    static func preview(inserting models: [any PersistentModel]) -> ModelContainer {
        do {
            let schema = Schema([Subscription.self])
            let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: schema, configurations: [configuration])
            let context = container.mainContext
            models.forEach { model in
                if let subscription = model as? Subscription {
                    context.insert(subscription)
                }
            }
            return container
        } catch {
            fatalError("Preview configuration failed: \(error.localizedDescription)")
        }
    }
}
#endif
