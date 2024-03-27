//
//  APIErrors.swift
//  Hendra
//
//  Created by Wilfried Mac Air on 23/02/2024.
//

import Foundation
import FirebaseAuth


public enum APIAuthErrors: Swift.Error {
    case badResponse(statusCode: Int)

    public static func  localizedDescription(error : NSError) -> String {
        switch error {
        case AuthErrorCode.invalidCredential:
            return "Email ou mot de passe incorrect"
        case AuthErrorCode.emailAlreadyInUse:
            return "Adresse e-mail déja utilisée"
        case AuthErrorCode.invalidEmail, AuthErrorCode.invalidSender, AuthErrorCode.invalidRecipientEmail:
            return "L'adresse e-mail est incorrect"
        case AuthErrorCode.wrongPassword:
            return "Mot de passe incorrect"
        case AuthErrorCode.tooManyRequests:
            return "Trop de requêtes. Attendez un moment avant de réessayer."
        default:
            return  "Un problème est survenu"
        }
    }
}
