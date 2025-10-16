import SwiftUI
import SwiftData

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @Query(
        filter: #Predicate<Subscription> { $0.isArchived == false },
        sort: [
            SortDescriptor(\.nextChargeDate, order: .forward),
            SortDescriptor(\.name, order: .forward)
        ]
    ) private var activeSubscriptions: [Subscription]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header

                if viewModel.metrics.hasActiveSubscriptions {
                    categoryBreakdownSection
                    upcomingRenewalsSection
                } else {
                    emptyState
                }
            }
            .padding(.vertical, 24)
            .padding(.horizontal)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .onAppear { viewModel.update(with: activeSubscriptions) }
        .onChange(of: activeSubscriptions) { viewModel.update(with: $0) }
        .refreshable {
            await viewModel.refresh(with: activeSubscriptions)
        }
    }

    private var header: some View {
        let metrics = viewModel.metrics

        return VStack(alignment: .leading, spacing: 16) {
            Text("Monthly Overview")
                .font(.title2.bold())

            VStack(spacing: 12) {
                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    Text(formatCurrency(metrics.totalMonthlyCost))
                        .font(.system(size: 34, weight: .heavy, design: .rounded))
                    Text("per month")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 16) {
                    MetricPill(
                        title: "Active",
                        value: "\(metrics.activeSubscriptionCount)",
                        subtitle: "Subscriptions",
                        systemImage: "checkmark.circle.fill"
                    )

                    MetricPill(
                        title: "Average",
                        value: formatCurrency(metrics.averageMonthlyCost),
                        subtitle: "Per Subscription",
                        systemImage: "chart.pie.fill"
                    )
                }

                Text("Updated \(viewModel.lastUpdated.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(.secondarySystemBackground).opacity(0.9))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.appAccent.opacity(0.15), lineWidth: 1)
            )
        }
    }

    private var categoryBreakdownSection: some View {
        let metrics = viewModel.metrics

        return VStack(alignment: .leading, spacing: 16) {
            Text("Where your money goes")
                .font(.headline)

            if metrics.categoryBreakdown.isEmpty {
                Text("Add categories to your subscriptions to see a breakdown of monthly costs.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                VStack(spacing: 16) {
                    ForEach(metrics.categoryBreakdown) { breakdown in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(breakdown.category)
                                    .font(.subheadline.bold())
                                Spacer()
                                Text(formatCurrency(breakdown.totalMonthlyCost))
                                    .font(.subheadline.weight(.semibold))
                            }

                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color.appAccent.opacity(0.12))
                                    Capsule()
                                        .fill(color(for: breakdown.category))
                                        .frame(width: geometry.size.width * CGFloat(breakdown.percentageOfTotal))
                                }
                            }
                            .frame(height: 12)

                            HStack {
                                Text("\(breakdown.subscriptionCount) subscription\(breakdown.subscriptionCount == 1 ? "" : "s")")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text(formatPercentage(breakdown.percentageOfTotal))
                                    .font(.caption.bold())
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(.secondarySystemBackground).opacity(0.9))
                )
            }
        }
    }

    private var upcomingRenewalsSection: some View {
        let renewals = viewModel.metrics.upcomingRenewals

        return VStack(alignment: .leading, spacing: 16) {
            Text("Upcoming renewals")
                .font(.headline)

            if renewals.isEmpty {
                Text("No renewals in the next 30 days. You're all caught up!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                VStack(spacing: 12) {
                    ForEach(renewals) { renewal in
                        NavigationLink(value: renewal.subscription) {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(renewal.subscription.name)
                                        .font(.headline)
                                    Spacer()
                                    Text(formatCurrency(renewal.subscription.normalizeToMonthlyCost()))
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }

                                HStack(spacing: 12) {
                                    Label(
                                        renewal.relativeDescription.capitalized,
                                        systemImage: "calendar"
                                    )
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                    Spacer()

                                    Text(renewal.renewalDate.formatted(date: .abbreviated, time: .omitted))
                                        .font(.caption.bold())
                                        .foregroundStyle(.appAccent)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color(.secondarySystemBackground).opacity(0.95))
                            )
                        }
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(Color.appAccent)

            Text("No active subscriptions yet")
                .font(.title3.bold())

            Text("Add your subscriptions to start tracking monthly spending, category breakdowns, and upcoming renewals.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground).opacity(0.9))
        )
    }

    private func formatCurrency(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = viewModel.metrics.currencyCode
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.string(from: NSDecimalNumber(decimal: value)) ?? "\(value as NSDecimalNumber)"
    }

    private func formatPercentage(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? String(format: "%.0f%%", value * 100)
    }

    private func color(for category: String) -> Color {
        let colors: [Color] = [
            .appAccent,
            .blue.opacity(0.8),
            .green.opacity(0.8),
            .orange.opacity(0.85),
            .purple.opacity(0.8),
            .pink.opacity(0.8),
            .teal.opacity(0.8)
        ]
        let index = abs(category.hashValue) % colors.count
        return colors[index]
    }
}

private struct MetricPill: View {
    let title: String
    let value: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(.appAccent)
            VStack(alignment: .leading, spacing: 4) {
                Text(title.uppercased())
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.headline)
                Text(subtitle)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.tertiarySystemBackground).opacity(0.95))
        )
    }
}

#Preview {
    NavigationStack {
        DashboardView()
    }
    .modelContainer(PreviewData.container)
}
