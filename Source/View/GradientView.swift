//===----------------------------------------------------------*- swift -*-===//
//
// Created by wuyikai on 2022/8/31.
// Copyright © 2022 wuyikai. All rights reserved.
//
//===----------------------------------------------------------------------===//

#if canImport(UIKit)

import UIKit

public class GradientView: UIView {
    let maskLayer: CAGradientLayer = CAGradientLayer()
    
    public class var `default`: GradientView {
        GradientView(
            colors: [UIColor("#6af2b7").cgColor, UIColor("#A7F284").cgColor],
            locations: [0, 1],
            startPoint: CGPoint(x: 0.25, y: 0.5),
            endPoint: CGPoint(x: 0.75, y: 0.5))
    }
    
    public convenience init(colors: [CGColor], locations: [NSNumber], startPoint: CGPoint, endPoint: CGPoint) {
        self.init(frame: .zero)
        maskLayer.colors = colors
        maskLayer.startPoint = startPoint
        maskLayer.endPoint = endPoint
        maskLayer.locations = locations
        maskLayer.frame = CGRect(origin: .zero, size: frame.size)
        layer.addSublayer(maskLayer)
    }
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        let radio = 1 + 1.0 / CGFloat(maskLayer.colors?.count ?? 2)
        maskLayer.frame = CGRect(x: 0, y: 0, width: layer.frame.width * radio, height: layer.frame.height * radio)
    }
}

#endif
