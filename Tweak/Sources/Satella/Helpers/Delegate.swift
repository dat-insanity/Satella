import Foundation
import StoreKit

final class SatellaDelegate: NSObject, SKProductsRequestDelegate {
    static let shared = SatellaDelegate()

    private(set) var products: [SKProduct] = []

    func add(_ delegate: SKProductsRequestDelegate) {
        lock.lock()
        defer { lock.unlock() }

        let object = delegate as AnyObject
        if !delegates.contains(object) {
            delegates.add(object)
        }
    }

    func productsRequest(
        _ request: SKProductsRequest,
        didReceive response: SKProductsResponse
    ) {
        lock.lock()
        let targets = delegates.allObjects
        lock.unlock()

        guard response.products.isEmpty else {
            for case let delegate as SKProductsRequestDelegate in targets {
                delegate.productsRequest(request, didReceive: response)
            }
            return
        }

        let identifiers = Array(SatellaProductIdentifiersForRequest(request)).sorted()
        let generated = identifiers.map { identifier -> SKProduct in
            let product = SKProduct()
            product.setValuesForKeys([
                "price": NSDecimalNumber(string: "0.01"),
                "priceLocale": Locale(identifier: "da_DK"),
                "productIdentifier": identifier,
                "localizedDescription": identifier,
                "localizedTitle": identifier
            ])
            return product
        }

        lock.lock()
        if products.isEmpty {
            products = generated
        }
        let currentProducts = products
        lock.unlock()

        let fakeResponse = SKProductsResponse()
        fakeResponse.setValue(currentProducts, forKey: "products")
        for case let delegate as SKProductsRequestDelegate in targets {
            delegate.productsRequest(request, didReceive: fakeResponse)
        }
    }

    private let lock = NSLock()
    private let delegates = NSHashTable<AnyObject>.weakObjects()
}
