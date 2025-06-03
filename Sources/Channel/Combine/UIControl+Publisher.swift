//===----------------------------------------------------------*- swift -*-===//
//
// Created by wuyikai on 2022/9/2.
// Copyright © 2022 wuyikai. All rights reserved.
//
//===----------------------------------------------------------------------===//

#if canImport(UIKit)

import UIKit
import Combine

extension UIControl: Combinable {}

extension CombineWrapper where Base: UIControl {
	public func controlEvent(_ events: UIControl.Event) -> AnyPublisher<Base, Never> {
		return ControlEventPublisher<Base>.init(control: self.base, events: events).eraseToAnyPublisher()
	}
}

struct ControlEventPublisher<Control: UIControl>: Publisher {
	typealias Output = Control
	typealias Failure = Never

	let control: Control
	let events: UIControl.Event

	init(control: Control, events: UIControl.Event) {
		self.control = control
		self.events = events
	}

	func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
		let subject = PassthroughSubject<Output, Failure>()

		let target = ControlTarget(control: self.control, events: self.events) {
			subject.send($0)
		}

		subject
			.handleEvents(receiveCancel: {
				target.cancel()
			})
			.receive(subscriber: subscriber)
	}
}

private class ControlTarget<Control: UIControl>: Cancellable {
	weak var control: Control?
	let events: UIControl.Event

	typealias Callback = (Control) -> Void
	var callback: Callback?

	init(control: Control, events: UIControl.Event, callback: @escaping Callback) {
		self.control = control
		self.events = events
		self.callback = callback
		self.control?.addTarget(self, action: #selector(self.run), for: events)
	}

	@objc func run() {
		guard let control = self.control, let callback = self.callback else {
			return
		}
		callback(control)
	}

	func cancel() {
		self.control?.removeTarget(self, action: #selector(self.run), for: self.events)
		self.callback = nil
	}
}

#endif
