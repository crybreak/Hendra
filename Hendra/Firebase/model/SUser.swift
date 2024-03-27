//
//  AuthData.swift
//  Hendra
//
//  Created by Wilfried Mac Air on 22/02/2024.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct SUser: Codable {
    
    let userId: String
    let email: String?
    let photoUrl: String?
    let dateCreated: Date
    
    
    init(user: User) {
        self.userId = user.uid
        self.email = user.email
        self.photoUrl = user.photoURL?.absoluteString
        self.dateCreated = Date()
    }
    
    enum CodingKeys: String, CodingKey {
        case userId
        case email
        case photoUrl
        case dateCreated
    }
}
