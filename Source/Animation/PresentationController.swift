//===----------------------------------------------------------*- swift -*-===//
//
// Created by wuyikai on 2022/9/12.
// Copyright © 2022 wuyikai. All rights reserved.
//
//===----------------------------------------------------------------------===//

#if canImport(UIKit)

import UIKit

open class BasePresentationController: UIPresentationController {
    public var ignoreKeyboardShowing = false
    public private(set) var keyboardHeight: CGFloat = 0
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardDidChangeFrameNote(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil)
    }
    
    public override func presentationTransitionWillBegin() {
        guard let containerView = containerView else {
            return
        }
        containerView.backgroundColor = .clear
        presentingViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            containerView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        })
    }
    
    public override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        guard let containerView = containerView else {
            return
        }
        presentingViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            containerView.backgroundColor = .clear
        })
    }
    
    public override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
    
    @objc
    private func handleKeyboardDidChangeFrameNote(_ note: Notification) {
        if ignoreKeyboardShowing { return }
        guard let containerView = containerView else { return }
        guard let userInfo = note.userInfo,
              let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else {
            return
        }
        let convertedFrame = containerView.convert(frame, from: UIScreen.main.coordinateSpace)
        let intersectedKeyboardHeight = containerView.frame.intersection(convertedFrame).height
        keyboardHeight = intersectedKeyboardHeight
        
        animateWithKeyboard(notification: note) { [unowned self] _ in
            presentedView?.frame = frameOfPresentedViewInContainerView
        }
    }
}

open class AlertPresentationController: BasePresentationController {
    public override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }
        let width = 285.0
        let contentSize = CGSize(width: width, height: presentedViewController.preferredContentSize.height)
        let height = min(contentSize.height, containerView.frame.height - keyboardHeight)
        let x = (containerView.frame.width - contentSize.width) / 2.0
        let y = (containerView.frame.height - height - keyboardHeight) / 2.0
        return CGRect(x: x, y: y, width: width, height: height)
    }
}

open class ActionSheetPresentationController: BasePresentationController {
    public override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }
        let width = containerView.frame.width
        let contentSize = CGSize(width: width, height: presentedViewController.preferredContentSize.height)
        let height = min(contentSize.height, containerView.frame.height - keyboardHeight)
        let x = (containerView.frame.width - contentSize.width) / 2.0
        let y = (containerView.frame.height - height - keyboardHeight)
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    public override var presentedView: UIView? {
        let view = super.presentedView
        view?.setCornerRadii(CGSize(width: 10, height: 10), forRoundingCorners: [.topLeft, .topRight])
        return view
    }
}

func animateWithKeyboard(
    notification: Notification,
    animations: ((_ keyboardFrame: CGRect) -> Void)?
) {
    guard let userInfo = notification.userInfo else {
        animations?(.zero)
        return
    }
    // Extract the duration of the keyboard animation
    let durationKey = UIResponder.keyboardAnimationDurationUserInfoKey
    let duration = userInfo[durationKey] as? Double ?? 0.225
    
    // Extract the final frame of the keyboard
    let frameKey = UIResponder.keyboardFrameEndUserInfoKey
    let keyboardFrameValue = userInfo[frameKey] as? NSValue ?? .init(cgRect: .zero)
    
    // Extract the curve of the iOS keyboard animation
    let curveKey = UIResponder.keyboardAnimationCurveUserInfoKey
    let curveValue = userInfo[curveKey] as? Int ?? 7
    let curve = UIView.AnimationCurve(rawValue: curveValue) ?? .easeInOut
    
    // Create a property animator to manage the animation
    let animator = UIViewPropertyAnimator(
        duration: duration,
        curve: curve
    ) {
        // Perform the necessary animation layout updates
        animations?(keyboardFrameValue.cgRectValue)
    }
    
    // Start the animation
    animator.startAnimation()
}

#endif
