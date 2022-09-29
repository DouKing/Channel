//===----------------------------------------------------------*- swift -*-===//
//
// Created by wuyikai on 2022/9/28.
// Copyright © 2022 wuyikai. All rights reserved.
//
//===----------------------------------------------------------------------===//

#if canImport(UIKit)

import UIKit

extension UIAlertAction {
    public var titleTextColor: UIColor? {
        get { value(forKey: "titleTextColor") as? UIColor }
        set { setValue(newValue, forKey: "titleTextColor") }
    }
}

extension UIAlertAction {
    public func withTitleTextColor(_ color: UIColor?) -> UIAlertAction {
        titleTextColor = color
        return self
    }
}

#endif
