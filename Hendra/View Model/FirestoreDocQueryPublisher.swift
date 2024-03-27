//
//  FirestoreDocQueryPublisher.swift
//  Hendra
//
//  Created by Wilfried Mac Air on 09/03/2024.
//

import Foundation
import FirebaseFirestore
import Combine

struct FirestoreDocQueryPublisher: Publisher {
    typealias Output = QuerySnapshot
    typealias Failure = Error
    
    let ref: Query
    init(ref: Query) {
        self.ref = ref
    }
    
    func receive<S>(subscriber: S) where S : Subscriber,
                                         Self.Failure == S.Failure,
                                        Self.Output == S.Input {
        let sub = FirestoreDocQuerySubscription(ref: ref, subscriber: subscriber)
        subscriber.receive(subscription: sub)
    }
}

class FirestoreDocQuerySubscription<S: Subscriber>: Subscription where S.Input ==  QuerySnapshot ,
                                                               S.Failure == Error {
    
    private var subscriber: S?
    var currentDemand = Subscribers.Demand.none
    var handle: ListenerRegistration?
    
    init(ref: Query, subscriber: S) {
        self.subscriber = subscriber
        handle =  ref.addSnapshotListener { [weak self] (snap, error) in
            
            if let currentDemand = self?.currentDemand,
               currentDemand > 0 {
                if let error = error {
                    self?.subscriber?.receive(completion: .failure(error))
                }else if let snap = snap {
                    if let newAdditionalDemand = self?.subscriber?.receive(snap) {
                        self!.currentDemand -= 1
                        self!.currentDemand += newAdditionalDemand
                    }
                }
            }
        }
    }
    
    func request(_ demand: Subscribers.Demand) {
        currentDemand += demand
    }
    
    func cancel() {
        subscriber = nil
        handle?.remove()
    }
 
}

