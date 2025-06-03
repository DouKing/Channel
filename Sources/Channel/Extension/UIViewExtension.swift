//===----------------------------------------------------------*- swift -*-===//
//
// Created by wuyikai on 2022/9/12.
// Copyright © 2022 wuyikai. All rights reserved.
//
//===----------------------------------------------------------------------===//

#if canImport(UIKit)

import UIKit
import Channel_Private

extension UIView {
    public func setCornerRadii(_ cornerRadii: CGSize, forRoundingCorners corners: UIRectCorner) {
        let maskPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: cornerRadii)
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = maskPath.cgPath
        layer.mask = maskLayer
    }
    
    public func disableCapture() {
        self.layer.disableCapture()
    }
}

#endif
