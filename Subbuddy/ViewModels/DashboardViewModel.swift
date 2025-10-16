import Foundation
import SwiftData

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published private(set) var metrics: DashboardMetrics = .empty
    @Published private(set) var lastUpdated: Date = Date()

    private let calendar: Calendar
    private let upcomingWindowInDays: Int
    private let relativeFormatter: RelativeDateTimeFormatter

    init(calendar: Calendar = .current, upcomingWindowInDays: Int = 30) {
        self.calendar = calendar
        self.upcomingWindowInDays = upcomingWindowInDays
        self.relativeFormatter = RelativeDateTimeFormatter()
        self.relativeFormatter.unitsStyle = .full
    }

    func update(with subscriptions: [Subscription], referenceDate: Date = Date()) {
        lastUpdated = referenceDate
        let activeSubscriptions = subscriptions.filter { !$0.isArchived }

        guard !activeSubscriptions.isEmpty else {
            metrics = .empty
            return
        }

        let totalMonthlyCost = activeSubscriptions.reduce(into: Decimal.zero) { partialResult, subscription in
            partialResult += subscription.normalizeToMonthlyCost()
        }

        let currencyCode = activeSubscriptions.currencyCodeFallback
        let averageMonthlyCost = totalMonthlyCost / Decimal(activeSubscriptions.count)
        let categoryBreakdown = makeCategoryBreakdown(from: activeSubscriptions, totalMonthlyCost: totalMonthlyCost)
        let upcomingRenewals = makeUpcomingRenewals(from: activeSubscriptions, referenceDate: referenceDate)

        metrics = DashboardMetrics(
            currencyCode: currencyCode,
            totalMonthlyCost: totalMonthlyCost,
            averageMonthlyCost: averageMonthlyCost,
            activeSubscriptionCount: activeSubscriptions.count,
            categoryBreakdown: categoryBreakdown,
            upcomingRenewals: upcomingRenewals
        )
    }

    func refresh(with subscriptions: [Subscription]) async {
        await MainActor.run {
            self.update(with: subscriptions, referenceDate: Date())
        }
    }

    private func makeCategoryBreakdown(from subscriptions: [Subscription], totalMonthlyCost: Decimal) -> [DashboardMetrics.CategoryBreakdown] {
        guard !subscriptions.isEmpty else { return [] }

        let grouped = Dictionary(grouping: subscriptions) { subscription in
            let trimmed = subscription.category.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? "Uncategorized" : trimmed
        }

        let totalDouble = totalMonthlyCost.doubleValue

        let breakdown = grouped.map { category, items -> DashboardMetrics.CategoryBreakdown in
            let categoryTotal = items.reduce(into: Decimal.zero) { partialResult, subscription in
                partialResult += subscription.normalizeToMonthlyCost()
            }

            let categoryPercentage = totalDouble > 0 ? categoryTotal.doubleValue / totalDouble : 0
            return DashboardMetrics.CategoryBreakdown(
                category: category,
                totalMonthlyCost: categoryTotal,
                percentageOfTotal: categoryPercentage.clampedToUnitInterval,
                subscriptionCount: items.count
            )
        }

        return breakdown.sorted { lhs, rhs in
            if lhs.totalMonthlyCost == rhs.totalMonthlyCost {
                return lhs.category.localizedCaseInsensitiveCompare(rhs.category) == .orderedAscending
            }
            return lhs.totalMonthlyCost > rhs.totalMonthlyCost
        }
    }

    private func makeUpcomingRenewals(from subscriptions: [Subscription], referenceDate: Date) -> [DashboardMetrics.UpcomingRenewal] {
        let referenceStart = calendar.startOfDay(for: referenceDate)

        let renewals = subscriptions.compactMap { subscription -> DashboardMetrics.UpcomingRenewal? in
            guard let renewalDate = subscription.calculateNextRenewal(after: referenceDate) else {
                return nil
            }

            let renewalStart = calendar.startOfDay(for: renewalDate)
            let components = calendar.dateComponents([.day], from: referenceStart, to: renewalStart)
            guard let daysUntil = components.day, daysUntil >= 0, daysUntil <= upcomingWindowInDays else {
                return nil
            }

            let relativeDescription = relativeFormatter.localizedString(for: renewalDate, relativeTo: referenceDate)

            return DashboardMetrics.UpcomingRenewal(
                subscription: subscription,
                renewalDate: renewalDate,
                daysUntil: daysUntil,
                relativeDescription: relativeDescription
            )
        }

        return renewals.sorted { $0.renewalDate < $1.renewalDate }
    }
}

struct DashboardMetrics {
    struct CategoryBreakdown: Identifiable {
        let category: String
        let totalMonthlyCost: Decimal
        let percentageOfTotal: Double
        let subscriptionCount: Int

        var id: String { category }
    }

    struct UpcomingRenewal: Identifiable {
        let subscription: Subscription
        let renewalDate: Date
        let daysUntil: Int
        let relativeDescription: String

        var id: Subscription.ID { subscription.id }
    }

    let currencyCode: String
    let totalMonthlyCost: Decimal
    let averageMonthlyCost: Decimal
    let activeSubscriptionCount: Int
    let categoryBreakdown: [CategoryBreakdown]
    let upcomingRenewals: [UpcomingRenewal]

    static var empty: DashboardMetrics {
        DashboardMetrics(
            currencyCode: Locale.current.currency?.identifier ?? "USD",
            totalMonthlyCost: .zero,
            averageMonthlyCost: .zero,
            activeSubscriptionCount: 0,
            categoryBreakdown: [],
            upcomingRenewals: []
        )
    }

    var hasActiveSubscriptions: Bool { activeSubscriptionCount > 0 }
}

private extension Decimal {
    var doubleValue: Double {
        NSDecimalNumber(decimal: self).doubleValue
    }
}

private extension Double {
    var clampedToUnitInterval: Double {
        guard isFinite else { return 0 }
        return max(0, min(self, 1))
    }
}

private extension Array where Element == Subscription {
    var currencyCodeFallback: String {
        if let currency = first(where: { !$0.currency.isEmpty })?.currency {
            return currency
        }
        return Locale.current.currency?.identifier ?? "USD"
    }
}
