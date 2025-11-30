import SwiftUI
import StoreKit

struct SubscriptionView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var selectedPlan: SubscriptionPlan = .yearly
    @State private var isProcessing = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    enum SubscriptionPlan {
        case monthly
        case yearly
        case lifetime
        
        var title: String {
            switch self {
            case .monthly: return L10n.subMonthlyTitle
            case .yearly: return L10n.subYearlyTitle
            case .lifetime: return L10n.subLifetimeTitle
            }
        }
        
        var productID: SubscriptionManager.ProductID {
            switch self {
            case .monthly: return .monthly
            case .yearly: return .yearly
            case .lifetime: return .lifetime
            }
        }
        
        var period: String {
            switch self {
            case .monthly: return L10n.subMonthlyPeriod
            case .yearly: return L10n.subYearlyPeriod
            case .lifetime: return ""
            }
        }
        
        var savings: String? {
            switch self {
            case .yearly: return L10n.subYearlySavings
            case .lifetime: return L10n.subLifetimeSavings
            default: return nil
            }
        }
        
        var badge: String? {
            switch self {
            case .yearly: return L10n.subRecommendedBadge
            default: return nil
            }
        }
    }
    
    // Feature Data
    struct FeatureItem: Identifiable {
        let id = UUID()
        let icon: String
        let title: String
        let description: String
    }
    
    let row1Features = [
        FeatureItem(icon: "music.note", title: L10n.subFeatureMusicTitle, description: L10n.subFeatureMusicDesc),
        FeatureItem(icon: "sparkles", title: L10n.subFeatureMaterialsTitle, description: L10n.subFeatureMaterialsDesc),
        FeatureItem(icon: "chart.xyaxis.line", title: L10n.subFeatureInsightsTitle, description: L10n.subFeatureInsightsDesc),
        FeatureItem(icon: "waveform.path.ecg", title: L10n.subFeatureFocusTitle, description: L10n.subFeatureFocusDesc)
    ]
    
    let row2Features = [
        FeatureItem(icon: "app.badge", title: L10n.subFeatureDistractionTitle, description: L10n.subFeatureDistractionDesc),
        FeatureItem(icon: "star.fill", title: L10n.subFeatureUpdatesTitle, description: L10n.subFeatureUpdatesDesc),
        FeatureItem(icon: "brain.head.profile", title: L10n.subFeatureCLITitle, description: L10n.subFeatureCLIDesc),
        FeatureItem(icon: "sparkles.rectangle.stack", title: L10n.subFeatureThemesTitle, description: L10n.subFeatureThemesDesc)
    ]
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.0, blue: 0.15),
                    Color.black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Content
            VStack(spacing: 0) {
                // Custom Navigation Bar
                HStack {
                    Spacer()
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white.opacity(0.6))
                            .padding(10)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        // 1. Header
                        VStack(spacing: 8) {
                            HStack(spacing: 0) {
                                Text(L10n.appName + " ")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.white, .white.opacity(0.9)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                
                                Text("Plus")
                                    .font(.system(size: 36, weight: .black)) // Thicker font for Plus
                                    .italic()
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 1.0, green: 0.95, blue: 0.8), // Light Gold
                                                Color(red: 0.9, green: 0.8, blue: 0.5),  // Gold
                                                Color(red: 0.8, green: 0.6, blue: 0.2)   // Dark Gold
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .shadow(color: Color(red: 0.9, green: 0.8, blue: 0.5).opacity(0.6), radius: 8, x: 0, y: 0) // Glow
                            }
                            
                            Text(L10n.subUnlockExperience)
                                .font(.system(size: 15))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(.top, 10)
                        
                        // 2. Auto-Scrolling Features (Marquee)
                        VStack(spacing: 16) {
                            AutoScrollingFeatureList(items: row1Features, direction: .left, speed: 30)
                            AutoScrollingFeatureList(items: row2Features, direction: .right, speed: 30)
                        }
                        .frame(height: 200) // Fixed height for the scrolling area
                        .mask(
                            LinearGradient(
                                colors: [.clear, .black, .black, .clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        
                        // 3. Subscription Plans
                        VStack(spacing: 12) {
                            PlanCard(
                                plan: .yearly,
                                isSelected: selectedPlan == .yearly,
                                price: getPrice(for: .yearly),
                                onSelect: { selectedPlan = .yearly }
                            )
                            
                            PlanCard(
                                plan: .monthly,
                                isSelected: selectedPlan == .monthly,
                                price: getPrice(for: .monthly),
                                onSelect: { selectedPlan = .monthly }
                            )
                            
                            PlanCard(
                                plan: .lifetime,
                                isSelected: selectedPlan == .lifetime,
                                price: getPrice(for: .lifetime),
                                onSelect: { selectedPlan = .lifetime }
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        // 4. Subscribe Button Area
                        VStack(spacing: 16) {
                            Button(action: handleSubscribe) {
                                ZStack {
                                    if isProcessing {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                    } else {
                                        Text(selectedPlan == .lifetime ? L10n.subBuyNow : L10n.subSubscribeNow)
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(.black)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .background(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.9, green: 0.8, blue: 0.5),
                                            Color(red: 1.0, green: 0.9, blue: 0.6)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(27)
                                .shadow(color: Color(red: 0.9, green: 0.8, blue: 0.5).opacity(0.3), radius: 10, x: 0, y: 5)
                            }
                            .disabled(isProcessing)
                            
                            // Info Text
                            Text(L10n.subInfoText)
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.4))
                                .multilineTextAlignment(.center)
                                .padding(.top, 4)
                            
                            // Footer Links
                            HStack(spacing: 20) {
                                Button(L10n.termsOfService) { /* TODO */ }
                                Button(L10n.privacyPolicy) { /* TODO */ }
                                Button(L10n.subRestorePurchase) { handleRestore() }
                            }
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.4))
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    }
                }
            }
        }
        .alert(L10n.subAlertTitle, isPresented: $showError) {
            Button(L10n.confirm, role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func getPrice(for plan: SubscriptionPlan) -> String {
        return subscriptionManager.getPrice(for: plan.productID)
    }
    
    private func handleSubscribe() {
        Task {
            isProcessing = true
            defer { isProcessing = false }
            
            do {
                let success = try await subscriptionManager.purchase(selectedPlan.productID)
                if success {
                    HapticManager.shared.notification(type: .success)
                    presentationMode.wrappedValue.dismiss()
                }
            } catch {
                errorMessage = error.localizedDescription
                showError = true
                HapticManager.shared.notification(type: .error)
            }
        }
    }
    
    private func handleRestore() {
        Task {
            isProcessing = true
            defer { isProcessing = false }
            
            do {
                try await subscriptionManager.restorePurchases()
                if subscriptionManager.isPremium {
                    HapticManager.shared.notification(type: .success)
                    presentationMode.wrappedValue.dismiss()
                } else {
                    errorMessage = L10n.subRestoreNoRecord
                    showError = true
                }
            } catch {
                errorMessage = error.localizedDescription
                showError = true
                HapticManager.shared.notification(type: .error)
            }
        }
    }
}

// MARK: - Components

struct AutoScrollingFeatureList: View {
    let items: [SubscriptionView.FeatureItem]
    let direction: Direction
    let speed: Double
    
    enum Direction {
        case left, right
    }
    
    @State private var offset: CGFloat = 0
    @State private var contentWidth: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            
            HStack(spacing: 16) {
                // Duplicate items to create infinite scroll illusion
                ForEach(0..<10) { _ in
                    HStack(spacing: 16) {
                        ForEach(items) { item in
                            FeatureCard(item: item)
                        }
                    }
                    .background(
                        GeometryReader { proxy in
                            Color.clear
                                .onAppear {
                                    contentWidth = proxy.size.width + 16 // Add spacing
                                }
                        }
                    )
                }
            }
            .offset(x: offset)
            .onAppear {
                startAnimation()
            }
        }
        .frame(height: 80) // Height of a single row
    }
    
    func startAnimation() {
        let duration = Double(items.count) * 3.0 // Adjust speed based on item count
        
        // Reset offset
        offset = direction == .left ? 0 : -1000 // Start position
        
        withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
            offset = direction == .left ? -1000 : 0 // End position
        }
    }
}

