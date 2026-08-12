import CoreFoundation
import Foundation
import UIKit

struct PrefsHelper {
    static let authorizedBundleIDs: [String] = SatellaPrefsAuthorizedBundleIdentifiers()

    static var altListSections: NSArray {
        guard !authorizedBundleIDs.isEmpty else { return [] }

        let quoted = authorizedBundleIDs
            .map { "'\($0.replacingOccurrences(of: "'", with: "\\'"))'" }
            .joined(separator: ",")
        return [[
            "sectionType": "Custom",
            "sectionName": "Allowlisted Apps",
            "sectionPredicate": "applicationIdentifier IN {\(quoted)}"
        ]] as NSArray
    }

    static func getValue(for key: String, fallback: Any? = nil) -> Any? {
        read()[key] ?? fallback
    }

    @discardableResult
    static func writeAndNotify() -> Bool {
        CFPreferencesAppSynchronize(cfDomain)
        let wrote = SatellaPrefsMirrorPreferences(read())
        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDarwinNotifyCenter(),
            CFNotificationName(preferenceNotification),
            nil,
            nil,
            true
        )
        return wrote
    }

    static func respring(withView view: UIView) {
        typealias RelaunchType = @convention(c) (AnyObject, Selector, String, Int, URL) -> NSObject
        let actionSelector = sel_registerName("actionWithReason:options:targetURL:")

        guard let actionObject = objc_getClass("SBSRelaunchAction") as? NSObject.Type,
              let actionClass = objc_getMetaClass("SBSRelaunchAction") as? AnyClass,
              let serviceObject = objc_getClass("FBSSystemService") as? NSObject.Type,
              let service = serviceObject.perform(sel_registerName("sharedService")).takeUnretainedValue() as? NSObject,
              let relaunch: RelaunchType = implementation(for: actionClass, selector: actionSelector),
              let returnURL = URL(string: "prefs:root=Tweaks&path=Satella")
        else {
            return
        }

        let action = relaunch(actionObject, actionSelector, "RestartRenderServer", 1 << 2, returnURL)
        let serviceSelector = sel_registerName("sendActions:withResult:")
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterialDark))
        blurView.frame = UIScreen.main.bounds
        blurView.alpha = 0
        view.window?.rootViewController?.view.addSubview(blurView)
        UIView.animate(withDuration: 1, animations: { blurView.alpha = 1 }) { _ in
            service.perform(serviceSelector, with: NSSet(object: action), with: nil)
        }
    }

    private static func read() -> [String: Any] {
        let keyList = CFPreferencesCopyKeyList(
            cfDomain,
            kCFPreferencesCurrentUser,
            kCFPreferencesAnyHost
        ) ?? CFArrayCreate(nil, nil, 0, nil)
        let dictionary = CFPreferencesCopyMultiple(
            keyList,
            cfDomain,
            kCFPreferencesCurrentUser,
            kCFPreferencesAnyHost
        )
        return dictionary as? [String: Any] ?? [:]
    }

    private static func implementation<T>(for cls: AnyClass, selector: Selector) -> T? {
        guard let method = class_getClassMethod(cls, selector) ?? class_getInstanceMethod(cls, selector) else {
            return nil
        }
        return unsafeBitCast(method_getImplementation(method), to: T?.self)
    }

    private static let cfDomain = "emt.paisseon.satella" as CFString
    private static let preferenceNotification = "emt.paisseon.satella.prefschanged" as CFString
}
