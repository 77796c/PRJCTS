#if canImport(SwiftUI) && canImport(StoreKit)
import SwiftUI
#if canImport(SubuddyCore)
import SubuddyCore
#endif

struct BannerAdView: View {
    @EnvironmentObject private var storeKitManager: StoreKitManager

    var body: some View {
        Group {
            if storeKitManager.entitlementState.hasAdFreeAccess {
                EmptyView()
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Enjoy Subuddy without ads")
                        .font(.headline)
                    Text("Unlock the full experience for a one-time $2.99 purchase.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    HStack {
                        Button(action: purchase) {
                            Label("Remove Ads", systemImage: "cart")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(storeKitManager.purchaseState == .inFlight || storeKitManager.purchaseState == .pending)

                        Button("Restore", action: restore)
                            .frame(maxWidth: .infinity)
                    }

                    if case .failed(let message) = storeKitManager.purchaseState {
                        Text(message)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }

                    if storeKitManager.purchaseState == .inFlight || storeKitManager.purchaseState == .pending {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding()
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                )
                .padding(.horizontal)
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.easeInOut(duration: 0.3), value: storeKitManager.entitlementState.hasAdFreeAccess)
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
    BannerAdView()
        .environmentObject(StoreKitManager())
}
#endif
