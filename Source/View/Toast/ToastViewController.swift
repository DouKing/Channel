//===----------------------------------------------------------*- swift -*-===//
//
// Created by Yikai Wu on 2022/10/8.
// Copyright © 2022 Yikai Wu. All rights reserved.
//
//===----------------------------------------------------------------------===//

import UIKit

public class ToastViewController: UIViewController {
    public init(title: String) {
        super.init(nibName: nil, bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = .custom
        self.title = title
    }
    
    public override func loadView() {
        super.loadView()
        self.view = ToastView(title: title ?? "")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ToastViewController: UIViewControllerTransitioningDelegate {
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return ToastPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
