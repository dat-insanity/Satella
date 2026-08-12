import Foundation
import StoreKit

@MainActor
final class StoreKit1Lab: NSObject, ObservableObject {
    @Published private(set) var products: [SKProduct] = []
    @Published private(set) var log = "Ready for StoreKit 1 testing."

    var productSummaries: [String] {
        products.map { "\($0.productIdentifier) — \($0.priceLocale.currencySymbol ?? "")\($0.price)" }
    }

    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }

    deinit {
        SKPaymentQueue.default().remove(self)
    }

    func loadProducts() {
        append("Requesting StoreKit 1 products")
        let request = SKProductsRequest(productIdentifiers: Set(LabProducts.all))
        request.delegate = self
        productRequest = request
        request.start()
    }

    func purchase(_ productID: String) {
        guard let product = products.first(where: { $0.productIdentifier == productID }) else {
            append("Load products before purchasing \(productID)")
            return
        }
        append("Adding StoreKit 1 payment for \(productID)")
        SKPaymentQueue.default().add(SKPayment(product: product))
    }

    func restorePurchases() {
        append("Requesting StoreKit 1 restore")
        SKPaymentQueue.default().restoreCompletedTransactions()
    }

    private func append(_ message: String) {
        log += "\n\(message)"
        NSLog("[SatellaLab][SK1] %@", message)
    }

    private var productRequest: SKProductsRequest?
}

extension StoreKit1Lab: SKProductsRequestDelegate {
    nonisolated func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        Task { @MainActor in
            products = response.products.sorted { $0.productIdentifier < $1.productIdentifier }
            append("Loaded \(products.count) product(s); invalid: \(response.invalidProductIdentifiers.count)")
            productRequest = nil
        }
    }

    nonisolated func request(_ request: SKRequest, didFailWithError error: Error) {
        Task { @MainActor in
            append("Product request failed: \(error.localizedDescription)")
            productRequest = nil
        }
    }
}

extension StoreKit1Lab: SKPaymentTransactionObserver {
    nonisolated func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        Task { @MainActor in
            for transaction in transactions {
                let productID = transaction.payment.productIdentifier
                switch transaction.transactionState {
                case .purchasing:
                    append("Purchasing \(productID)")
                case .deferred:
                    append("Deferred \(productID)")
                case .failed:
                    append("Failed \(productID): \(transaction.error?.localizedDescription ?? "unknown error")")
                    queue.finishTransaction(transaction)
                case .purchased:
                    append("Purchased \(productID), transaction \(transaction.transactionIdentifier ?? "unknown")")
                    queue.finishTransaction(transaction)
                case .restored:
                    append("Restored \(productID)")
                    queue.finishTransaction(transaction)
                @unknown default:
                    append("Unknown transaction state for \(productID)")
                }
            }
        }
    }

    nonisolated func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        Task { @MainActor in
            append("Restore completed")
        }
    }
}
