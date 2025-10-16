import SwiftUI
import SwiftData

struct SubscriptionDetailView: View {
    let subscription: Subscription

    private var currencyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = subscription.currency
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter
    }

    private var relativeFormatter: RelativeDateTimeFormatter {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter
    }

    private var monthlyCostString: String {
        formatCurrency(subscription.normalizeToMonthlyCost())
    }

    private var priceString: String {
        formatCurrency(subscription.price)
    }

    private func formatCurrency(_ value: Decimal) -> String {
        let number = NSDecimalNumber(decimal: value)
        return currencyFormatter.string(from: number) ?? "\(value as NSDecimalNumber)"
    }

    var body: some View {
        List {
            Section("Summary") {
                labeledRow(label: "Billing", value: subscription.billingPeriod.displayName)
                labeledRow(label: "Price", value: priceString)
                labeledRow(label: "Normalized Monthly", value: monthlyCostString)
                labeledRow(label: "Category", value: subscription.category)
            }

            Section("Renewal") {
                if let nextRenewal = subscription.calculateNextRenewal() {
                    labeledRow(label: "Next Renewal", value: nextRenewal.formatted(date: .abbreviated, time: .omitted))
                    labeledRow(label: "Relative", value: relativeFormatter.localizedString(for: nextRenewal, relativeTo: Date()))
                } else {
                    Text("No upcoming renewal scheduled")
                        .foregroundStyle(.secondary)
                }
            }

            if let notes = subscription.notes.isEmpty ? nil : subscription.notes {
                Section("Notes") {
                    Text(notes)
                }
            }

            if let provider = subscription.providerURL, let url = URL(string: provider) {
                Section("Provider") {
                    Link(destination: url) {
                        Label("Open Provider", systemImage: "safari")
                    }
                }
            }
        }
        .navigationTitle(subscription.name)
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(.insetGrouped)
    }

    private func labeledRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .multilineTextAlignment(.trailing)
        }
    }
}

#Preview {
    NavigationStack {
        if let subscription = PreviewData.sampleSubscriptions.first {
            SubscriptionDetailView(subscription: subscription)
        }
    }
    .modelContainer(PreviewData.container)
}
