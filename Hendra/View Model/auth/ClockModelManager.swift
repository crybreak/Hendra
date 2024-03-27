//
//  ClockModel.swift
//  Hendra
//
//  Created by Wilfried Mac Air on 29/02/2024.
//

import Foundation
import Combine

class ClockModelManager: ObservableObject {
   
    @Published var second : Int = 240
    @Published var timeOut: Bool = false
    @Published var resendCode: Bool = false
        
    var subscriptions = Set<AnyCancellable>()


    init() {
        
        $resendCode
            .handleEvents(receiveOutput: {[unowned self ] _ in
                self.timeOut = false
            })
            .map { staus -> AnyPublisher<Int, Never> in
                Timer.publish(every: 1, on: .main, in: .common)
                       .autoconnect()
                       .scan(240) { (count, _ )in
                           return count - 1
                       }
                       .filter({$0 < 240 && $0 >= 0})
                       .eraseToAnyPublisher()
            }
            .switchToLatest()
            .assign(to: &$second)
        
        $second
            .sink { [unowned self]  second in
                if second == 0 {
                    self.timeOut = true
                }
            }.store(in: &subscriptions)
    }
}



