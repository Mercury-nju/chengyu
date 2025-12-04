import SwiftUI

struct SphereMaterialPickerView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var statusManager = StatusManager.shared
    @ObservedObject var subscriptionManager = SubscriptionManager.shared
    @State private var showSubscriptionPrompt = false
    
    // Free materials
    var freeMaterials: [MaterialOption] {
        [
            MaterialOption(type: "default", name: L10n.materialDefault, description: L10n.descClassic),
            MaterialOption(type: "lava", name: L10n.isUSVersion ? "Lava Core" : "熔岩核心", description: L10n.descLava),
            MaterialOption(type: "ice", name: L10n.isUSVersion ? "Glacial Crystal" : "冰川结晶", description: L10n.descIce),
            MaterialOption(type: "gold", name: L10n.isUSVersion ? "Liquid Gold" : "流体黄金", description: L10n.descGold)
        ]
    }
    
    // Premium materials
    var premiumMaterials: [MaterialOption] {
        [
            MaterialOption(type: "amber", name: L10n.isUSVersion ? "Amber Resin" : "琥珀树脂", description: L10n.descAmber),
            MaterialOption(type: "neon", name: L10n.isUSVersion ? "Cyber Neon" : "赛博霓虹", description: L10n.descNeon),
            MaterialOption(type: "nebula", name: L10n.isUSVersion ? "Cosmic Nebula" : "宇宙星云", description: L10n.descNebula),
            MaterialOption(type: "aurora", name: L10n.isUSVersion ? "Aurora Borealis" : "极光幻境", description: L10n.descAurora),
            MaterialOption(type: "sakura", name: L10n.isUSVersion ? "Sakura Stream" : "樱花溪流", description: L10n.descSakura),
            MaterialOption(type: "ocean", name: L10n.isUSVersion ? "Deep Ocean" : "深海幽蓝", description: L10n.descOcean),
            MaterialOption(type: "sunset", name: L10n.isUSVersion ? "Sunset Glow" : "落日余晖", description: L10n.descSunset),
            MaterialOption(type: "forest", name: L10n.isUSVersion ? "Forest Vitality" : "森林生机", description: L10n.descForest),
            MaterialOption(type: "galaxy", name: L10n.isUSVersion ? "Milky Way" : "银河星系", description: L10n.descGalaxy),
            MaterialOption(type: "crystal", name: L10n.isUSVersion ? "Prism Crystal" : "棱镜水晶", description: L10n.descCrystal)
        ]
    }
    
    struct MaterialOption: Identifiable {
        let id = UUID()
        let type: String
        let name: String
        let description: String
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Navigation Bar
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Text(L10n.materialPickerTitle)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Color.clear.frame(width: 24)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 20)
                
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 24, pinnedViews: []) {
                        // Preview
                        VStack(spacing: 12) {
                            Text(L10n.preview)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white.opacity(0.05))
                                    .frame(height: 200)
                                
                                FluidSphereVisualizer(
                                    isInteracting: .constant(false),
                                    touchLocation: .zero,
                                    material: getCurrentMaterial(),
                                    stability: 70.0,
                                    isTransparent: true,
                                    isStatic: true
                                )
                                .frame(height: 180)
                            }
                            .frame(height: 200)
                        }
                        
                        // Free Materials
                        VStack(spacing: 12) {
                            Text(L10n.freeMaterials)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 16)], spacing: 16) {
                                ForEach(freeMaterials) { material in
                                    MaterialCard(
                                        material: material,
                                        isSelected: statusManager.sphereMaterial == material.type,
                                        isLocked: false,
                                        onSelect: {
                                            selectMaterial(material.type)
                                        }
                                    )
                                }
                            }
                        }
                        
                        // Premium Materials
                        VStack(spacing: 12) {
                            HStack {
                                Text(L10n.premiumExclusive)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.6))
                                
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.yellow)
                                
                                Spacer()
                            }
                            
                            VStack(spacing: 10) {
                                ForEach(premiumMaterials) { material in
                                    MaterialCard(
                                        material: material,
                                        isSelected: statusManager.sphereMaterial == material.type,
                                        isLocked: !subscriptionManager.isPremium,
                                        onSelect: {
                                            if subscriptionManager.isPremium {
                                                selectMaterial(material.type)
                                            } else {
                                                showSubscriptionPrompt = true
                                            }
                                        }
                                    )
                                }
                            }
                        }
                        
                        Spacer().frame(height: 40)
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .fullScreenCover(isPresented: $showSubscriptionPrompt) {
            SubscriptionView()
        }
    }
    
    private func getCurrentMaterial() -> FluidSphereVisualizer.SphereMaterial {
        switch statusManager.sphereMaterial {
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
    
    private func selectMaterial(_ type: String) {
        withAnimation {
            statusManager.sphereMaterial = type
        }
        HapticManager.shared.impact(style: .light)
    }
}

// MARK: - Material Card

struct MaterialCard: View {
    let material: SphereMaterialPickerView.MaterialOption
    let isSelected: Bool
    let isLocked: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                // Preview Circle
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: getPreviewColors(),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                        .padding(1) // Fix: Add padding to prevent anti-aliasing clipping
                    
                    if isLocked {
                        Circle()
                            .fill(Color.black.opacity(0.6))
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: "lock.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(material.name)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        if isLocked {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 10))
                                .foregroundColor(Color(red: 0.9, green: 0.8, blue: 0.5))
                        }
                    }
                    
                    Text(material.description)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                // Selection Indicator
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.cyan : Color.white.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(Color.cyan)
                            .frame(width: 14, height: 14)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.cyan.opacity(0.1) : Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color.cyan.opacity(0.5) : Color.clear, lineWidth: 1.5)
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    private func getPreviewColors() -> [Color] {
        switch material.type {
        case "default":
            return [Color.cyan, Color.purple]
        case "lava":
            return [Color.red, Color.orange]
        case "ice":
            return [Color.white, Color.cyan]
        case "gold":
            return [Color.yellow, Color.orange]
        case "amber":
            return [Color.orange, Color(red: 0.9, green: 0.5, blue: 0.1)]
        case "neon":
            return [Color.green, Color.pink]
        case "nebula":
            return [Color.purple, Color(red: 0.6, green: 0.3, blue: 1.0)]
        case "aurora":
            return [Color.green, Color.cyan, Color.purple]
        case "sakura":
            return [Color.pink, Color(red: 1.0, green: 0.7, blue: 0.8)]
        case "ocean":
            return [Color.blue, Color.cyan]
        case "sunset":
            return [Color.orange, Color.pink]
        case "forest":
            return [Color.green, Color(red: 0.4, green: 0.8, blue: 0.4)]
        case "galaxy":
            return [Color.purple, Color(red: 0.5, green: 0.2, blue: 0.8)]
        case "crystal":
            return [Color.white, Color(red: 0.7, green: 0.9, blue: 1.0)]
        default:
            return [Color.cyan, Color.purple]
        }
    }
}
