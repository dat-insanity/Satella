import Foundation
import StoreKit

final class SatellaObserver: NSObject, SKPaymentTransactionObserver {
    static let shared = SatellaObserver()

    func add(_ observer: SKPaymentTransactionObserver) {
        lock.lock()
        defer { lock.unlock() }

        let object = observer as AnyObject
        if !observers.contains(object) {
            observers.add(object)
        }
    }

    func paymentQueue(
        _ queue: SKPaymentQueue,
        updatedTransactions transactions: [SKPaymentTransaction]
    ) {
        lock.lock()
        let freshTransactions = transactions.filter { transaction in
            if purchases.contains(transaction) {
                return false
            }
            purchases.add(transaction)
            return true
        }
        let targets = observers.allObjects
        lock.unlock()

        guard !freshTransactions.isEmpty else {
            return
        }

        for case let observer as SKPaymentTransactionObserver in targets {
            observer.paymentQueue(queue, updatedTransactions: freshTransactions)
        }
    }

    private let lock = NSLock()
    private let observers = NSHashTable<AnyObject>.weakObjects()
    private let purchases = NSHashTable<SKPaymentTransaction>.weakObjects()
}
