#if canImport(GoogleSignIn)
import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

struct GoogleSignInHelper {
    
    /// Configure Google Sign-In with client ID from Info.plist
    static func configure() {
        // Client ID is read from Info.plist automatically
        // No additional configuration needed
    }
    
    /// Perform Google Sign-In
    static func signIn(presenting viewController: UIViewController, completion: @escaping (Result<GIDGoogleUser, Error>) -> Void) {
        GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { signInResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let signInResult = signInResult else {
                let error = NSError(domain: "GoogleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "No sign-in result"])
                completion(.failure(error))
                return
            }
            
            completion(.success(signInResult.user))
        }
    }
    
    /// Sign out from Google
    static func signOut() {
        GIDSignIn.sharedInstance.signOut()
    }
    
    /// Restore previous sign-in
    static func restorePreviousSignIn(completion: @escaping (GIDGoogleUser?) -> Void) {
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if let error = error {
                print("Failed to restore sign-in: \(error.localizedDescription)")
                completion(nil)
                return
            }
            completion(user)
        }
    }
}
#endif
