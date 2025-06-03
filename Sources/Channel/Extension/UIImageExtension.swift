//===----------------------------------------------------------*- swift -*-===//
//
// Created by wuyikai on 2022/9/5.
// Copyright © 2022 wuyikai. All rights reserved.
//
//===----------------------------------------------------------------------===//

#if canImport(UIKit)

import UIKit

extension UIImage {
    public struct Name: Hashable, Equatable, RawRepresentable, @unchecked Sendable {
        public let rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        public init(_ rawValue: String) {
            self.rawValue = rawValue
        }
    }
    
    public convenience init?(named: UIImage.Name) {
        self.init(named: named.rawValue)
    }
}

#endif
