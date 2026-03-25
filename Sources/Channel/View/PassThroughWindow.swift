//===----------------------------------------------------------*- Swift -*-===//
//
// Created by Yikai Wu on 2026/3/25.
// Copyright © 2026 Yikai Wu. All rights reserved.
//
//===----------------------------------------------------------------------===//

import UIKit

public final class PassThroughWindow: UIWindow {
    private var handledEvents = Set<UIEvent>()
    
    public convenience init() {
        self.init(frame: .zero)
    }
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let rootViewController, let rootView = rootViewController.view else { return nil }
        
        guard let event else {
            return super.hitTest(point, with: event)
        }
        
        guard let hitView = super.hitTest(point, with: event) else {
            handledEvents.removeAll()
            return nil
        }
        
        if handledEvents.contains(event) {
            handledEvents.removeAll()
            return hitView
        }
        
        if #available(iOS 26, *) {
            handledEvents.insert(event)
            guard let name = rootView.layer.hitTest(point)?.name else {
                return hitView
            }
            
            if name.starts(with: "@"),
               let realHit = deepestHitView(in: rootView, at: point, with: event),
               realHit !== rootView {
                return realHit
            }
            
            return nil
        }
        
        if #available(iOS 18, *) {
            handledEvents.insert(event)
            return hitView
        }
        
        return hitView
    }
    
    private func deepestHitView(in root: UIView, at point: CGPoint, with event: UIEvent?) -> UIView? {
        guard !root.isHidden, root.alpha > 0.01, root.isUserInteractionEnabled else { return nil }
        
        for subview in root.subviews.reversed() {
            let pointInSubview = subview.convert(point, from: root)
            if let hit = deepestHitView(in: subview, at: pointInSubview, with: event) {
                return hit
            }
        }
        
        return root.point(inside: point, with: event) ? root : nil
    }
}
