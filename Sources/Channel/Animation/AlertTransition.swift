//===----------------------------------------------------------*- swift -*-===//
//
// Created by wuyikai on 2022/8/18.
// Copyright © 2022 wuyikai. All rights reserved.
//
//===----------------------------------------------------------------------===//

#if canImport(UIKit)

import UIKit

public class BaseTransition: NSObject, UIViewControllerAnimatedTransitioning {
    public enum `Type` {
        case present
        case dismiss
    }
    
    public let type: `Type`
    
    public init(type: `Type`) {
        self.type = type
    }
    
    private override init() {
        type = .present
    }
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        switch type {
        case .present:
            present(using: transitionContext)
        case .dismiss:
            dismiss(using: transitionContext)
        }
    }
    
    func present(using transitionContext: UIViewControllerContextTransitioning) {
        fatalError()
    }
    
    func dismiss(using transitionContext: UIViewControllerContextTransitioning) {
        fatalError()
    }
}

public class AlertTransition: BaseTransition {
    override func present(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toVC = transitionContext.viewController(forKey: .to), let toView = toVC.view else {
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            return
        }
        
        let containerView = transitionContext.containerView
        containerView.addSubview(toView)
        toView.frame = transitionContext.finalFrame(for: toVC)
        toView.alpha = 0
        
        UIView.animate(withDuration: 0.3) {
            toView.alpha = 1
        } completion: { finished in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
    
    override func dismiss(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from) else {
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            return
        }
        
        let containerView = transitionContext.containerView
        containerView.addSubview(fromView)
        
        UIView.animate(withDuration: 0.3) {
            fromView.alpha = 0
        } completion: { finished in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}

public class ActionSheetTransition: BaseTransition {
    override func present(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toVC = transitionContext.viewController(forKey: .to), let toView = toVC.view else {
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            return
        }
        
        let containerView = transitionContext.containerView
        containerView.addSubview(toView)
        let finalFrame = transitionContext.finalFrame(for: toVC)
        toView.frame = finalFrame.applying(CGAffineTransform(translationX: 0, y: finalFrame.height))
        
        UIView.animate(withDuration: 0.3) {
            toView.frame = finalFrame
        } completion: { finished in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
    
    override func dismiss(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let fromView = transitionContext.view(forKey: .from) else {
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            return
        }
        
        let containerView = transitionContext.containerView
        containerView.addSubview(fromView)
        
        let frame = transitionContext.finalFrame(for: fromVC)
        fromView.frame = frame
        
        UIView.animate(withDuration: 0.3) {
            fromView.frame = frame.applying(CGAffineTransform(translationX: 0, y: frame.height))
        } completion: { finished in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}

#endif
