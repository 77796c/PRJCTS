import XCTest
@testable import SubuddyCore

final class EntitlementStoreTests: XCTestCase {
    func testPersistingEntitlementStateRoundTrips() throws {
        let suiteName = "entitlement-test-suite-\(UUID().uuidString)"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            XCTFail("Unable to create UserDefaults suite")
            return
        }
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let store = UserDefaultsEntitlementStore(defaults: defaults)
        let state = EntitlementState(hasAdFreeAccess: true, latestTransactionID: "12345")

        store.save(state)

        let restored = store.load()
        XCTAssertEqual(restored.hasAdFreeAccess, true)
        XCTAssertEqual(restored.latestTransactionID, "12345")
    }

    func testCorruptedDataResetsEntitlement() throws {
        let suiteName = "entitlement-test-suite-\(UUID().uuidString)"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            XCTFail("Unable to create UserDefaults suite")
            return
        }
        defer { defaults.removePersistentDomain(forName: suiteName) }

        defaults.set(Data([0x00, 0x01, 0x02]), forKey: "com.subuddy.entitlement")

        let store = UserDefaultsEntitlementStore(defaults: defaults)
        let restored = store.load()

        XCTAssertFalse(restored.hasAdFreeAccess)
        XCTAssertNil(restored.latestTransactionID)
    }
}
