//===----------------------------------------------------------*- swift -*-===//
//
// Created by Yikai Wu on 2023/11/29.
// Copyright © 2023 Yikai Wu. All rights reserved.
//
//===----------------------------------------------------------------------===//

#if canImport(UIKit)
import Foundation
import UIKit.UIColor

@available(iOS 15.0, *)
public struct UIColorParseStrategy: ParseStrategy {
    public func parse(_ value: String) throws -> UIColor {
        return value.color()
    }
}

@available(iOS 15.0, *)
public struct UIColorFormatStyle: ParseableFormatStyle {
    private let locale: Locale
    private var alpha: Bool
    
    public init(locale: Locale = .current, alpha: Bool = false) {
        self.locale = locale
        self.alpha = alpha
    }
    
    public var parseStrategy: UIColorParseStrategy {
        return UIColorParseStrategy()
    }
    
    public func format(_ value: UIColor) -> String {
        let (r, g, b, a) = value.components()
        let red = String(format: "%02X", Int(r * 0xff))
        let green = String(format: "%02X", Int(g * 0xff))
        let blue = String(format: "%02X", Int(b * 0xff))
        var result = "#\(red)\(green)\(blue)"
        if self.alpha {
            let alpha = String(format: "%02X", Int(a * 0xff))
            result += alpha
        }
        return result
    }
}

@available(iOS 15.0, *)
extension UIColorFormatStyle {
    public func alpha(_ alpha: Bool) -> Self {
        guard self.alpha != alpha else { return self }
        var result = self
        result.alpha = alpha
        return result
    }
}

@available(iOS 15.0, *)
extension FormatStyle where Self == UIColorFormatStyle {
    public static var uiColor: UIColorFormatStyle {
        UIColorFormatStyle()
    }
}

@available(iOS 15.0, *)
extension UIColor {
    public func formatted<F>(_ format: F) -> F.FormatOutput
    where F: FormatStyle, F.FormatInput == UIColor, F.FormatOutput == String {
        format.format(self)
    }
    
    public func formatted() -> String {
        UIColorFormatStyle().format(self)
    }
}

#endif
