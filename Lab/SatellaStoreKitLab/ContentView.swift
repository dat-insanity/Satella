import SwiftUI

struct ContentView: View {
    @StateObject private var storeKit1 = StoreKit1Lab()
    @StateObject private var storeKit2 = StoreKit2Lab()
    @State private var selectedAPI = 0

    var body: some View {
        NavigationView {
            Form {
                Section("Runtime") {
                    HStack {
                        Text("Satella injected")
                        Spacer()
                        Text(injectionStatus).foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Bundle")
                        Spacer()
                        Text(Bundle.main.bundleIdentifier ?? "Unknown").foregroundColor(.secondary)
                    }
                }

                Section("API") {
                    Picker("StoreKit API", selection: $selectedAPI) {
                        Text("StoreKit 1").tag(0)
                        Text("StoreKit 2").tag(1)
                    }
                    .pickerStyle(.segmented)
                }

                Section("Actions") {
                    Button("Load Products") {
                        if selectedAPI == 0 {
                            storeKit1.loadProducts()
                        } else {
                            Task { await storeKit2.loadProducts() }
                        }
                    }
                    Button("Buy Consumable") {
                        purchase(LabProducts.consumable)
                    }
                    Button("Buy Non-Consumable") {
                        purchase(LabProducts.nonConsumable)
                    }
                    Button("Buy Monthly Subscription") {
                        purchase(LabProducts.monthlySubscription)
                    }
                    Button(selectedAPI == 0 ? "Restore Purchases" : "Sync and Refresh Entitlements") {
                        if selectedAPI == 0 {
                            storeKit1.restorePurchases()
                        } else {
                            Task { await storeKit2.restoreAndRefresh() }
                        }
                    }
                }

                Section("Products") {
                    let products = selectedAPI == 0 ? storeKit1.productSummaries : storeKit2.productSummaries
                    if products.isEmpty {
                        Text("No products loaded")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(products, id: \.self) { product in
                            Text(product)
                        }
                    }
                }

                Section("Event Log") {
                    Text(selectedAPI == 0 ? storeKit1.log : storeKit2.log)
                        .font(.system(.caption, design: .monospaced))
                        .textSelection(.enabled)
                }
            }
            .navigationTitle("Satella StoreKit Lab")
        }
        .task {
            await storeKit2.startTransactionListener()
        }
    }

    private var injectionStatus: String {
        NSClassFromString("SATRuntime") == nil ? "No" : "Yes"
    }

    private func purchase(_ productID: String) {
        if selectedAPI == 0 {
            storeKit1.purchase(productID)
        } else {
            Task { await storeKit2.purchase(productID) }
        }
    }
}
