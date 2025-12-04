import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var soundManager = SoundManager.shared
    @ObservedObject var hapticManager = HapticManager.shared
    @State private var showMaterialPicker = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Navigation Bar
                navigationBar
                
                // Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        audioHapticSection
                        aboutSection
                        versionInfo
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .fullScreenCover(isPresented: $showMaterialPicker) {
            SphereMaterialPickerView()
        }
    }
    
    private var navigationBar: some View {
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Text(L10n.settingsTitle)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            Spacer()
            
            Color.clear.frame(width: 24)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 20)
        .frame(height: 60)
    }
    
    // Sphere Material section removed for US version
    
    private var audioHapticSection: some View {
        VStack(spacing: 0) {
            SettingToggleRow(
                icon: "speaker.wave.2.fill",
                title: L10n.soundEffects,
                subtitle: L10n.soundEffectsDesc,
                isOn: Binding(
                    get: { soundManager.isSoundEnabled },
                    set: { soundManager.setSoundEnabled($0) }
                )
            )
            
            Divider()
                .background(Color.white.opacity(0.1))
                .padding(.leading, 60)
            
            SettingToggleRow(
                icon: "waveform",
                title: L10n.hapticFeedback,
                subtitle: L10n.hapticFeedbackDesc,
                isOn: Binding(
                    get: { hapticManager.isHapticEnabled },
                    set: { hapticManager.setHapticEnabled($0) }
                )
            )
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
        )
    }
    
    private var aboutSection: some View {
        VStack(spacing: 0) {
            SettingNavigationRow(
                icon: "doc.text.fill",
                title: L10n.userAgreement,
                action: {
                    if let url = URL(string: "https://www.chengyu.space/terms.html") {
                        UIApplication.shared.open(url)
                    }
                }
            )
            
            Divider()
                .background(Color.white.opacity(0.1))
                .padding(.leading, 60)
            
            SettingNavigationRow(
                icon: "hand.raised.fill",
                title: L10n.privacyPolicy,
                action: {
                    if let url = URL(string: "https://www.chengyu.space/privacy.html") {
                        UIApplication.shared.open(url)
                    }
                }
            )
            
            Divider()
                .background(Color.white.opacity(0.1))
                .padding(.leading, 60)
            
            SettingNavigationRow(
                icon: "info.circle.fill",
                title: L10n.aboutApp,
                action: {
                    if let url = URL(string: "https://chengyu.space") {
                        UIApplication.shared.open(url)
                    }
                }
            )
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
        )
    }
    
    private var versionInfo: some View {
        Text("\(L10n.version) 1.0.0")
            .font(.system(size: 13))
            .foregroundColor(.white.opacity(0.3))
            .padding(.top, 20)
    }
}

struct SettingToggleRow: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.cyan)
                .frame(width: 28)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.5))
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(.cyan)
        }
        .padding(16)
    }
}

struct SettingNavigationRow: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.cyan)
                    .frame(width: 28)
                
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white.opacity(0.3))
            }
            .padding(16)
        }
    }
}
