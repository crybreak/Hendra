//
//  SigninGoogleHelper.swift
//  Hendra
//
//  Created by Wilfried Mac Air on 27/02/2024.
//

import Foundation

import GoogleSignIn
import FirebaseAuth
import Combine


class SignInGoogleHelper {
    @MainActor
       
   static func signIn () async throws -> GoogleSignInData {
        
        guard let topVc = Utilities.shared.topViewController() else {
            throw URLError(.cannotFindHost)
        }
        
        let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVc)
        
        guard let idToken = gidSignInResult.user.idToken?.tokenString else {
            throw URLError(.badServerResponse)
        }
        let accessToken = gidSignInResult.user.accessToken.tokenString
        let name = gidSignInResult.user.profile?.name
       let email = gidSignInResult.user.profile?.email

        let tokens = GoogleSignInData(idToken: idToken, accessToken: accessToken, name: name, email: email)
       
       return tokens;
    }
}


