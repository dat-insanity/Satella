import Preferences
import UIKit

final class RootListController: PSListController {
    override var specifiers: NSMutableArray? {
        get {
            if let specifiers = value(forKey: "_specifiers") as? NSMutableArray {
                return specifiers
            }

            var specifiers = NSMutableArray()
            SpecifierFactory.add([
                GroupCell(name: "General", footerText: "Changes apply immediately to running enabled apps; newly selected apps must be relaunched."),
                ToggleCell(name: "Enable StoreKit 1 Lab", key: "isEnabled", defaultValue: true)
            ], to: &specifiers, in: self)

            if PrefsHelper.getValue(for: "isEnabled", fallback: true) as? Bool == true {
                addFeatureSpecifiers(to: &specifiers)
            }

            SpecifierFactory.add([
                GroupCell(name: "App Selection", footerText: "Select the installed apps where Satella should be enabled."),
                AppsCell(name: "Enabled Apps", key: "apps", defaultValue: false),
                GroupCell(name: "Links", footerText: "StoreKit 2 testing uses Apple's signed StoreKit Test transactions; Satella does not modify JWS data."),
                ButtonCell(name: "Source Code", action: #selector(openSource))
            ], to: &specifiers, in: self)

            setValue(specifiers, forKey: "_specifiers")
            return specifiers
        }
        set { super.specifiers = newValue }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Satella 2 Lab"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Apply",
            style: .done,
            target: self,
            action: #selector(applyPreferences)
        )
        table.tableHeaderView = HeaderView(style: .default, reuseIdentifier: "HeaderCell")
    }

    override func setPreferenceValue(_ value: Any, specifier: PSSpecifier) {
        super.setPreferenceValue(value, specifier: specifier)
        PrefsHelper.writeAndNotify()

        guard specifier.identifier == "isEnabled" else {
            return
        }

        if value as? Bool == true {
            var additions = NSMutableArray()
            addFeatureSpecifiers(to: &additions)
            insertContiguousSpecifiers(additions as? [Any], afterSpecifierID: "isEnabled", animated: true)
        } else {
            let hidden = specifiers(forIDs: ["isReceipt", "isObserver", "isPriceZero"])
            removeContiguousSpecifiers(hidden, animated: true)
        }
    }

    private func addFeatureSpecifiers(to specifiers: inout NSMutableArray) {
        SpecifierFactory.add([
            ToggleCell(name: "Legacy Transaction Receipt", key: "isReceipt", defaultValue: false),
            ToggleCell(name: "Observer Proxy", key: "isObserver", defaultValue: false),
            ToggleCell(name: "0.01 Test Price", key: "isPriceZero", defaultValue: false)
        ], to: &specifiers, in: self)
    }

    @objc private func applyPreferences() {
        let wrote = PrefsHelper.writeAndNotify()
        let message = wrote
            ? "Preferences were mirrored to the Dopamine rootless environment. Relaunch newly selected test apps."
            : "Satella could not mirror its preferences. Check the device log before testing."
        let alert = UIAlertController(
            title: wrote ? "Preferences Applied" : "Apply Failed",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc private func openSource() {
        guard let url = URL(string: "https://github.com/dat-insanity/Satella") else {
            return
        }
        UIApplication.shared.open(url)
    }
}
