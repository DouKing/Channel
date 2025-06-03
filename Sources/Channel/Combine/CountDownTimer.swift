//===----------------------------------------------------------*- swift -*-===//
//
// Created by wuyikai on 2022/9/4.
// Copyright © 2022 wuyikai. All rights reserved.
//
//===----------------------------------------------------------------------===//

import Foundation
import Combine

public struct CountDownTimer: Publisher {
    public struct TimeRemaining: CustomStringConvertible {
        public let min, seconds, totalSeconds: Int
        
        public var description: String {
            String(totalSeconds)
        }
    }
    
    public typealias Output = TimeRemaining
    public typealias Failure = Never
    
    public let duration: TimeInterval
    public init(duration: TimeInterval) {
        self.duration = duration
    }
    
    public func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, Output == S.Input {
        let subscription = CountDownSubscription(duration: duration, subscriber: subscriber)
        subscriber.receive(subscription: subscription)
    }
}

private extension CountDownTimer {
    class CountDownSubscription<S: Subscriber>: Subscription where S.Input == Output, S.Failure == Failure {
        private var duration: Int
        private var subscriber: S?
        private var timer: Timer?
        
        init(duration: TimeInterval, subscriber: S) {
            self.duration = Int(duration)
            self.subscriber = subscriber
        }
        
        func request(_ demand: Subscribers.Demand) {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { timer in
                self.duration -= 1
                if self.duration == 0 {
                    self.subscriber?.receive(completion: .finished)
                } else {
                    let components = self.durationToTimeComponents(self.duration)
                    let timeRemaining = TimeRemaining(min: components.min, seconds: components.seconds, totalSeconds: self.duration)
                    _ = self.subscriber?.receive(timeRemaining)
                }
            })
            timer?.fire()
        }
        
        func cancel() {
            timer?.invalidate()
        }
        
        func durationToTimeComponents(_ duration: Int) ->(min: Int, seconds: Int) {
            return (min: duration / 60, seconds: duration % 60)
        }
    }
}
