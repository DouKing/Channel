//===----------------------------------------------------------*- swift -*-===//
//
// Created by wuyikai on 2022/8/31.
// Copyright © 2022 wuyikai. All rights reserved.
//
//===----------------------------------------------------------------------===//

#if canImport(UIKit)

import UIKit.UIFont

extension UIFont {
    public struct Name: Hashable, Equatable, RawRepresentable, @unchecked Sendable {
        public let rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        public init(_ rawValue: String) {
            self.rawValue = rawValue
        }
    }
    
    public static func with(name: UIFont.Name, size: CGFloat = 10) -> Self? {
        Self(name: name.rawValue, size: size)
    }
    
    public convenience init?(name: UIFont.Name, size: CGFloat = 10) {
        self.init(name: name.rawValue, size: size)
    }
}

extension UIFont {
    public static var pingFangSCLight: UIFont? { .init(name: .PingFangSC.light) }
    public static var pingFangSCRegular: UIFont? { .init(name: .PingFangSC.regular) }
    public static var pingFangSCMedium: UIFont? { .init(name: .PingFangSC.medium) }
    public static var pingFangSCSemibold: UIFont? { .init(name: .PingFangSC.semibold) }
}

extension UIFont.Name {
    public struct PingFangSC {
        public static var light = UIFont.Name("PingFangSC-Light")
        public static var regular = UIFont.Name("PingFangSC-Regular")
        public static var medium = UIFont.Name("PingFangSC-Medium")
        public static var semibold = UIFont.Name("PingFangSC-Semibold")
    }
}

#endif
