//===----------------------------------------------------------*- swift -*-===//
//
// Created by Yikai Wu on 2023/1/1.
// Copyright © 2023 Yikai Wu. All rights reserved.
//
//===----------------------------------------------------------------------===//

#if canImport(UIKit)

import UIKit

extension UIViewController {
    
    /// 在当前 view controller 模态展示 toast
    /// - Parameters:
    ///   - message: 展示的内容
    ///   - duration: 持续时长，默认 2s
    public func toast(_ message: String, duration: DispatchTimeInterval = .seconds(2)) {
        if message.isEmpty { return }
        let toast = ToastViewController(title: message)
        present(toast, animated: true)
        DispatchQueue.main.asyncAfter(duration) {
            toast.dismiss(animated: true)
        }
    }
}

extension UIView {
    
    /// 在当前 view 展示 toast
    /// - Parameters:
    ///   - message: 展示的内容
    ///   - duration: 持续时长，默认 2s
    public func toast(_ message: String, duration: DispatchTimeInterval = .seconds(2)) {
        if message.isEmpty { return }
        let toast = ToastView(title: message)
        
        let finalFrame = toast.autoresizeFrame(on: self)
        var initialFrame = finalFrame
        initialFrame.origin.y = self.bounds.maxY
        toast.frame = initialFrame
        toast.alpha = 0
        
        addSubview(toast)
        
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut, .allowUserInteraction]) {
            toast.alpha = 1
            toast.frame = finalFrame
        } completion: { _ in
            DispatchQueue.main.asyncAfter(duration) {
                UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseIn, .beginFromCurrentState]) {
                    toast.alpha = 0
                    toast.frame = initialFrame
                } completion: { _ in
                    toast.removeFromSuperview()
                }
            }
        }
    }
}

#endif
