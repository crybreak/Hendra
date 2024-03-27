//
//  AuthentifcationManager + Helper.swift
//  Hendra
//
//  Created by Wilfried Mac Air on 26/02/2024.
//

import Foundation
import FirebaseAuth
import GoogleSignIn

extension AuthentificationManager {
    
    func filterEmptyFieldEmailandPassword(email: String, password: String) -> Bool {
       
        guard !email.isEmpty , !password.isEmpty else {
            if email.isEmpty  {
                self.feedBackEmail = "Adresse e-mail requise"
            } else if password.isEmpty {
                self.feedBackText =  (0, "Mot de passe requis")
            }
            self.isLoading = false
            return false
        }
        return true
    }
    
    func getErrorFirebaseApiAuthentification (error: NSError) {
        
        if AuthErrorCode.networkError.rawValue == error.code {
            self.noConnection = true
        } else {
            self.feedBackEmail = APIAuthErrors.localizedDescription(error: error)
        }
    }
    
    func getErrorFirebaseApiGoogleSignIn (error: NSError) {
        print ("\(error.localizedDescription) code \(error.code)")
    }
    
}