struct FeatureCard: View {
    let item: SubscriptionView.FeatureItem
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.cyan.opacity(0.1))
                    .frame(width: 32, height: 32)
                
                Image(systemName: item.icon)
                    .font(.system(size: 14))
                    .foregroundColor(.cyan)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(item.description)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.5))
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .frame(width: 220) // Fixed width for consistent scrolling
    }
}

struct PlanCard: View {
    let plan: SubscriptionView.SubscriptionPlan
    let isSelected: Bool
    let price: String
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                // Left: Info
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(plan.title)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                        
                        if let badge = plan.badge {
                            Text(badge)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(Color(red: 0.9, green: 0.8, blue: 0.5))
                                )
                        }
                    }
                    
                    if let savings = plan.savings {
                        Text(savings)
                            .font(.system(size: 12))
                            .foregroundColor(Color(red: 0.9, green: 0.8, blue: 0.5))
                    }
                }
                
                Spacer()
                
                // Right: Price
                VStack(alignment: .trailing, spacing: 2) {
                    // Show original price with strikethrough for yearly plan
                    if plan == .yearly {
                        Text(L10n.subOriginalPrice)
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.4))
                            .strikethrough(true, color: .white.opacity(0.4))
                    }
                    
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text(price)
                            .font(.system(size: plan == .yearly ? 24 : 20, weight: .bold))
                            .foregroundColor(plan == .yearly ? Color(red: 0.9, green: 0.8, blue: 0.5) : .white)
                        
                        Text(plan.period)
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                
                // Selection Circle
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color(red: 0.9, green: 0.8, blue: 0.5) : Color.white.opacity(0.2), lineWidth: 1.5)
                        .frame(width: 20, height: 20)
                    
                    if isSelected {
                        Circle()
                            .fill(Color(red: 0.9, green: 0.8, blue: 0.5))
                            .frame(width: 12, height: 12)
                    }
                }
                .padding(.leading, 8)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color(red: 0.9, green: 0.8, blue: 0.5).opacity(0.1) : Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color(red: 0.9, green: 0.8, blue: 0.5).opacity(0.5) : Color.clear, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
