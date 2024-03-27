//
//  Authentification + Manager.swift
//  Hendra
//
//  Created by Wilfried Mac Air on 22/02/2024.
//

import Foundation
import FirebaseAuth
import GoogleSignInSwift
import Combine
import CryptoKit
import AuthenticationServices


enum AuthProviderOption: String {
    case email = "email"
    case google = "google.com"
    case apple = "apple.com"


}
@MainActor

class FirebaseAuthAPI: NSObject, ObservableObject {
    
    static let shared = FirebaseAuthAPI()
    let signInAppleHelper = SignInAppleHelper()
    @Published var didSignInWithApple: Bool = false

    private override init () {}
    
    
    func getProvider() throws -> [AuthProviderOption] {
        guard let providerData = Auth.auth().currentUser?.providerData else {
            throw URLError(.badServerResponse)
        }
        
        var providers: [AuthProviderOption] = []
        for provider in providerData {
            if let option = AuthProviderOption(rawValue: provider.providerID) {
                providers.append(option)
            } else {
                assertionFailure("Provider option not found \(provider.providerID)")
            }
        }
        return providers
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    func delete() async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badURL)
        }
        try await user.delete()
    }
}

//MARK: SIGN IN EMAIL

extension FirebaseAuthAPI {
    
    static func createUser(withEmail: String, password: String)-> Future<AuthDataResult?, Error> {
        Future <AuthDataResult?, Error> {promise in
            Auth.auth().createUser(withEmail: withEmail, password: password) {authResult, error in
                if let error = error {
                    promise(Result.failure(error))
                } else {
                    promise(Result.success(authResult))
                }
            }
        }
    }
    
    
    static func signIn(withEmail: String, password: String) -> Future<AuthDataResult?, Error> {
        Future <AuthDataResult?, Error> {promise in
            Auth.auth().signIn(withEmail: withEmail, password: password) {authResult, error in
                if let error = error {
                    promise(Result.failure(error))
                } else {
                    promise(Result.success(authResult))
                }
            }
        }
    }
    
    
    func resetPassword(email: String) async throws  {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    
    func updatedPassword(password: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        try await user.updatePassword(to: password)
    }
}

//MARK: Sign In Google

extension FirebaseAuthAPI {
    @discardableResult
    func signInWithGoogle(tokens: GoogleSignInData) async throws -> AuthDataResult {
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken,
                                                       accessToken:  tokens.accessToken)
      return try await signIn(credential: credential)
    }
    func signIn(credential: AuthCredential) async throws -> AuthDataResult {
      return try await Auth.auth().signIn(with: credential)
    }
    
    func signInWithApple(tokens: SignInAppleWithResult ) async throws -> AuthDataResult {
        let credential = OAuthProvider.credential(withProviderID: AuthProviderOption.apple.rawValue ,
                                                  idToken: tokens.token,
                                                  rawNonce: tokens.nonce)
      return try await signIn(credential: credential)
    }
  
}

//MARK: Sign In Apple

extension FirebaseAuthAPI {
 
    @MainActor
    func signInApple() async throws {
        let helper = SignInAppleHelper()
        let tokens = try await helper.startSignInWithAppleFlow()
        let _ = try await FirebaseAuthAPI.shared.signInWithApple(tokens: tokens)
    }
    
}

extension UIViewController: ASAuthorizationControllerPresentationContextProviding {
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
