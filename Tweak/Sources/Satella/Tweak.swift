import Foundation
import StoreKit

struct Tweak {
    static func ctor() {
        guard Preferences.start() else {
            return
        }

        SatellaInstallHooks()
        NSLog("[Satella] Active in %@", Bundle.main.bundleIdentifier ?? "unknown bundle")
    }
}

@objc(SATRuntime)
final class SatellaRuntime: NSObject {
    @objc(runtimeActive)
    static func runtimeActive() -> Bool {
        Preferences.shouldOverrideStoreKit
    }

    @objc(priceOverrideEnabled)
    static func priceOverrideEnabled() -> Bool {
        Preferences.snapshot.isPriceZero
    }

    @objc(receiptOverrideEnabled)
    static func receiptOverrideEnabled() -> Bool {
        Preferences.snapshot.isReceipt
    }

    @objc(observerOverrideEnabled)
    static func observerOverrideEnabled() -> Bool {
        Preferences.snapshot.isObserver
    }

    @objc(receiptForTransaction:)
    static func receipt(for transaction: SKPaymentTransaction) -> Data? {
        let receipt = ReceiptGenerator.old(for: transaction.payment.productIdentifier)
        return try? JSONEncoder().encode(receipt)
    }

    @objc(observerProxyForObserver:)
    static func observerProxy(for observer: AnyObject) -> AnyObject? {
        guard let observer = observer as? SKPaymentTransactionObserver else {
            return nil
        }
        SatellaObserver.shared.add(observer)
        return SatellaObserver.shared
    }
}

@_cdecl("satella_entry")
func satellaEntry() {
    Tweak.ctor()
}
