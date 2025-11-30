import SwiftUI
import Combine

class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    // Published properties
    @Published var isLoggedIn: Bool = false
    @Published var currentUser: User?
    @Published var authMethod: AuthMethod?
    
    // User defaults keys
    private let isLoggedInKey = "isLoggedIn"
    private let userDataKey = "userData"
    private let authMethodKey = "authMethod"
    
    // Authentication methods
    enum AuthMethod: String, Codable {
        case apple = "Apple"
        case google = "Google"
        case wechat = "WeChat"
        case phone = "Phone"
    }
    
    // User model
    struct User: Codable {
        let id: String
        let name: String?
        let email: String?
        let phone: String?
        let avatar: String?
        
        var displayName: String {
            name ?? email ?? phone ?? (L10n.isUSVersion ? "User" : "用户")
        }
    }
    
    private init() {
        loadUserSession()
    }
    
    // MARK: - Session Management
    
    func loadUserSession() {
        isLoggedIn = UserDefaults.standard.bool(forKey: isLoggedInKey)
        
        if let userData = UserDefaults.standard.data(forKey: userDataKey),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            currentUser = user
        }
        
        if let methodString = UserDefaults.standard.string(forKey: authMethodKey),
           let method = AuthMethod(rawValue: methodString) {
            authMethod = method
        }
    }
    
    func saveUserSession(user: User, method: AuthMethod) {
        currentUser = user
        authMethod = method
        isLoggedIn = true
        
        UserDefaults.standard.set(true, forKey: isLoggedInKey)
        UserDefaults.standard.set(method.rawValue, forKey: authMethodKey)
        
        if let userData = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(userData, forKey: userDataKey)
        }
        
        // 登录后重新检查订阅状态
        Task { @MainActor in
            await SubscriptionManager.shared.updateSubscriptionStatus()
        }
    }
    
    func logout() {
        // Google Sign-Out
        #if US_VERSION
        GoogleSignInHelper.signOut()
        #endif
        
        isLoggedIn = false
        currentUser = nil
        authMethod = nil
        
        UserDefaults.standard.removeObject(forKey: isLoggedInKey)
        UserDefaults.standard.removeObject(forKey: userDataKey)
        UserDefaults.standard.removeObject(forKey: authMethodKey)
        
        // 重要：登出时重新检查订阅状态
        // 因为订阅是绑定到设备的 Apple ID，不是 App 账号
        Task { @MainActor in
            await SubscriptionManager.shared.updateSubscriptionStatus()
        }
    }
    
    // MARK: - Login Methods
    
    func loginWithApple(userId: String, name: String?, email: String?) {
        let user = User(id: userId, name: name, email: email, phone: nil, avatar: nil)
        saveUserSession(user: user, method: .apple)
    }
    
    func loginWithGoogle(userId: String, name: String?, email: String?, avatar: String?) {
        let user = User(id: userId, name: name, email: email, phone: nil, avatar: avatar)
        saveUserSession(user: user, method: .google)
    }
    
    func loginWithWeChat(userId: String, name: String?, avatar: String?) {
        let user = User(id: userId, name: name, email: nil, phone: nil, avatar: avatar)
        saveUserSession(user: user, method: .wechat)
    }
    
    func loginWithPhone(phone: String, userId: String) {
        let user = User(id: userId, name: nil, email: nil, phone: phone, avatar: nil)
        saveUserSession(user: user, method: .phone)
    }
}
