import Foundation

public struct EntitlementState: Codable, Equatable {
    public var hasAdFreeAccess: Bool
    public var latestTransactionID: String?

    public init(hasAdFreeAccess: Bool = false, latestTransactionID: String? = nil) {
        self.hasAdFreeAccess = hasAdFreeAccess
        self.latestTransactionID = latestTransactionID
    }
}

public protocol EntitlementPersisting {
    func load() -> EntitlementState
    func save(_ state: EntitlementState)
}

public final class UserDefaultsEntitlementStore: EntitlementPersisting {
    private let defaults: UserDefaults
    private let storageKey = "com.subuddy.entitlement"

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    public func load() -> EntitlementState {
        guard let data = defaults.data(forKey: storageKey) else {
            return EntitlementState()
        }

        do {
            return try JSONDecoder().decode(EntitlementState.self, from: data)
        } catch {
            defaults.removeObject(forKey: storageKey)
            return EntitlementState()
        }
    }

    public func save(_ state: EntitlementState) {
        do {
            let data = try JSONEncoder().encode(state)
            defaults.set(data, forKey: storageKey)
        } catch {
#if DEBUG
            assertionFailure("Failed to persist entitlement: \(error)")
#endif
        }
    }
}
