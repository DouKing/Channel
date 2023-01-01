//===----------------------------------------------------------*- swift -*-===//
//
// Created by Yikai Wu on 2022/10/8.
// Copyright © 2022 Yikai Wu. All rights reserved.
//
//===----------------------------------------------------------------------===//

#if canImport(UIKit)

import UIKit

public class ToastPresentationController: UIPresentationController {
    public override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView,
              let presentedView = presentedView
        else { return .zero }
        
        return presentedView.autoresizeFrame(on: containerView)
    }
    
    public override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
    
    public override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        presentedView?.layer.cornerRadius = 12
    }
}

#endif
