import Foundation
import StoreKit
import Combine

@MainActor
class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    
    // Published properties
    @Published var isPremium: Bool = false // 正式版本：默认非会员
    @Published var subscriptionType: SubscriptionType = .none // 正式版本：无订阅
    @Published var expirationDate: Date?
    @Published var isLoading: Bool = false
    
    // Product IDs - 匹配 Configuration.storekit 中的配置
    enum ProductID: String, CaseIterable {
        case monthly = "lumea.plus.monthly"
        case yearly = "lumea.plus.annual"
        case lifetime = "lumea.plus.lifetime"
    }
    
    enum SubscriptionType: String {
        case none
        case monthly
        case yearly
        case lifetime
    }
    
    private var products: [Product] = []
    private var purchasedProductIDs: Set<String> = []
    private var updateListenerTask: Task<Void, Error>?
    
    private init() {
        // Start listening for transaction updates
        updateListenerTask = listenForTransactions()
        
        Task {
            await loadProducts()
            await updateSubscriptionStatus()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Load Products
    
    func loadProducts() async {
        do {
            let productIDs = ProductID.allCases.map { $0.rawValue }
            print("🔍 Attempting to load products with IDs: \(productIDs)")
            products = try await Product.products(for: productIDs)
            print("✅ Loaded \(products.count) products")
            for product in products {
                print("  - \(product.id): \(product.displayName) - \(product.displayPrice)")
            }
        } catch {
            print("❌ Failed to load products: \(error)")
            print("   Error details: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Get Product
    
    func getProduct(for productID: ProductID) -> Product? {
        return products.first { $0.id == productID.rawValue }
    }
    
    func getPrice(for productID: ProductID) -> String {
        // If we have the product, return its price
        if let product = getProduct(for: productID) {
            return product.displayPrice
        }
        
        // Return fallback price if product not loaded
        switch productID {
        case .monthly:
            return "$8.99"
        case .yearly:
            return "$69.99"
        case .lifetime:
            return "$129.99"
        }
    }
    
    // MARK: - Purchase
    
    func purchase(_ productID: ProductID) async throws -> Bool {
        guard let product = getProduct(for: productID) else {
            throw SubscriptionError.productNotFound
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                // Verify the transaction
                let transaction = try checkVerified(verification)
                
                // Update subscription status
                await updateSubscriptionStatus()
                
                // Finish the transaction
                await transaction.finish()
                
                return true
                
            case .userCancelled:
                return false
                
            case .pending:
                return false
                
            @unknown default:
                return false
            }
        } catch {
            print("❌ Purchase failed: \(error)")
            throw error
        }
    }
    
    // MARK: - Restore Purchases
    
    func restorePurchases() async throws {
        isLoading = true
        defer { isLoading = false }
        
        try await AppStore.sync()
        await updateSubscriptionStatus()
    }
    
    // MARK: - Update Subscription Status
    
    func updateSubscriptionStatus() async {
        var activeSubscription: SubscriptionType = .none
        var latestExpirationDate: Date?
        
        // Check for current entitlements
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                
                // Check if transaction is valid
                if let expirationDate = transaction.expirationDate {
                    if expirationDate > Date() {
                        // Active subscription
                        if let type = SubscriptionType(rawValue: getSubscriptionType(from: transaction.productID)) {
                            activeSubscription = type
                            latestExpirationDate = expirationDate
                        }
                    }
                } else {
                    // Lifetime purchase (no expiration)
                    if transaction.productID == ProductID.lifetime.rawValue {
                        activeSubscription = .lifetime
                        latestExpirationDate = nil
                    }
                }
                
                purchasedProductIDs.insert(transaction.productID)
            } catch {
                print("❌ Transaction verification failed: \(error)")
            }
        }
        
        // Update published properties
        isPremium = activeSubscription != .none
        subscriptionType = activeSubscription
        expirationDate = latestExpirationDate
        
        print("📱 Subscription Status: \(subscriptionType.rawValue), Premium: \(isPremium)")
    }
    
    // MARK: - Listen for Transactions
    
    private nonisolated func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try Self.checkVerifiedStatic(result)
                    await SubscriptionManager.shared.updateSubscriptionStatus()
                    await transaction.finish()
                } catch {
                    print("❌ Transaction update failed: \(error)")
                }
            }
        }
    }
    
    private nonisolated static func checkVerifiedStatic<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw SubscriptionError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    // MARK: - Verification
    
    private nonisolated func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw SubscriptionError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    // MARK: - Helper
    
    private func getSubscriptionType(from productID: String) -> String {
        if productID.contains("monthly") {
            return "monthly"
        } else if productID.contains("yearly") {
            return "yearly"
        } else if productID.contains("lifetime") {
            return "lifetime"
        }
        return "none"
    }
    
    // MARK: - Check Feature Access
    
    func hasAccessToFeature(_ feature: PremiumFeature) -> Bool {
        return isPremium
    }
    
    func hasAccessToMaterial(_ material: String) -> Bool {
        // 免费材质：default, lava, ice, gold
        let freeMaterials = ["default", "lava", "ice", "gold"]
        if freeMaterials.contains(material) {
            return true
        }
        // 其他材质需要会员
        return isPremium
    }
    
    enum PremiumFeature {
        case allSphereMaterials
        case premiumMusic
        case advancedAnalytics
        case customization
    }
}

// MARK: - Errors

enum SubscriptionError: LocalizedError {
    case productNotFound
    case failedVerification
    case purchaseFailed
    
    var errorDescription: String? {
        switch self {
        case .productNotFound:
            return "未找到该产品"
        case .failedVerification:
            return "购买验证失败"
        case .purchaseFailed:
            return "购买失败，请稍后重试"
        }
    }
}
