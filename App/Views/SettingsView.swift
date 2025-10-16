#if canImport(SwiftUI) && canImport(StoreKit)
import SwiftUI
#if canImport(SubuddyCore)
import SubuddyCore
#endif

struct SettingsView: View {
    @EnvironmentObject private var storeKitManager: StoreKitManager

    var body: some View {
        Form {
            Section(header: Text("Ad-Free Experience")) {
                toggleRow
                purchaseButtons
            }

            Section(footer: Text("StoreKit transactions are simulated when running with the Subuddy.storekit configuration.")) {
                EmptyView()
            }
        }
        .navigationTitle("Settings")
    }

    private var toggleRow: some View {
        HStack {
            Label("Ad-Free", systemImage: storeKitManager.entitlementState.hasAdFreeAccess ? "checkmark.seal.fill" : "xmark.seal")
            Spacer()
            Text(storeKitManager.entitlementState.hasAdFreeAccess ? "Unlocked" : "Locked")
                .foregroundStyle(storeKitManager.entitlementState.hasAdFreeAccess ? .green : .secondary)
        }
    }

    private var purchaseButtons: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: purchase) {
                Label("Remove Ads", systemImage: "cart")
            }
            .disabled(storeKitManager.purchaseState == .inFlight || storeKitManager.purchaseState == .pending)

            Button("Restore Purchases", action: restore)
                .disabled(storeKitManager.purchaseState == .inFlight)

            switch storeKitManager.purchaseState {
            case .failed(let message):
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.red)
            case .pending:
                Text("Awaiting purchase confirmation…")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            case .inFlight:
                ProgressView()
            case .purchased:
                Text("Thanks for supporting Subuddy!")
                    .font(.footnote)
                    .foregroundStyle(.green)
            default:
                EmptyView()
            }
        }
    }

    private func purchase() {
        Task {
            await storeKitManager.purchaseAdFree()
        }
    }

    private func restore() {
        Task {
            await storeKitManager.restorePurchases()
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(StoreKitManager())
    }
}
#endif
