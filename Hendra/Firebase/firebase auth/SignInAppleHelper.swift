//
//  SigninApple + Helper.swift
//  Hendra
//
//  Created by Wilfried Mac Air on 18/03/2024.
//

import Foundation
import CryptoKit
import AuthenticationServices


struct SignInAppleWithResult {
    let token: String
    let nonce: String
    let name: String?
    let email: String?
}

@MainActor
class SignInAppleHelper: NSObject {
    
    private var completionHandler: ((Result<SignInAppleWithResult, Error>) -> Void)? = nil
    private var currentNonce: String? = nil

    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }
        
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }

    func startSignInWithAppleFlow() async throws -> SignInAppleWithResult {
        try await withCheckedThrowingContinuation { continuation in
            self.startSignInWithAppleFlow { result in
                switch result {
                case .success(let signInAppleResult):
                    continuation.resume(returning: signInAppleResult)
                    return
                case .failure(let error):
                    continuation.resume(throwing: error)
                    return
                }
            }
        }
    }
    
    func startSignInWithAppleFlow(completion: @escaping (Result<SignInAppleWithResult, Error>) -> Void) {
        
        guard let topVc = Utilities.shared.topViewController() else {
            return
        }
        let nonce = randomNonceString()
        currentNonce = nonce
        completionHandler = completion
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = topVc
        authorizationController.performRequests()
    }
    
}

@available(iOS 13.0, *)

extension SignInAppleHelper: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8),
              let nonce = currentNonce  else {
            completionHandler?(.failure(URLError(.badServerResponse)))
            return
        }
        let name = appleIDCredential.fullName?.givenName
        let email = appleIDCredential.email
        
        let tokens = SignInAppleWithResult(token: idTokenString, nonce: nonce, name: name, email: email)
        completionHandler?(.success(tokens))
        
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        completionHandler?(.failure(URLError(.cannotConnectToHost)))
        print("Sign in with Apple errored: \(error)")
    }
}
