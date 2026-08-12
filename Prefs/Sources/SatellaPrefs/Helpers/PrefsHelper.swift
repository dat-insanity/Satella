import CoreFoundation
import Foundation

enum PrefsHelper {
    static let authorizedBundleIDs: [String] = SatellaPrefsAuthorizedBundleIdentifiers()

    static var altListSections: NSArray {
        guard !authorizedBundleIDs.isEmpty else {
            return []
        }

        let quoted = authorizedBundleIDs
            .map { "'\($0.replacingOccurrences(of: "'", with: "\\'"))'" }
            .joined(separator: ",")
        let predicate = "applicationIdentifier IN {\(quoted)}"

        return [[
            "sectionType": "Custom",
            "sectionName": "Authorized Test Apps",
            "sectionPredicate": predicate
        ]] as NSArray
    }

    static func getValue(for key: String, fallback: Any? = nil) -> Any? {
        read()[key] ?? fallback
    }

    @discardableResult
    static func writeAndNotify() -> Bool {
        CFPreferencesAppSynchronize(preferenceDomain)
        let wrote = SatellaPrefsMirrorPreferences(read() as NSDictionary)
        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDarwinNotifyCenter(),
            CFNotificationName(preferenceNotification),
            nil,
            nil,
            true
        )
        return wrote
    }

    private static func read() -> [String: Any] {
        let keyList = CFPreferencesCopyKeyList(
            preferenceDomain,
            kCFPreferencesCurrentUser,
            kCFPreferencesAnyHost
        ) ?? CFArrayCreate(nil, nil, 0, nil)

        let dictionary = CFPreferencesCopyMultiple(
            keyList,
            preferenceDomain,
            kCFPreferencesCurrentUser,
            kCFPreferencesAnyHost
        )
        return dictionary as? [String: Any] ?? [:]
    }

    private static let preferenceDomain = "emt.paisseon.satella" as CFString
    private static let preferenceNotification = "emt.paisseon.satella.prefschanged" as CFString
}
