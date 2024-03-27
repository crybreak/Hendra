//
//  FirestoreCollectionPublisher.swift
//  Hendra
//
//  Created by Wilfried Mac Air on 09/03/2024.
//


import Foundation
import FirebaseFirestore
import Combine

struct FirestoreCollectionPublisher: Publisher {
    typealias Output = [QueryDocumentSnapshot]
    typealias Failure = Error
    
    let ref: CollectionReference
    init(ref: CollectionReference) {
        self.ref = ref
    }
    
    func receive<S>(subscriber: S) where S : Subscriber,
                                         Self.Failure == S.Failure,
                                         Self.Output == S.Input {
        let sub = FirestoreCollectionSubscription(ref: ref, subscriber: subscriber)
        subscriber.receive(subscription: sub)
    }
}

class FirestoreCollectionSubscription<S: Subscriber>: Subscription where S.Input == [QueryDocumentSnapshot] ,
                                                               S.Failure == Error {
    
    private var subscriber: S?
    var currentDemand = Subscribers.Demand.none
    var handle: ListenerRegistration?
    
    init(ref: CollectionReference, subscriber: S) {
        self.subscriber = subscriber
        handle =  ref.addSnapshotListener { [weak self] (snap, error) in
            
            if let currentDemand = self?.currentDemand,
               currentDemand > 0 {
                if let error = error {
                    self?.subscriber?.receive(completion: .failure(error))
                }else if let snap = snap {
                    if let newAdditionalDemand = self?.subscriber?.receive(snap.documents) {
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
