//===----------------------------------------------------------*- swift -*-===//
//
// Created by wuyikai on 2022/9/2.
// Copyright © 2022 wuyikai. All rights reserved.
//
//===----------------------------------------------------------------------===//

import Foundation
import Combine

public protocol Binder {
	associatedtype Value
	func onNext(_ value: Value)
}

public struct AnyBinder<Value>: Binder {
	private let action: (Value) -> Void

	public init(_ onNext: @escaping (Value) -> Void) {
		self.action = onNext
	}

	public func onNext(_ value: Value) {
		self.action(value)
	}
}

// swiftlint:disable force_cast
extension AnyBinder {
	public init<S: Scheduler, Target: AnyObject>(
        scheduler: S = DispatchQueue.main as! S,
        target: Target,
        action: @escaping (Target, Value) -> Void
    ) {
		weak var weakTarget = target
		self.action = { value in
			scheduler.schedule {
				guard let target = weakTarget else { return }
				action(target, value)
			}
		}
	}
}
// swiftlint:enable force_cast

extension Binder {
	public func eraseToAnyBinder() -> AnyBinder<Value> {
		return .init(self.onNext)
	}
}

extension Publisher where Failure == Never {
	public func bind<B: Binder>(to binder: B) -> AnyCancellable where B.Value == Output {
		return self.sink(receiveValue: { (v) in
			binder.onNext(v)
		})
	}

	public func bindTo<B1: Binder, B2: Binder>(_ b1: B1, _ b2: B2) -> AnyCancellable where Output == (B1.Value, B2.Value) {
		return self.sink(receiveValue: {
			b1.onNext($0.0)
			b2.onNext($0.1)
		})
	}

	public func bindTo<B1: Binder, B2: Binder, B3: Binder>(
        _ b1: B1, _ b2: B2, _ b3: B3
    ) -> AnyCancellable where Output == (B1.Value, B2.Value, B3.Value) {
		return self.sink(receiveValue: {
			b1.onNext($0.0)
			b2.onNext($0.1)
			b3.onNext($0.2)
		})
	}
}
