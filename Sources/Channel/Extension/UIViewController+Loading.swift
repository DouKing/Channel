//===----------------------------------------------------------*- swift -*-===//
//
// Created by wuyikai on 2022/8/28.
// Copyright © 2022 wuyikai. All rights reserved.
//
//===----------------------------------------------------------------------===//

#if canImport(UIKit)

import UIKit

private let kLoadingViewTag = 99889

extension UIViewController {
    public var loadingView: UIActivityIndicatorView {
        let activity = (self.view.viewWithTag(kLoadingViewTag) as? UIActivityIndicatorView) ??
        UIActivityIndicatorView(style: .medium)
        // activity.backgroundColor = .lightGray
        activity.tag = kLoadingViewTag
        return activity
    }
    
    @objc public func showLoading() {
        let loadingView = self.loadingView
        self.view.addSubview(loadingView)
        loadingView.center = CGPoint(x: view.frame.size.width / 2,
                                     y: view.frame.size.height / 2)
        loadingView.startAnimating()
    }
    
    @objc public func stopLoading() {
        self.loadingView.stopAnimating()
        self.loadingView.removeFromSuperview()
    }
}

#endif
