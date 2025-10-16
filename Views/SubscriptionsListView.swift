import SwiftUI
import SwiftData

struct SubscriptionsListView: View {
    @Binding var selectedTab: AppTab
    @Environment(\.modelContext) private var modelContext
    @AppStorage(AppStorageKey.globalRemindersEnabled) private var globalRemindersEnabled = true
    @Query(sort: [SortDescriptor(\Subscription.updatedAt, order: .reverse)]) private var subscriptions: [Subscription]

    @State private var searchText = ""
    @State private var sortOption: SortOption = .nextChargeDate
    @State private var archivedFilter: ArchivedFilter = .active
    @State private var showingAddSheet = false

    var body: some View {
        Group {
            if filteredSubscriptions.isEmpty {
                emptyStateView
            } else {
                listView
            }
        }
        .navigationTitle("Subscriptions")
        .searchable(text: $searchText, prompt: "Search subscriptions")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Menu {
                    Picker("Filter", selection: $archivedFilter) {
                        ForEach(ArchivedFilter.allCases) { filter in
                            Text(filter.title)
                                .tag(filter)
                        }
                    }
                } label: {
                    Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Picker("Sort", selection: $sortOption) {
                        ForEach(SortOption.allCases) { option in
                            Text(option.title)
                                .tag(option)
                        }
                    }
                } label: {
                    Label("Sort", systemImage: "arrow.up.arrow.down")
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAddSheet = true
                } label: {
                    Label("New Subscription", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            NavigationStack {
                SubscriptionFormView()
            }
        }
        .animation(.default, value: filteredSubscriptions)
    }

    private var listView: some View {
        List {
            if !globalRemindersEnabled {
                Section {
                    ReminderSettingsBanner {
                        selectedTab = .settings
                    }
                    .listRowInsets(EdgeInsets())
                }
                .listRowBackground(Color.clear)
            }

            Section {
                ForEach(filteredSubscriptions) { subscription in
                    NavigationLink {
                        SubscriptionDetailView(subscription: subscription)
                    } label: {
                        SubscriptionRowView(subscription: subscription)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            delete(subscription)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        Button {
                            toggleArchive(for: subscription)
                        } label: {
                            Label(subscription.isArchived ? "Unarchive" : "Archive", systemImage: subscription.isArchived ? "tray.and.arrow.up.fill" : "archivebox")
                        }
                        .tint(subscription.isArchived ? .blue : .orange)
                    }
                }
                .onDelete(perform: deleteSubscriptions)
            }
        }
        .listStyle(.insetGrouped)
    }

    private var emptyStateView: some View {
        ContentUnavailableView(
            "No Subscriptions",
            systemImage: "tray",
            description: Text("Add a new subscription to start tracking your recurring costs.")
        )
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button(action: { showingAddSheet = true }) {
                    Label("Add Subscription", systemImage: "plus")
                }
            }
        }
    }

    private var filteredSubscriptions: [Subscription] {
        var results = subscriptions

        if !searchText.isEmpty {
            let query = searchText.lowercased()
            results = results.filter { subscription in
                subscription.name.lowercased().contains(query) ||
                subscription.category.lowercased().contains(query)
            }
        }

        switch archivedFilter {
        case .active:
            results = results.filter { !$0.isArchived }
        case .archived:
            results = results.filter { $0.isArchived }
        case .all:
            break
        }

        results.sort(using: sortOption)
        return results
    }

    private func deleteSubscriptions(at offsets: IndexSet) {
        let items = offsets.map { filteredSubscriptions[$0] }
        items.forEach(delete)
    }

    private func delete(_ subscription: Subscription) {
        withAnimation {
            modelContext.delete(subscription)
            saveChanges()
        }
    }

    private func toggleArchive(for subscription: Subscription) {
        withAnimation {
            subscription.isArchived.toggle()
            subscription.updatedAt = Date()
            saveChanges()
        }
    }

    private func saveChanges() {
        do {
            try modelContext.save()
        } catch {
            assertionFailure("Failed to save subscription changes: \(error)")
        }
    }
}

private extension Array where Element == Subscription {
    mutating func sort(using option: SubscriptionsListView.SortOption) {
        sort { option.areInIncreasingOrder($0, $1) }
    }
}

private extension SubscriptionsListView {
    enum ArchivedFilter: String, CaseIterable, Identifiable {
        case all
        case active
        case archived

        var id: String { rawValue }

        var title: String {
            switch self {
            case .all:
                return "All"
            case .active:
                return "Active"
            case .archived:
                return "Archived"
            }
        }
    }

    enum SortOption: String, CaseIterable, Identifiable {
        case nextChargeDate
        case monthlyCost
        case name

        var id: String { rawValue }

        var title: String {
            switch self {
            case .nextChargeDate:
                return "Next Charge"
            case .monthlyCost:
                return "Monthly Cost"
            case .name:
                return "Name"
            }
        }

        func areInIncreasingOrder(_ lhs: Subscription, _ rhs: Subscription) -> Bool {
            switch self {
            case .nextChargeDate:
                return lhs.nextChargeDate < rhs.nextChargeDate
            case .monthlyCost:
                return lhs.monthlyCostDouble < rhs.monthlyCostDouble
            case .name:
                return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
            }
        }
    }
}

private extension Subscription {
    var monthlyCostDouble: Double {
        NSDecimalNumber(decimal: monthlyCost).doubleValue
    }
}

private struct SubscriptionRowView: View {
    let subscription: Subscription

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(subscription.name)
                    .font(.headline)
                Spacer()
                Text(formattedPrice)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 12) {
                Label(subscription.billingPeriod.displayName, systemImage: "calendar")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Label(subscription.currency.uppercased(), systemImage: "coloncurrencysign")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if subscription.isArchived {
                    Label("Archived", systemImage: "archivebox")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }

            if let days = subscription.daysUntilRenewal(), days >= 0 {
                ProgressView(value: progressValue(for: days)) {
                    Text(renewalDescription(for: days))
                        .font(.subheadline)
                }
                .progressViewStyle(.linear)
            } else {
                Text("Next charge: \(subscription.nextChargeDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 6)
    }

    private var formattedPrice: String {
        formattedAmount(subscription.price, currencyCode: subscription.currency)
    }

    private func renewalDescription(for days: Int) -> String {
        if days == 0 {
            return "Renews today"
        } else if days == 1 {
            return "Renews tomorrow"
        } else {
            return "Renews in \(days) days"
        }
    }

    private func progressValue(for days: Int) -> Double {
        guard let totalDays = subscription.billingPeriod.daysInPeriod ?? subscription.customBillingDays else {
            return 0
        }

        if totalDays == 0 {
            return 0
        }

        let remaining = min(max(days, 0), totalDays)
        return 1 - Double(remaining) / Double(totalDays)
    }
}

private struct ReminderSettingsBanner: View {
    let onManageTapped: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Reminders are turned off", systemImage: "bell.slash")
                .font(.subheadline)
            Text("Enable reminders in Settings to receive alerts before renewals.")
                .font(.footnote)
                .foregroundStyle(.secondary)
            Button("Manage Reminder Settings", action: onManageTapped)
                .font(.footnote.weight(.semibold))
        }
        .padding()
        .background(.orange.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

#Preview {
    NavigationStack {
        SubscriptionsListView(selectedTab: .constant(.subscriptions))
    }
    .modelContainer(PreviewData.container)
}
