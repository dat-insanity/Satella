import Foundation

public struct SatellaPolicy: Sendable {
    public init(
        isEnabled: Bool,
        authorizedBundleIDs: Set<String>,
        selectedBundleIDs: Set<String>
    ) {
        self.isEnabled = isEnabled
        self.authorizedBundleIDs = authorizedBundleIDs
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

        return authorizedBundleIDs.contains(bundleID)
            && selectedBundleIDs.contains(bundleID)
    }

    public let isEnabled: Bool
    public let authorizedBundleIDs: Set<String>
    public let selectedBundleIDs: Set<String>
}
