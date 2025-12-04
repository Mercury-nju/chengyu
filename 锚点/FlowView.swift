import SwiftUI

struct FlowView: View {
    var body: some View {
        CoreCastingView()
    }
}

// MARK: - Core Component Casting
struct CoreCastingView: View {
    @State private var isInteracting = false
    @State private var touchLocation: CGPoint = .zero
    @ObservedObject var statusManager = StatusManager.shared
    @ObservedObject var subscriptionManager = SubscriptionManager.shared
    @State private var showSubscriptionPrompt = false
    @State private var previewMaterial: String? = nil // 用于预览会员材质
    @State private var showPreviewHint = false
    
    // Helper to convert String <-> Enum
    var currentMaterial: FluidSphereVisualizer.SphereMaterial {
        // 如果正在预览，显示预览材质
        let materialId = previewMaterial ?? statusManager.sphereMaterial
        
        switch materialId {
        case "lava": return .lava
        case "ice": return .ice
        case "amber": return .amber
        case "gold": return .gold
        case "neon": return .neon
        case "nebula": return .nebula
        case "aurora": return .aurora
        case "sakura": return .sakura
        case "ocean": return .ocean
        case "sunset": return .sunset
        case "forest": return .forest
        case "galaxy": return .galaxy
        case "crystal": return .crystal
        default: return .default
        }
    }
    
    // 材质名称映射
    var materialNames: [String: String] {
        [
            "amber": L10n.materialAmberFull,
            "neon": L10n.materialNeonFull,
            "nebula": L10n.materialNebulaFull,
            "aurora": L10n.materialAuroraFull,
            "sakura": L10n.materialSakuraFull,
            "ocean": L10n.materialOceanFull,
            "sunset": L10n.materialSunsetFull,
            "forest": L10n.materialForestFull,
            "galaxy": L10n.materialGalaxyFull,
            "crystal": L10n.materialCrystalFull
        ]
    }
    
    var materials: [(name: String, type: FluidSphereVisualizer.SphereMaterial, id: String, locked: Bool)] {
        [
            // 免费材质
            (L10n.materialDefault, .default, "default", false),
            (L10n.materialLava, .lava, "lava", false),
            (L10n.materialIce, .ice, "ice", false),
            (L10n.materialGold, .gold, "gold", false),
            
            // 会员材质
            (L10n.materialAmber, .amber, "amber", true),
            (L10n.materialNeon, .neon, "neon", true),
            (L10n.materialNebula, .nebula, "nebula", true),
            (L10n.materialAurora, .aurora, "aurora", true),
            (L10n.materialSakura, .sakura, "sakura", true),
            (L10n.materialOcean, .ocean, "ocean", true),
            (L10n.materialSunset, .sunset, "sunset", true),
            (L10n.materialForest, .forest, "forest", true),
            (L10n.materialGalaxy, .galaxy, "galaxy", true),
            (L10n.materialCrystal, .crystal, "crystal", true)
        ]
    }
    
    var body: some View {
        ZStack {
            // Background
            ThemeManager.shared.currentTheme.backgroundView
            
            // Preview Window
            FluidSphereVisualizer(
                isInteracting: $isInteracting, 
                touchLocation: touchLocation, 
                material: currentMaterial, 
                stability: 35.0, // Fixed stability for consistent animation speed
                isTransparent: true
            )
                .offset(y: -60) // 向上偏移，保持在画面中心
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            isInteracting = true
                            touchLocation = value.location
                        }
                        .onEnded { _ in
                            isInteracting = false
                        }
                )
            
            // Material Selector
            VStack {
                // Preview Hint - Elegant Glass Morphism (Tappable) - 移到顶部
                if showPreviewHint, let previewName = getPreviewMaterialName() {
                    Button(action: {
                        // 点击弹窗后跳转到订阅页面
                        showSubscriptionPrompt = true
                        previewMaterial = nil
                        showPreviewHint = false
                    }) {
                        VStack(spacing: 10) {
                            Text(L10n.isUSVersion ? "Lumea Exclusive: \(previewName)" : "澄域限定：\(previewName)")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text(L10n.isUSVersion ? "Upgrade to Lumea PLUS to unlock this flow aesthetic," : "升级澄域 PLUS，解锁此心流美学，")
                                .font(.system(size: 13, weight: .light))
                                .foregroundColor(.white.opacity(0.85))
                            
                            Text(L10n.isUSVersion ? "and begin a deeper journey to clarity." : "开启更深层次的澄澈之旅。")
                                .font(.system(size: 13, weight: .light))
                                .foregroundColor(.white.opacity(0.85))
                        }
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 20)
                        .background(
                            ZStack {
                                // Glassmorphism background
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(.ultraThinMaterial)
                                    .opacity(0.8)
                                
                                // Gradient overlay for depth
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.cyan.opacity(0.15),
                                                Color.purple.opacity(0.1)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                
                                // Soft glow border
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                Color.cyan.opacity(0.6),
                                                Color.purple.opacity(0.4)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                                    .blur(radius: 2)
                            }
                        )
                        .shadow(color: Color.cyan.opacity(0.3), radius: 20, x: 0, y: 10)
                        .shadow(color: Color.purple.opacity(0.2), radius: 30, x: 0, y: 15)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .transition(.scale(scale: 0.8).combined(with: .opacity))
                    .padding(.top, 60)
                }
                
                Spacer()
                
                Text(L10n.flowVisualization)
                    .font(Theme.fontTitle())
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.bottom, 20)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(materials, id: \.name) { item in
                            let isLocked = item.locked && !subscriptionManager.isPremium
                            let isCurrentlySelected = statusManager.sphereMaterial == item.id
                            let isPreviewing = previewMaterial == item.id
                            
                            Button(action: {
                                if isLocked {
                                    // 预览会员材质
                                    previewMaterial = item.id
                                    showPreviewHint = true
                                } else {
                                    // 免费材质直接选择
                                    statusManager.sphereMaterial = item.id
                                    previewMaterial = nil
                                    showPreviewHint = false
                                }
                            }) {
                                VStack(spacing: 8) {
                                    ZStack {
                                        Circle()
                                            .fill(LinearGradient(colors: item.type.colors, startPoint: .topLeading, endPoint: .bottomTrailing))
                                            .frame(width: 60, height: 60)
                                            .overlay(
                                                Circle()
                                                    .stroke(
                                                        isPreviewing ? Color.yellow : (isCurrentlySelected ? Color.white : Color.clear),
                                                        lineWidth: 2
                                                    )
                                            )
                                            .shadow(radius: isPreviewing ? 10 : 5)
                                            .shadow(color: isPreviewing ? .yellow : .clear, radius: 15)
                                        
                                        if isLocked {
                                            Circle()
                                                .fill(Color.black.opacity(0.4))
                                                .frame(width: 60, height: 60)
                                            
                                            Image(systemName: "lock.fill")
                                                .font(.system(size: 16))
                                                .foregroundColor(.white.opacity(0.7))
                                        }
                                    }
                                    .frame(width: 60, height: 60)
                                    
                                    Text(item.name)
                                        .font(.caption)
                                        .foregroundColor(isPreviewing ? .yellow : .white)
                                }
                                .frame(width: 80, height: 90)
                            }
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 20)
                }
                
            }
        }
        .fullScreenCover(isPresented: $showSubscriptionPrompt) {
            SubscriptionView()
        }
    }
    
    // 获取预览材质的中文名称
    private func getPreviewMaterialName() -> String? {
        guard let previewId = previewMaterial else { return nil }
        return materialNames[previewId]
    }
}
