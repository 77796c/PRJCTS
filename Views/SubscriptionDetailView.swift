import SwiftUI
import SwiftData

struct SubscriptionDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @Bindable var subscription: Subscription

    @State private var showingDeleteConfirmation = false
    @State private var presentingEditSheet = false

    var body: some View {
        List {
            summarySection
            billingSection
            remindersSection
            notesSection
            metadataSection
            actionsSection
        }
        .navigationTitle(subscription.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    presentingEditSheet = true
                }
            }
        }
        .sheet(isPresented: $presentingEditSheet) {
            NavigationStack {
                SubscriptionFormView(subscription: subscription)
            }
        }
        .alert("Delete Subscription?", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive, action: deleteSubscription)
            Button("Cancel", role: .cancel, action: {})
        } message: {
            Text("This action cannot be undone.")
        }
    }

    private var summarySection: some View {
        Section("Summary") {
            HStack {
                Label("Price", systemImage: "creditcard")
                Spacer()
                Text(formattedAmount(subscription.price, currencyCode: subscription.currency))
            }
            HStack {
                Label("Monthly Cost", systemImage: "calendar")
                Spacer()
                Text(formattedAmount(subscription.monthlyCost, currencyCode: subscription.currency))
            }
        }
    }

    private var billingSection: some View {
        Section("Billing") {
            Label(subscription.billingPeriod.displayName, systemImage: "repeat")
            if subscription.billingPeriod == .custom, let days = subscription.customBillingDays {
                Label("Every \(days) days", systemImage: "clock")
            }
            Label("Next charge \(subscription.nextChargeDate.formatted(date: .abbreviated, time: .omitted))", systemImage: "calendar")
            if let daysUntil = subscription.daysUntilRenewal(), daysUntil >= 0 {
                Label(daysUntilDescription(daysUntil), systemImage: "hourglass")
            }
            if !subscription.category.isEmpty {
                Label(subscription.category, systemImage: "tag")
            }
        }
    }

    private var remindersSection: some View {
        Section("Reminders") {
            Label(subscription.remindersEnabled ? "Enabled" : "Disabled", systemImage: subscription.remindersEnabled ? "bell" : "bell.slash")
            if subscription.remindersEnabled {
                Label("Reminder \(subscription.reminderLeadTime == 1 ? "1 day" : "\(subscription.reminderLeadTime) days") before", systemImage: "timer")
            }
        }
    }

    private var notesSection: some View {
        Section("Notes") {
            if subscription.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text("No notes")
                    .foregroundStyle(.secondary)
            } else {
                Text(subscription.notes)
            }
        }
    }

    private var metadataSection: some View {
        Section("History") {
            Label("Created \(subscription.createdAt.formatted(date: .abbreviated, time: .shortened))", systemImage: "calendar.badge.plus")
            Label("Updated \(subscription.updatedAt.formatted(date: .abbreviated, time: .shortened))", systemImage: "clock.arrow.2.circlepath")
            if subscription.isArchived {
                Label("Archived", systemImage: "archivebox")
            }
        }
    }

    private var actionsSection: some View {
        Section("Quick Actions") {
            if let providerURL, let url = URL(string: providerURL) {
                Button {
                    openURL(url)
                } label: {
                    Label("Open Provider", systemImage: "safari")
                }
            }
            Button {
                toggleArchive()
            } label: {
                Label(subscription.isArchived ? "Unarchive" : "Archive", systemImage: subscription.isArchived ? "tray.and.arrow.up" : "archivebox")
            }
            Button(role: .destructive) {
                showingDeleteConfirmation = true
            } label: {
                Label("Delete Subscription", systemImage: "trash")
            }
        }
    }

    private var providerURL: String? {
        subscription.providerURL
    }

    private func daysUntilDescription(_ days: Int) -> String {
        if days == 0 {
            return "Renews today"
        } else if days == 1 {
            return "Renews tomorrow"
        } else {
            return "Renews in \(days) days"
        }
    }

    private func toggleArchive() {
        withAnimation {
            subscription.isArchived.toggle()
            subscription.updatedAt = Date()
            saveChanges()
        }
    }

    private func deleteSubscription() {
        withAnimation {
            modelContext.delete(subscription)
            saveChanges()
            dismiss()
        }
    }

    private func saveChanges() {
        do {
            try modelContext.save()
        } catch {
            assertionFailure("Failed to persist subscription changes: \(error)")
        }
    }
}

#Preview {
    NavigationStack {
        if let subscription = try? PreviewData.container.mainContext.fetch(FetchDescriptor<Subscription>()).first {
            SubscriptionDetailView(subscription: subscription)
        }
    }
    .modelContainer(PreviewData.container)
}
