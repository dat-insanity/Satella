import Foundation
import StoreKit

@MainActor
final class StoreKit2Lab: ObservableObject {
    @Published private(set) var products: [Product] = []
    @Published private(set) var log = "Ready for StoreKit 2 testing."

    var productSummaries: [String] {
        products.map { "\($0.id) — \($0.displayPrice)" }
    }

    func loadProducts() async {
        do {
            products = try await Product.products(for: LabProducts.all).sorted { $0.id < $1.id }
            append("Loaded \(products.count) StoreKit 2 product(s)")
        } catch {
            append("Product request failed: \(error.localizedDescription)")
        }
    }

    func purchase(_ productID: String) async {
        guard let product = products.first(where: { $0.id == productID }) else {
            append("Load products before purchasing \(productID)")
            return
        }

        do {
            switch try await product.purchase() {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    append("Verified StoreKit 2 purchase \(transaction.productID)")
                    await transaction.finish()
                case .unverified(let transaction, let error):
                    append("Unverified transaction \(transaction.productID): \(error.localizedDescription)")
                }
            case .pending:
                append("StoreKit 2 purchase is pending")
            case .userCancelled:
                append("StoreKit 2 purchase was cancelled")
            @unknown default:
                append("Unknown StoreKit 2 purchase result")
            }
        } catch {
            append("StoreKit 2 purchase failed: \(error.localizedDescription)")
        }
    }

    func restoreAndRefresh() async {
        do {
            try await AppStore.sync()
            append("App Store sync completed")
        } catch {
            append("App Store sync failed: \(error.localizedDescription)")
        }

        var entitlements: [String] = []
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                entitlements.append(transaction.productID)
            }
        }
        append("Current entitlements: \(entitlements.sorted().joined(separator: ", "))")
    }

    func startTransactionListener() async {
        guard listenerTask == nil else {
            return
        }
        listenerTask = Task { [weak self] in
            for await result in Transaction.updates {
                guard !Task.isCancelled else { return }
                if case .verified(let transaction) = result {
                    await self?.recordUpdate(transaction)
                    await transaction.finish()
                }
            }
        }
        append("StoreKit 2 transaction listener started")
    }

    private func recordUpdate(_ transaction: Transaction) {
        append("Transaction update: \(transaction.productID)")
    }

    private func append(_ message: String) {
        log += "\n\(message)"
        NSLog("[SatellaLab][SK2] %@", message)
    }

    private var listenerTask: Task<Void, Never>?
}
