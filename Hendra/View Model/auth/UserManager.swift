//
//  UserManager.swift
//  Hendra
//
//  Created by Wilfried Mac Air on 01/03/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

class UserManager: ObservableObject {
    @Published var users: [SUser] = []
    @Published var currentUser: User? = nil
    
    @Published var isLoading: Bool = false
    @Published var getUserError: String? = nil
    
    @Published  var shouldNavigate: Bool = false

    @Published var code: String? = nil

    var getUserbyMail =  PassthroughSubject<String, Never>()
    var addNewUser = PassthroughSubject<User, Never>()
    let resetCode = PassthroughSubject<Void, Never>()


        
    var subscriptions = Set<AnyCancellable>()
    

    
    let db = Firestore.firestore()
    let path = "users"
    
    init() {
        setupCreateUser()
        
        getUserbyMail
            .filter({!$0.isEmpty})
            .handleEvents(receiveOutput: { [unowned self] (_) in
                self.isLoading = true
            })
            .map({ [unowned self] email in
                return self.db.collection(self.path)
                    .whereField(SUser.CodingKeys.email.rawValue, isEqualTo: email)
            })
            .map {[unowned self] query -> AnyPublisher<[SUser], Never> in
                FirestoreUserAPI.getDocs(ref: query)
                    .handleEvents(receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            print("❇️ User has taken successfully")
                        case .failure(let error):
                            self.getUserError = error.localizedDescription
                            print("❇️  Get User with error: \(error.localizedDescription)")
                        }
                        self.isLoading = false

                    })
                    .tryMap({ snap in
                        try snap.documents.compactMap({ try $0.data(as: SUser.self) })
                    })
                    .replaceError(with: [])
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .sink { [unowned self ] users in
                self.users = users
                if users.isEmpty {
                    self.getUserError = "Désolé, aucun compte ne correspond à cet email."
                } else {
                    self.getUserError = nil
                    self.verifyCodeAuth(email: users.first!.email!)
                    self.shouldNavigate = true
                }
            }
            .store(in: &subscriptions)

        $users
            .compactMap({$0})
            .sink { users in
                print("users \(users)")
            }
            .store(in: &subscriptions)
        
        resetCode
            .throttle(for: .seconds(60), scheduler: RunLoop.main, latest: true)
            .sink { [unowned self] _ in
                self.verifyCodeAuth(email: users.first!.email!)
            }
            .store(in: &subscriptions)
    }
    
    
    
    func setupCreateUser() {
        
        addNewUser
            .map({user in
                return SUser(user: user)
            })
            .flatMap { suser -> AnyPublisher<Void, Error> in
                 FirestoreUserAPI.shared.createNewUser(user: suser)
                .eraseToAnyPublisher()
            }
            .sink { completion in
                switch completion {
                case .finished:
                    print("Opération terminée avec succès")
                case .failure(let error as NSError):
                    print("Opération échouée avec l'erreur : \(error.code)")
                }
            } receiveValue: { _ in
                print("☘️ added new doc for user")
            }.store(in: &subscriptions)
        
    }
   
    
    func verifyCodeAuth(email: String) {
        self.code = FirestoreUserAPI.generateCodeAuth()
        self.sendMailCodeSetPass(code: self.code!, email: email)
    }
    
    static func sendMailCodeAuth(code: String, email: String) {
        let data: [String: Any] = [
            "to": email,
            "message": [
                "subject": "Bienvenue sur l'application Hendra : Votre clé d'accès 🌟",
                "html": "<body style=\"font-family: 'Nunito Sans', sans-serif;\"> <p style=\"font-size: 2em; text-align: center;\"><strong>Validation de l’adresse e‑mail comme nouvel identifiant Hendra</strong></p><p style=\"opacity: 0.7;\">Vous avez choisi cette adresse e‑mail comme nouvel identifiant. Pour confirmer que cette adresse e‑mail vous appartient, veuillez saisir le code ci‑dessous sur la page de validation de l’adresse e‑mail :</p>   <p><strong style=\"font-size: 1.5em;\">\(code)</strong></p> </body> "
            ]
        ]

        Firestore.firestore().collection("code").addDocument(data: data) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("email send succesful!")
            }
        }
    }
    
     func sendMailCodeSetPass(code: String, email: String) {
        let data: [String: Any] = [
            "to": email,
            "message": [
                "subject": "Modificatin du mot de passe : Votre clé d'accès 🌟",
                "html": "<body style=\"font-family: 'Nunito Sans', sans-serif;\"> <p style=\"font-size: 2em; text-align: center;\"><strong>Validation de l’adresse e‑mail comme nouvel identifiant Hendra</strong></p><p style=\"opacity: 0.7;\"> Pour confirmer que cette adresse e‑mail vous appartient, veuillez saisir le code ci‑dessous sur la page de validation de l’adresse e‑mail :</p>   <p><strong style=\"font-size: 1.5em;\">\(code)</strong></p> </body> "
            ]
        ]

        Firestore.firestore().collection("code").addDocument(data: data) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("email send succesful!")
            }
        }
    }
}

