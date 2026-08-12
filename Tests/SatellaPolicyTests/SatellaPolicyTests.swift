import XCTest
@testable import SatellaPolicy

final class SatellaPolicyTests: XCTestCase {
    private let labBundleID = "emt.paisseon.satellalab"

    func testAuthorizedSelectedEnabledTargetIsActive() {
        let policy = makePolicy()
        XCTAssertTrue(policy.shouldOverrideStoreKit(in: labBundleID))
    }

    func testAuthorizedButUnselectedTargetIsInactive() {
        let policy = makePolicy(selected: [])
        XCTAssertFalse(policy.shouldOverrideStoreKit(in: labBundleID))
    }

    func testSelectedButUnauthorizedTargetIsInactive() {
        let policy = makePolicy(authorized: [])
        XCTAssertFalse(policy.shouldOverrideStoreKit(in: labBundleID))
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
            authorizedBundleIDs: [appleBundle],
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
        authorized: Set<String>? = nil,
        selected: Set<String>? = nil
    ) -> SatellaPolicy {
        SatellaPolicy(
            isEnabled: isEnabled,
            authorizedBundleIDs: authorized ?? [labBundleID],
            selectedBundleIDs: selected ?? [labBundleID]
        )
    }
}
