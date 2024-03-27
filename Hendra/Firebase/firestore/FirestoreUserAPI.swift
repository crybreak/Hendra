//
//  FireStoreAPI.swift
//  Hendra
//
//  Created by Wilfried Mac Air on 02/03/2024.
//

import FirebaseFirestore
import Combine

class FirestoreUserAPI {
    static let shared = FirestoreUserAPI()
    
    private init () {}
    
    private let userCollection = Firestore.firestore().collection("users")
    
    private func userDocument(_ userId: String) -> DocumentReference {
        return userCollection.document(userId)
    }
    
    static func generateCodeAuth() -> String{
        
        let code: [Int] = (1...6).map { _ in
            return Int.random(in: 0...9)
        }
        return code.reduce("", {String($0) + String($1)})
    }
    
    func  createNewUser(user: SUser) -> Future<Void, Error> {
        return Future<Void, Error> { [self] promise in
            do {
                try userDocument(user.userId).setData(from: user, merge: false)
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
    }
    
    static func getDocs(ref: CollectionReference) -> AnyPublisher<[QueryDocumentSnapshot], Error> {
        Future { promise in
            ref.getDocuments { (snap, error) in
                if let error = error {
                    promise(.failure(error))
                }else if let snap = snap {
                    promise(.success(snap.documents))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    
    static func getDoc(ref: DocumentReference) -> AnyPublisher<DocumentSnapshot, Error> {
        Future { promise in
            ref.getDocument { (snap, error) in
                if let error = error {
                    promise(.failure(error))
                }else if let snap = snap {
                    promise(.success(snap))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    
    static func getDocs(ref: Query) -> AnyPublisher<QuerySnapshot, Error> {
        Future { promise in
            ref.getDocuments { (snap, error) in
                if let error = error {
                    promise(.failure(error))
                }else if let snap = snap {
                    promise(.success(snap))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
