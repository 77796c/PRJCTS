#if canImport(StoreKit)
import StoreKit
import SwiftUI

@MainActor
public final class StoreKitManager: ObservableObject {
    public enum PurchaseState: Equatable {
        case idle
        case inFlight
        case pending
        case purchased
        case failed(String)
    }

    public static let adFreeProductIdentifier = "com.subuddy.adfree"

    @Published public private(set) var products: [Product] = []
    @Published public private(set) var entitlementState: EntitlementState
    @Published public private(set) var purchaseState: PurchaseState = .idle

    private let entitlementStore: EntitlementPersisting
    private var updatesTask: Task<Void, Never>?

    public init(entitlementStore: EntitlementPersisting = UserDefaultsEntitlementStore()) {
        self.entitlementStore = entitlementStore
        self.entitlementState = entitlementStore.load()
        updatesTask = Task { [weak self] in
            await self?.listenForTransactions()
        }
        Task {
            await requestProducts()
            await refreshEntitlementStatus()
        }
    }

    deinit {
        updatesTask?.cancel()
    }

    @discardableResult
    public func requestProducts() async -> [Product] {
        do {
            let storeProducts = try await Product.products(for: [Self.adFreeProductIdentifier])
            let sorted = storeProducts.sorted { $0.displayName < $1.displayName }
            products = sorted
            return sorted
        } catch {
            purchaseState = .failed("Unable to load products: \(error.localizedDescription)")
            products = []
            return []
        }
    }

    public func purchaseAdFree() async {
        guard let product = products.first(where: { $0.id == Self.adFreeProductIdentifier }) else {
            purchaseState = .failed("Ad-free product unavailable")
            return
        }

        purchaseState = .inFlight

        do {
            let result = try await product.purchase(options: [.simulatesAskToBuyInSandbox(false)])
            switch result {
            case .success(let verification):
                try await handleVerifiedTransaction(verification)
                purchaseState = .purchased
            case .userCancelled:
                purchaseState = .idle
            case .pending:
                purchaseState = .pending
            @unknown default:
                purchaseState = .failed("Unknown purchase result")
            }
        } catch {
            purchaseState = .failed(error.localizedDescription)
        }
    }

    public func restorePurchases() async {
        purchaseState = .inFlight
        do {
            try await AppStore.sync()
            await refreshEntitlementStatus()
            purchaseState = entitlementState.hasAdFreeAccess ? .purchased : .idle
        } catch {
            purchaseState = .failed(error.localizedDescription)
        }
    }

    public func refreshEntitlementStatus() async {
        var entitlement = EntitlementState()

        for await result in Transaction.currentEntitlements {
            guard result.productID == Self.adFreeProductIdentifier else { continue }
            do {
                let transaction = try checkVerified(result)
                entitlement.hasAdFreeAccess = true
                entitlement.latestTransactionID = String(transaction.id)
            } catch {
                continue
            }
        }

        applyEntitlement(entitlement)
    }

    private func listenForTransactions() async {
        for await update in Transaction.updates {
            guard update.productID == Self.adFreeProductIdentifier else { continue }
            do {
                try await handleVerifiedTransaction(update)
                purchaseState = .purchased
            } catch {
                purchaseState = .failed(error.localizedDescription)
            }
        }
    }

    private func handleVerifiedTransaction(_ result: VerificationResult<Transaction>) async throws {
        let transaction = try checkVerified(result)
        applyEntitlement(EntitlementState(hasAdFreeAccess: true, latestTransactionID: String(transaction.id)))
        await transaction.finish()
    }

    private func applyEntitlement(_ state: EntitlementState) {
        entitlementState = state
        entitlementStore.save(state)
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreKitError.verificationFailed
        case .verified(let signedType):
            return signedType
        }
    }

    enum StoreKitError: LocalizedError {
        case verificationFailed

        var errorDescription: String? {
            switch self {
            case .verificationFailed:
                return "Unable to verify transaction signature."
            }
        }
    }
}

#else
import Foundation

public final class StoreKitManager {
    public enum PurchaseState: Equatable {
        case idle
        case inFlight
        case pending
        case purchased
        case failed(String)
    }

    public private(set) var products: [Any] = []
    public private(set) var entitlementState: EntitlementState
    public private(set) var purchaseState: PurchaseState = .idle

    private let entitlementStore: EntitlementPersisting

    public init(entitlementStore: EntitlementPersisting = UserDefaultsEntitlementStore()) {
        self.entitlementStore = entitlementStore
        self.entitlementState = entitlementStore.load()
    }

    public func requestProducts() async -> [Any] { [] }

    public func purchaseAdFree() async {
        entitlementState = EntitlementState(hasAdFreeAccess: true)
        purchaseState = .purchased
        entitlementStore.save(entitlementState)
    }

    public func restorePurchases() async {
        entitlementState = entitlementStore.load()
        purchaseState = entitlementState.hasAdFreeAccess ? .purchased : .idle
    }
}
#endif
