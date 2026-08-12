import CoreFoundation
import Foundation

private let preferenceDomain = "emt.paisseon.satella"
private let preferenceNotification = "emt.paisseon.satella.prefschanged" as CFString

struct PreferencesSnapshot {
    let apps: Set<String>
    let isEnabled: Bool
    let isObserver: Bool
    let isPriceZero: Bool
    let isReceipt: Bool

    static let disabled = PreferencesSnapshot(
        apps: [],
        isEnabled: false,
        isObserver: false,
        isPriceZero: false,
        isReceipt: false
    )
}

enum Preferences {
    static var snapshot: PreferencesSnapshot {
        lock.lock()
        defer { lock.unlock() }
        return current
    }

    static var shouldOverrideStoreKit: Bool {
        let values = snapshot
        let policy = SatellaPolicy(
            isEnabled: values.isEnabled,
            selectedBundleIDs: values.apps
        )
        return policy.shouldOverrideStoreKit(in: Bundle.main.bundleIdentifier)
    }

    @discardableResult
    static func start() -> Bool {
        reload()
        CFNotificationCenterAddObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            nil,
            preferencesDidChange,
            preferenceNotification,
            nil,
            .deliverImmediately
        )

        return shouldOverrideStoreKit
    }

    fileprivate static func reload() {
        let path = SatellaRootPath("/var/mobile/Library/Preferences/\(preferenceDomain).plist")
        let dictionary = NSDictionary(contentsOfFile: path) as? [String: Any] ?? [:]
        let updated = PreferencesSnapshot(
            apps: Set(dictionary["apps"] as? [String] ?? []),
            isEnabled: dictionary["isEnabled"] as? Bool ?? true,
            isObserver: dictionary["isObserver"] as? Bool ?? false,
            isPriceZero: dictionary["isPriceZero"] as? Bool ?? false,
            isReceipt: dictionary["isReceipt"] as? Bool ?? false
        )

        lock.lock()
        current = updated
        lock.unlock()
        NSLog("[Satella] Preferences reloaded")
    }

    private static let lock = NSLock()
    private static var current = PreferencesSnapshot.disabled
}

private func preferencesDidChange(
    _ center: CFNotificationCenter?,
    _ observer: UnsafeMutableRawPointer?,
    _ name: CFNotificationName?,
    _ object: UnsafeRawPointer?,
    _ userInfo: CFDictionary?
) {
    Preferences.reload()
}
