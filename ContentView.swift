import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var subscriptions: [Subscription]

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(subscriptions) { subscription in
                    VStack(alignment: .leading) {
                        Text(subscription.name)
                            .font(.headline)
                        Text("\(subscription.currency) \(subscription.price as NSDecimalNumber)")
                            .font(.subheadline)
                        Text(subscription.billingPeriod.displayName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Subscriptions")
            .toolbar {
                ToolbarItem {
                    Button(action: addSampleSubscription) {
                        Label("Add Sample", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Select a subscription")
        }
    }

    private func addSampleSubscription() {
        withAnimation {
            let newSubscription = Subscription(
                name: "Sample Service",
                price: 9.99,
                billingPeriod: .monthly,
                nextChargeDate: Date()
            )
            modelContext.insert(newSubscription)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(PreviewData.container)
}
