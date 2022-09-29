//===----------------------------------------------------------*- swift -*-===//
//
// Created by wuyikai on 2022/9/2.
// Copyright © 2022 wuyikai. All rights reserved.
//
//===----------------------------------------------------------------------===//

import Foundation

public protocol CombineWrapper {
	associatedtype Base
	var base: Base { get }
	init(_ base: Base)
}

public struct AnyCombineWrapper<Base>: CombineWrapper {
	public let base: Base
	public init(_ base: Base) {
		self.base = base
	}
}

public protocol Combinable {}

extension Combinable {
	public var combine: AnyCombineWrapper<Self> {
		return AnyCombineWrapper(self)
	}

	public static var combine: AnyCombineWrapper<Self>.Type {
		return AnyCombineWrapper.self
	}
}
