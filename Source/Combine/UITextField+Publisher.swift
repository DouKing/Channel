//===----------------------------------------------------------*- swift -*-===//
//
// Created by wuyikai on 2022/9/2.
// Copyright © 2022 wuyikai. All rights reserved.
//
//===----------------------------------------------------------------------===//

#if canImport(UIKit)

import UIKit
import Combine

extension CombineWrapper where Base: UITextField {
    public var text: AnyPublisher<String?, Never> {
		return controlEvent([.allEditingEvents, .valueChanged]).map({ $0.text }).eraseToAnyPublisher()
	}
}

#endif
