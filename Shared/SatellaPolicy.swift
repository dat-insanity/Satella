import Foundation

public struct SatellaPolicy: Sendable {
    public init(
        isEnabled: Bool,
        selectedBundleIDs: Set<String>
    ) {
        self.isEnabled = isEnabled
        self.selectedBundleIDs = selectedBundleIDs
    }

    public func shouldOverrideStoreKit(in bundleID: String?) -> Bool {
        guard isEnabled,
              let bundleID,
              !bundleID.isEmpty,
              !bundleID.hasPrefix("com.apple.")
        else {
            return false
        }

        return selectedBundleIDs.contains(bundleID)
    }

    public let isEnabled: Bool
    public let selectedBundleIDs: Set<String>
}
