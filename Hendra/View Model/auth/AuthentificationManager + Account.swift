//
//  AuthentificationManager.swift
//  Hendra
//
//  Created by Wilfried Mac Air on 23/02/2024.
//

import Foundation
import FirebaseAuth
import Combine
import CoreData
import MessageUI

@MainActor
class AuthentificationManager: ObservableObject {
    
    let userName = PassthroughSubject<(String, String), Never>()
    let createNewUserRequest = PassthroughSubject<(String, String), Never>()
    let signInRequest = PassthroughSubject<(String, String), Never>()
    let signOutRequest = PassthroughSubject<Void, Never>()
    let resetCode = PassthroughSubject<Void, Never>()
    let signInGoogleRequest = PassthroughSubject<Void, Never>()
    
    
    var subscriptions = Set<AnyCancellable>()
    
    
    @Published var user: User? = nil
    
    @Published var code: String? = nil
    
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var passwordConfirm: String = ""
    
    @Published var disableCreateUserButton: Bool = true
    
    // feedback user
    @Published var feedBackText: (Int, String) = (0, "")
    @Published var feedBackEmail: String =  ""
    @Published var noConnection: Bool =  false
    @Published var isLoading: Bool = false
    
    var userManager : UserManager? = UserManager()
    
    @Published  var shouldNavigate: Bool = false

    
    init () {
        
        AuthPublisher().sink { [unowned self] user in
            print("sink receive user \(String(describing: user))")
            self.user = user
        }.store(in: &subscriptions)
        
        $email
            .sink {[unowned self] _ in
                self.feedBackEmail = ""
            }.store(in: &subscriptions)
        
        let passwordPubliser = $password
            .map {$0.count >= 8 || $0.isEmpty}
        
        let passwordConfirmPubliser = $password.combineLatest($passwordConfirm).map {$0 == $1}
        
        passwordPubliser.combineLatest(passwordConfirmPubliser)
            .map {
                !($0 && $1)
            }.assign(to: &$disableCreateUserButton)
        
        passwordPubliser.combineLatest(passwordConfirmPubliser)
            .map { [unowned self] (password, confirm) -> (Int, String) in
                if !password {
                    return (0, "Doit contenir au moins 8 caratères")
                } else if !confirm {
                    return (1, "Aucune correspondance")
                } else {
                    if !self.password.isEmpty {
                        return (2, "")
                    } else {
                        return (2, "Doit contenir au moins 8 caratères")
                    }
                }
            }.assign(to: &$feedBackText)
        
        
        createNewUserRequest.merge(with: signInRequest)
            .sink { [unowned self] (_,_) in
                self.isLoading = true
            }.store(in: &subscriptions)
        
      
        createAccount()
        
        signInWithEmail()
        
        signOut()
        
        $shouldNavigate.sink{shouldNavigate in
           print("shouldNavigate \(shouldNavigate)")
                 }.store(in: &subscriptions)
        
        resetCode
            .throttle(for: .seconds(60), scheduler: RunLoop.main, latest: true)
            .sink { [unowned self] _ in
                self.verifyCodeAuth()
            }
            .store(in: &subscriptions)
    }
    
    func createAccount() {
        createNewUserRequest
            .debounce(for: .milliseconds(500) , scheduler: DispatchQueue.main)
            .filter({ [unowned self ](email, password) in
                self.filterEmptyFieldEmailandPassword(email: email, password: password)
            })
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .map{ [unowned self] (email, password) -> AnyPublisher<User?, Never> in
                FirebaseAuthAPI.createUser(withEmail: email, password: password)
                    .receive(on: DispatchQueue.main)
                    .handleEvents(receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            print("❇️ AuthManager - complete create account with success")
                        case .failure(let error):
                            self.getErrorFirebaseApiAuthentification(error: error as NSError)
                            print("❇️ AuthManager - complete create account with error: \(error.localizedDescription)")
                            
                        }
                        self.isLoading = false
                        
                    })
                    .compactMap {authResult in
                        authResult?.user
                    }
                    .replaceError(with: nil)
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .sink {[unowned self] user in
                self.user = user
                if user != nil {
                    self.verifyCodeAuth()
                    self.shouldNavigate = true 
                }
            }
            .store(in: &subscriptions)
    }
    
    func signInWithEmail() {
        signInRequest
            .debounce(for: .milliseconds(500) , scheduler: DispatchQueue.main)
            .filter { [unowned self] (email, password) in
                self.filterEmptyFieldEmailandPassword(email: email, password: password)
                
            }
            .map { (email, password) -> AnyPublisher<User?, Never> in
                FirebaseAuthAPI.signIn(withEmail: email, password: password)
                    .receive(on: DispatchQueue.main)
                    .handleEvents(receiveCompletion: {completion in
                        switch completion {
                        case .finished: break
                        case .failure(let error):
                            self.getErrorFirebaseApiAuthentification(error: error as NSError)
                        }
                        self.isLoading = false
                        print(self.isLoading)
                        
                        
                    } )
                    .compactMap {authResult in
                        authResult?.user
                    }
                    .replaceError(with: nil)
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .assign(to: &$user)
    }
    
    func signOut() {
        signOutRequest
            .flatMap({ _ -> AnyPublisher<Bool, Never> in
                Just("")
                    .tryMap { _ in
                        try Auth.auth().signOut()
                    }
                    .handleEvents( receiveCompletion: { [unowned self] (completion) in
                        switch completion {
                        case .finished:
                            break
                        case .failure(let error):
                            print("❇️ AuthManager - sign out with error: \(error.localizedDescription)")
                            if let error = error as NSError? {
                                self.getErrorFirebaseApiAuthentification(error: error )
                            }
                        }
                        self.isLoading = false
                    })
                    .map({_ in return true})
                    .replaceError(with: false)
                    .eraseToAnyPublisher()
            })
            .sink { success in
                print("❇️ AuthManager - signout was successful: \(success)")
            }.store(in: &subscriptions)
    }
    
    
    func ResetPassword() {
        func updatePassord(password: String) async throws{
            guard let user = Auth.auth().currentUser else {
                throw URLError(.badServerResponse)
            }
            try await user.updatePassword(to: password)
        }
        
    }
    
    func addUser(username: (String, String)) {
        let context = PersistenceController.shared.container.viewContext
        let _ = UserData(username: username, context: context)
    }
    
    
    func signInGoogle () async throws {
        let tokens = try await SignInGoogleHelper.signIn()
        let authDataResults = try await FirebaseAuthAPI.shared.signInWithGoogle(tokens: tokens)
        self.user = authDataResults.user
        self.userManager?.addNewUser.send(authDataResults.user)
    }
    
    func signInApple() async throws {
        let helper = SignInAppleHelper()
        let tokens = try await helper.startSignInWithAppleFlow()
        let authDataResults = try await FirebaseAuthAPI.shared.signInWithApple(tokens: tokens)
        self.userManager?.addNewUser.send(authDataResults.user)
    }
    
    func verifyCodeAuth() {
        self.code = FirestoreUserAPI.generateCodeAuth()
        UserManager.sendMailCodeAuth(code: self.code!, email: self.email)
    }
}


