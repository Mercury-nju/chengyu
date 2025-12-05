//
//  __App.swift
//  锚点
//
//  Created by Mercury on 2025/11/21.
//

import SwiftUI
#if canImport(GoogleSignIn)
import GoogleSignIn
#endif

@main
struct __App: App {
    @State private var showSplash = true
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @AppStorage("hasSeenPersonalization") private var hasSeenPersonalization = false
    
    // init() removed to persist onboarding state
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                // Main Content
                ContentView()
                    .opacity(hasSeenOnboarding && hasSeenPersonalization ? 1 : 0) // Hide until all onboarding done
                
                // Personalization Overlay (个性化问卷 + 订阅页面)
                if hasSeenOnboarding && !hasSeenPersonalization && !showSplash {
                    PersonalizationView(isCompleted: $hasSeenPersonalization)
                        .transition(.opacity)
                        .zIndex(2)
                }
                
                // Onboarding Overlay (原有的3段式引导)
                if !hasSeenOnboarding && !showSplash {
                    OnboardingView(isCompleted: $hasSeenOnboarding)
                        .transition(.opacity)
                        .zIndex(3)
                }
                
                // Splash Overlay (光球动效)
                if showSplash {
                    SplashView(isActive: $showSplash)
                        .transition(.opacity)
                        .zIndex(4)
                }
            }
            .animation(.easeInOut(duration: 0.8), value: hasSeenOnboarding)
            .animation(.easeInOut(duration: 0.8), value: hasSeenPersonalization)
            .animation(.easeInOut(duration: 1.0), value: showSplash)
            .onAppear {
                // Start ambient background music
                SoundManager.shared.startAmbientBackgroundMusic()
            }
            #if canImport(GoogleSignIn)
            .onOpenURL { url in
                // Handle Google Sign-In callback
                GIDSignIn.sharedInstance.handle(url)
            }
            #endif
        }
    }
}
