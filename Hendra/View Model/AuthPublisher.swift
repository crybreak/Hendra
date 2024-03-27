//
//  AuthPublisher.swift
//  Hendra
//
//  Created by Wilfried Mac Air on 26/02/2024.
//

import Foundation
import Combine
import FirebaseAuth

struct AuthPublisher: Publisher {
    typealias Output = User?
    typealias Failure = Never
    
    func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, User? == S.Input {
        subscriber.receive(subscription: AuthSubscription(subscriber: subscriber))
    }
}

class AuthSubscription<S: Subscriber>: Subscription where S.Input == User?, S.Failure == Never {
    
    private var subscriber: S?
    var currentDemand = Subscribers.Demand.none

    var handle: AuthStateDidChangeListenerHandle?

    
    init (subscriber: S) {
        self.subscriber = subscriber
        handle = Auth.auth().addStateDidChangeListener{ [unowned self] (auth, user) in
           
            if  self.currentDemand > 0,
               let newAddintionnalDemand = self.subscriber?.receive(user) {
                self.currentDemand -= 1
                self.currentDemand += newAddintionnalDemand
            }
            
        }
    }
    
    func request(_ demand: Subscribers.Demand) {
        self.currentDemand += demand
    }
    
    func cancel() {
        subscriber = nil
        
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}
