import SwiftUI
import AuthenticationServices
#if canImport(GoogleSignIn)
import GoogleSignIn
#endif


struct LoginView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var authManager = AuthManager.shared
    
    // Animation states
    @State private var appearAnimation = false
    @State private var animateGradient = false
    @State private var animateBlobs = false
    
    // Login states
    @State private var isLoggingIn = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack {
            // 1. Premium Background
            // Deep, sophisticated gradient with subtle animation
            LinearGradient(
                colors: [
                    Color(hex: "050510"), // Deep dark blue/black
                    Color(hex: "101025"), // Slightly lighter midnight blue
                    Color(hex: "000000")  // Pure black bottom
                ],
                startPoint: animateGradient ? .topLeading : .top,
                endPoint: animateGradient ? .bottomTrailing : .bottom
            )
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.easeInOut(duration: 10).repeatForever(autoreverses: true)) {
                    animateGradient.toggle()
                }
            }
            
            // Subtle ambient light/glow (Floating Blobs)
            GeometryReader { geo in
                ZStack {
                    // Blob 1 (Blue-ish)
                    Circle()
                        .fill(Color(hex: "4A90E2").opacity(0.1))
                        .frame(width: geo.size.width * 1.2)
                        .blur(radius: 100)
                        .offset(
                            x: animateBlobs ? -geo.size.width * 0.2 : -geo.size.width * 0.4,
                            y: animateBlobs ? -geo.size.height * 0.1 : -geo.size.height * 0.3
                        )
                    
                    // Blob 2 (Purple-ish)
                    Circle()
                        .fill(Color(hex: "9013FE").opacity(0.05))
                        .frame(width: geo.size.width)
                        .blur(radius: 80)
                        .offset(
                            x: animateBlobs ? geo.size.width * 0.3 : geo.size.width * 0.5,
                            y: animateBlobs ? geo.size.height * 0.2 : geo.size.height * 0.4
                        )
                    
                    // Blob 3 (Cyan-ish - New for depth)
                    Circle()
                        .fill(Color(hex: "50E3C2").opacity(0.03))
                        .frame(width: geo.size.width * 0.8)
                        .blur(radius: 60)
                        .offset(
                            x: animateBlobs ? -geo.size.width * 0.1 : geo.size.width * 0.1,
                            y: animateBlobs ? geo.size.height * 0.4 : geo.size.height * 0.6
                        )
                }
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 15).repeatForever(autoreverses: true)) {
                    animateBlobs.toggle()
                }
            }
            

            VStack(spacing: 0) {
                // Close button
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .fill(.white.opacity(0.1))
                            )
                    }
                    .padding(.leading, 24)
                    .padding(.top, 20)
                    
                    Spacer()
                }
                
                Spacer()
                
                // Brand Section
                VStack(spacing: 24) {
                    // App Icon / Logo Placeholder (Optional, or just text)
                    // Using a stylized text representation
                    
                    Text(L10n.appName)
                        .font(.system(size: 56, weight: .thin, design: .serif))
                        .foregroundColor(.white)
                        .tracking(2)
                        .shadow(color: .white.opacity(0.3), radius: 20, x: 0, y: 0)
                    
                    Text(L10n.appSlogan)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(.white.opacity(0.6))
                        .tracking(4)
                        .padding(.top, 16)
                    
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.clear, .white.opacity(0.3), .clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 100, height: 1)
                        .padding(.top, 8)
                }
                .offset(y: appearAnimation ? 0 : 20)
                .opacity(appearAnimation ? 1 : 0)
                
                Spacer()
                Spacer()
                
                // Login Buttons
                VStack(spacing: 16) {
                    // Apple Login
                    ZStack {
                        SignInWithAppleButton(
                            onRequest: { request in
                                request.requestedScopes = [.fullName, .email]
                                isLoggingIn = true
                            },
                            onCompletion: { result in
                                handleAppleSignIn(result: result)
                            }
                        )
                        .signInWithAppleButtonStyle(.white)
                        .frame(height: 50) // Standard height
                        .cornerRadius(8)   // Standard corner radius
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        .disabled(isLoggingIn)
                        
                        if isLoggingIn {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .black))
                        }
                    }
                    
                    // Google Login
                    Button(action: {
                        handleGoogleSignIn()
                    }) {
                        HStack(spacing: 12) {
                            GoogleLogoView() // Use the path-based logo
                                .frame(width: 18, height: 18)
                            
                            Text(L10n.signInWithGoogle)
                                .font(.system(size: 17, weight: .medium))
                                .foregroundColor(.black.opacity(0.54)) // Standard Google text color
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50) // Standard height
                        .background(Color.white)
                        .cornerRadius(8) // Standard corner radius
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    }
                }
                .padding(.horizontal, 32)
                .offset(y: appearAnimation ? 0 : 20)
                .opacity(appearAnimation ? 1 : 0)
                
                Spacer()
                    .frame(height: 40)
                
                // Privacy Policy
                HStack(spacing: 4) {
                    Text(L10n.loginAgree)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.4))
                    
                    Button(L10n.termsOfService) { }
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text(L10n.and)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.4))
                    
                    Button(L10n.privacyPolicy) { }
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.bottom, 40)
                .opacity(appearAnimation ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                appearAnimation = true
            }
        }
        .alert(L10n.loginFailed, isPresented: $showError) {
            Button(L10n.confirm, role: .cancel) {
                isLoggingIn = false
            }
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - Login Handlers
    
    func handleAppleSignIn(result: Result<ASAuthorization, Error>) {
        isLoggingIn = false
        
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                let userId = appleIDCredential.user
                let name = appleIDCredential.fullName?.givenName
                let email = appleIDCredential.email
                
                print("✅ Apple Sign In successful: \(userId)")
                authManager.loginWithApple(userId: userId, name: name, email: email)
                presentationMode.wrappedValue.dismiss()
            }
        case .failure(let error):
            let nsError = error as NSError
            print("❌ Apple Sign In failed: \(error.localizedDescription)")
            print("❌ Error code: \(nsError.code)")
            
            // 处理不同的错误类型
            if nsError.code == 1001 { // ASAuthorizationError.canceled
                // 用户取消，不显示错误
                return
            }
            
            // 显示错误信息
            if nsError.code == 1000 { // ASAuthorizationError.unknown
                errorMessage = L10n.checkNetwork
            } else if nsError.code == 1004 { // ASAuthorizationError.notInteractive
                errorMessage = L10n.tryAgainLater
            } else {
                errorMessage = "\(L10n.loginErrorPrefix)\(error.localizedDescription)"
            }
            showError = true
        }
    }
    
    func handleGoogleSignIn() {
        #if canImport(GoogleSignIn)
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            print("No root view controller found")
            return
        }
        
        GoogleSignInHelper.signIn(presenting: rootViewController) { result in
            switch result {
            case .success(let user):
                let userId = user.userID ?? ""
                let name = user.profile?.name
                let email = user.profile?.email
                let avatarURL = user.profile?.imageURL(withDimension: 200)?.absoluteString
                
                authManager.loginWithGoogle(
                    userId: userId,
                    name: name,
                    email: email,
                    avatar: avatarURL
                )
                
                presentationMode.wrappedValue.dismiss()
                
            case .failure(let error):
                print("Google Sign-In failed: \(error.localizedDescription)")
            }
        }
        #else
        print("Google Sign-In is not available in this build")
        #endif
    }
}




