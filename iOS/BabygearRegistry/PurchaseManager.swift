import Foundation
import StoreKit

@MainActor
final class PurchaseManager: ObservableObject {
    static let productId = "com.shimondeitel.babygearregistry.pro"

    @Published var isPro: Bool = false
    @Published var product: Product?

    private var updatesTask: Task<Void, Never>?

    init() {
        updatesTask = Task { [weak self] in
            for await update in Transaction.updates {
                if case .verified(let transaction) = update {
                    await transaction.finish()
                    await self?.refresh()
                }
            }
        }
        Task { await load() }
    }

    deinit {
        updatesTask?.cancel()
    }

    func load() async {
        if let products = try? await Product.products(for: [Self.productId]), let p = products.first {
            product = p
        }
        await refresh()
    }

    func purchase() async {
        guard let product else { return }
        if let result = try? await product.purchase() {
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    await transaction.finish()
                    await refresh()
                }
            default:
                break
            }
        }
    }

    func restore() async {
        try? await AppStore.sync()
        await refresh()
    }

    func refresh() async {
        var active = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result, transaction.productID == Self.productId {
                active = true
            }
        }
        isPro = active
    }
}
