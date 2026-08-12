import Foundation
import StoreKit

struct Tweak {
    static func ctor() {
        guard CommandLine.arguments[0].hasPrefix("/var/containers/Bundle/Application"),
              Preferences.start()
        else {
            return
        }

        SatellaInstallHooks()
        NSLog("[Satella] Active in %@", Bundle.main.bundleIdentifier ?? "unknown bundle")
    }
}

@objc(SATRuntime)
final class SatellaRuntime: NSObject {
    @objc(runtimeActive)
    static func runtimeActive() -> Bool { Preferences.shouldInject }

    @objc(priceOverrideEnabled)
    static func priceOverrideEnabled() -> Bool { Preferences.snapshot.isPriceZero }

    @objc(receiptOverrideEnabled)
    static func receiptOverrideEnabled() -> Bool { Preferences.snapshot.isReceipt }

    @objc(observerOverrideEnabled)
    static func observerOverrideEnabled() -> Bool { Preferences.snapshot.isObserver }

    @objc(sideloadedOverrideEnabled)
    static func sideloadedOverrideEnabled() -> Bool { Preferences.snapshot.isSideloaded }

    @objc(stealthOverrideEnabled)
    static func stealthOverrideEnabled() -> Bool { Preferences.snapshot.isStealth }

    @objc(receiptForTransaction:)
    static func receipt(for transaction: SKPaymentTransaction) -> Data? {
        let receipt = ReceiptGenerator.old(for: transaction.payment.productIdentifier)
        return try? JSONEncoder().encode(receipt)
    }

    @objc(receiptResponse)
    static func receiptResponse() -> Data? {
        ReceiptGenerator.response(for: SatellaDelegate.shared.products.last?.productIdentifier ?? "")
    }

    @objc(observerProxyForObserver:)
    static func observerProxy(for observer: AnyObject) -> AnyObject? {
        guard let observer = observer as? SKPaymentTransactionObserver else { return nil }
        SatellaObserver.shared.add(observer)
        return SatellaObserver.shared
    }

    @objc(delegateProxyForDelegate:)
    static func delegateProxy(for delegate: AnyObject) -> AnyObject? {
        guard let delegate = delegate as? SKProductsRequestDelegate else { return nil }
        SatellaDelegate.shared.add(delegate)
        return SatellaDelegate.shared
    }
}

@_cdecl("satella_entry")
func satellaEntry() {
    Tweak.ctor()
}
