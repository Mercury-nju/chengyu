import SwiftUI

struct ProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var authManager = AuthManager.shared
    @State private var showLogoutAlert = false
    @State private var showMyStats = false
    @State private var showDailyReminder = false
    @State private var showSettings = false
    @State private var showHelpFeedback = false
    @State private var showSubscription = false
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.02, blue: 0.1),
                    Color.black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Bar with Close Button
                HStack {
                    Spacer()
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.1))
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // MARK: - User Profile Header
                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                if authManager.isLoggedIn, let user = authManager.currentUser {
                                    Text(user.displayName)
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundColor(.white)
                                    
                                    HStack(spacing: 6) {
                                        Image(systemName: "sparkles")
                                            .font(.system(size: 12))
                                            .foregroundColor(.cyan)
                                        
                                        Text(String(format: L10n.dayWithLumea, 1))
                                            .font(.system(size: 14))
                                            .foregroundColor(.white.opacity(0.6))
                                    }
                                } else {
                                    Text(L10n.notLoggedIn)
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundColor(.white)
                                    
                                    Text(L10n.signInToSync)
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                            }
                            
                            Spacer()
                            
                            // Avatar Icon (Premium Look)
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.white.opacity(0.1), Color.white.opacity(0.05)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 72, height: 72)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                    )
                                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                                
                                Image(systemName: "person.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(authManager.isLoggedIn ? .white.opacity(0.8) : .white.opacity(0.4))
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        .padding(.bottom, 10)
                        
                        // MARK: - Membership Card
                        membershipCard
                            .padding(.horizontal, 20)
                        
                        // MARK: - Menu Items
                        VStack(spacing: 12) {
                            if !authManager.isLoggedIn {
                                ProfileMenuItem(
                                    icon: "person.crop.circle.badge.checkmark",
                                    title: L10n.loginAccountAction,
                                    color: .cyan,
                                    action: {
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                )
                            }
                            
                            ProfileMenuItem(
                                icon: "bell.badge.fill",
                                title: L10n.dailyReminderTitle,
                                color: .orange,
                                action: {
                                    showDailyReminder = true
                                }
                            )
                            
                            ProfileMenuItem(
                                icon: "gearshape.fill",
                                title: L10n.settingsTitle,
                                color: .gray,
                                action: {
                                    showSettings = true
                                }
                            )
                            
                            ProfileMenuItem(
                                icon: "questionmark.circle.fill",
                                title: L10n.helpTitle,
                                color: .blue,
                                action: {
                                    showHelpFeedback = true
                                }
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        // MARK: - Logout Button
                        if authManager.isLoggedIn {
                            Button(action: {
                                showLogoutAlert = true
                            }) {
                                Text(L10n.logout)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.white.opacity(0.4))
                                    .padding(.vertical, 12)
                            }
                            .padding(.top, 10)
                        }
                        
                        // Version info
                        Text("\(L10n.appName) v1.0.0")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.2))
                            .padding(.bottom, 40)
                    }
                }
            }
        }
        .alert(L10n.logout, isPresented: $showLogoutAlert) {
            Button(L10n.cancel, role: .cancel) { }
            Button(L10n.logoutConfirmTitle, role: .destructive) {
                authManager.logout()
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text(L10n.logoutConfirmMessage)
        }
        .fullScreenCover(isPresented: $showMyStats) {
            MyStatsView()
        }
        .fullScreenCover(isPresented: $showDailyReminder) {
            DailyReminderView()
        }
        .fullScreenCover(isPresented: $showSettings) {
            SettingsView()
        }
        .fullScreenCover(isPresented: $showHelpFeedback) {
            HelpFeedbackView()
        }
        .fullScreenCover(isPresented: $showSubscription) {
            SubscriptionView()
        }
    }
    
    // MARK: - Membership Card
    
    var membershipCard: some View {
        Button(action: {
            showSubscription = true
        }) {
            ZStack {
                // Background Gradient
                if SubscriptionManager.shared.isPremium {
                    LinearGradient(
                        colors: [
                            Color(red: 0.2, green: 0.15, blue: 0.05),
                            Color(red: 0.1, green: 0.08, blue: 0.02)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                } else {
                    LinearGradient(
                        colors: [
                            Color(red: 0.1, green: 0.1, blue: 0.12),
                            Color(red: 0.05, green: 0.05, blue: 0.06)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
                
                // Content
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 4) {
                            Text(L10n.appName)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Plus")
                                .font(.system(size: 22, weight: .black))
                                .italic()
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 1.0, green: 0.95, blue: 0.8),
                                            Color(red: 0.9, green: 0.8, blue: 0.5),
                                            Color(red: 0.8, green: 0.6, blue: 0.2)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: Color(red: 0.9, green: 0.8, blue: 0.5).opacity(0.3), radius: 5, x: 0, y: 0)
                        }
                        
                        Text(membershipStatusText)
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    Spacer()
                    
                    if SubscriptionManager.shared.isPremium {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color(red: 1.0, green: 0.95, blue: 0.8),
                                        Color(red: 0.9, green: 0.8, blue: 0.5)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .shadow(color: Color(red: 0.9, green: 0.8, blue: 0.5).opacity(0.5), radius: 10)
                    } else {
                        Text(L10n.upgradeToPlus)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.9, green: 0.8, blue: 0.5),
                                                Color(red: 1.0, green: 0.9, blue: 0.6)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                    }
                }
                .padding(20)
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(red: 0.9, green: 0.8, blue: 0.5).opacity(0.3),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color.black.opacity(0.3), radius: 15, x: 0, y: 5)
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    private var membershipStatusText: String {
        let manager = SubscriptionManager.shared
        let isUS = L10n.isUSVersion
        switch manager.subscriptionType {
        case .monthly:
            if let expiration = manager.expirationDate {
                let formatter = DateFormatter()
                formatter.dateFormat = isUS ? "MMM dd, yyyy" : "yyyy年MM月dd日"
                return String(format: L10n.monthlyExpires, formatter.string(from: expiration))
            }
            return L10n.monthlyMember
        case .yearly:
            if let expiration = manager.expirationDate {
                let formatter = DateFormatter()
                formatter.dateFormat = isUS ? "MMM dd, yyyy" : "yyyy年MM月dd日"
                return String(format: L10n.yearlyExpires, formatter.string(from: expiration))
            }
            return L10n.yearlyMember
        case .lifetime:
            return L10n.lifetimeMember
        case .none:
            return L10n.unlockFullExperience
        }
    }
}

// MARK: - Profile Menu Item

struct ProfileMenuItem: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.2))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.05))
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
