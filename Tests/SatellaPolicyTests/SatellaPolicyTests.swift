import XCTest
@testable import SatellaPolicy

final class SatellaPolicyTests: XCTestCase {
    private let labBundleID = "emt.paisseon.satellalab"

    func testSelectedEnabledTargetIsActive() {
        let policy = makePolicy()
        XCTAssertTrue(policy.shouldOverrideStoreKit(in: labBundleID))
    }

    func testUnselectedTargetIsInactive() {
        let policy = makePolicy(selected: [])
        XCTAssertFalse(policy.shouldOverrideStoreKit(in: labBundleID))
    }

    func testAnySelectedUserTargetCanBeActive() {
        let bundleID = "org.example.application"
        let policy = makePolicy(selected: [bundleID])
        XCTAssertTrue(policy.shouldOverrideStoreKit(in: bundleID))
    }

    func testDisabledTargetIsInactive() {
        let policy = makePolicy(isEnabled: false)
        XCTAssertFalse(policy.shouldOverrideStoreKit(in: labBundleID))
    }

    func testEmptyBundleIdentifierIsInactive() {
        let policy = makePolicy()
        XCTAssertFalse(policy.shouldOverrideStoreKit(in: nil))
        XCTAssertFalse(policy.shouldOverrideStoreKit(in: ""))
    }

    func testAppleBundleIsAlwaysInactive() {
        let appleBundle = "com.apple.Preferences"
        let policy = SatellaPolicy(
            isEnabled: true,
            selectedBundleIDs: [appleBundle]
        )
        XCTAssertFalse(policy.shouldOverrideStoreKit(in: appleBundle))
    }

    func testLegacyGlobalInjectionCannotActivateAnUnselectedTarget() {
        let policy = makePolicy(selected: [])
        XCTAssertFalse(policy.shouldOverrideStoreKit(in: labBundleID))
    }

    private func makePolicy(
        isEnabled: Bool = true,
        selected: Set<String>? = nil
    ) -> SatellaPolicy {
        SatellaPolicy(
            isEnabled: isEnabled,
            selectedBundleIDs: selected ?? [labBundleID]
        )
    }
}
