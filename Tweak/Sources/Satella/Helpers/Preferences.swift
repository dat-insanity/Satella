import CoreFoundation
import Foundation

private let preferenceDomain = "emt.paisseon.satella"
private let preferenceNotification = "emt.paisseon.satella.prefschanged" as CFString

struct PreferencesSnapshot {
    let apps: Set<String>
    let isEnabled: Bool
    let isGloballyInjected: Bool
    let isObserver: Bool
    let isPriceZero: Bool
    let isReceipt: Bool
    let isSideloaded: Bool
    let isStealth: Bool

    static let disabled = PreferencesSnapshot(
        apps: [],
        isEnabled: false,
        isGloballyInjected: false,
        isObserver: false,
        isPriceZero: false,
        isReceipt: false,
        isSideloaded: false,
        isStealth: false
    )
}

enum Preferences {
    static var snapshot: PreferencesSnapshot {
        lock.lock()
        defer { lock.unlock() }
        return current
    }

    static var shouldInject: Bool {
        let values = snapshot
        guard values.isEnabled,
              let bundleID = Bundle.main.bundleIdentifier,
              !bundleID.hasPrefix("com.apple."),
              authorizedBundleIDs.contains(bundleID)
        else {
            return false
        }

        return values.isGloballyInjected || values.apps.contains(bundleID)
    }

    @discardableResult
    static func start() -> Bool {
        authorizedBundleIDs = Set(SatellaAuthorizedBundleIdentifiers())
        guard !authorizedBundleIDs.isEmpty else {
            NSLog("[Satella] Refusing to start without an authorized bundle filter")
            return false
        }

        reload()
        CFNotificationCenterAddObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            nil,
            preferencesDidChange,
            preferenceNotification,
            nil,
            .deliverImmediately
        )
        return shouldInject
    }

    fileprivate static func reload() {
        let path = SatellaRootPath("/var/mobile/Library/Preferences/\(preferenceDomain).plist")
        let dictionary = NSDictionary(contentsOfFile: path) as? [String: Any] ?? [:]
        let updated = PreferencesSnapshot(
            apps: Set(dictionary["apps"] as? [String] ?? []),
            isEnabled: dictionary["isEnabled"] as? Bool ?? true,
            isGloballyInjected: dictionary["isGloballyInjected"] as? Bool ?? false,
            isObserver: dictionary["isObserver"] as? Bool ?? false,
            isPriceZero: dictionary["isPriceZero"] as? Bool ?? false,
            isReceipt: dictionary["isReceipt"] as? Bool ?? false,
            isSideloaded: dictionary["isSideloaded"] as? Bool ?? false,
            isStealth: dictionary["isStealth"] as? Bool ?? false
        )

        lock.lock()
        current = updated
        lock.unlock()
    }

    private static let lock = NSLock()
    private static var current = PreferencesSnapshot.disabled
    private static var authorizedBundleIDs = Set<String>()
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
