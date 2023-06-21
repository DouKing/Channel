//===----------------------------------------------------------*- swift -*-===//
//
// Created by wuyikai on 2022/9/25.
// Copyright © 2022 wuyikai. All rights reserved.
//
//===----------------------------------------------------------------------===//

import UIKit

public protocol Reusable {
    static var id: String { get }
}

extension UICollectionReusableView: Reusable {}
extension UICollectionReusableView {
    public class var id: String {
        NSStringFromClass(self.self)
    }
}

extension UITableViewCell: Reusable {}
extension UITableViewCell {
    public class var id: String {
        NSStringFromClass(self.self)
    }
}

extension UITableViewHeaderFooterView: Reusable {}
extension UITableViewHeaderFooterView {
    public static var id: String {
        NSStringFromClass(self.self)
    }
}
