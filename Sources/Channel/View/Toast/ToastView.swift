//===----------------------------------------------------------*- swift -*-===//
//
// Created by Yikai Wu on 2023/1/1.
// Copyright © 2023 Yikai Wu. All rights reserved.
//
//===----------------------------------------------------------------------===//

#if canImport(UIKit)

import UIKit

public class ToastView: UIView {
    let title: String

    public init(title: String) {
        self.title = title
        super.init()
        
        let view = self
        
        view.backgroundColor = .black
        view.layer.cornerRadius = 12
        
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 0
        
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
    
    private override init(frame: CGRect) {
        title = ""
        super.init(frame: frame)
    }
    
    required internal init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIView {
    func autoresizeFrame(on containerView: UIView) -> CGRect {
        let presentedView = self
        let inset: CGFloat = 60
        
        // Make sure to account for the safe area insets
        let safeAreaFrame = containerView.bounds
            .inset(by: containerView.safeAreaInsets)
        
        let fittingWidth = safeAreaFrame.width - 2 * inset
        let fittingSize = CGSize(
            width: fittingWidth,
            height: UIView.layoutFittingCompressedSize.height
        )
        let targetSize = presentedView.systemLayoutSizeFitting(
            fittingSize, withHorizontalFittingPriority: .fittingSizeLevel,
            verticalFittingPriority: .defaultLow)
        let targetHeight = targetSize.height
        let targetWidth = targetSize.width
        
        var frame = safeAreaFrame
        frame.origin.x += inset + (fittingWidth - targetWidth) / 2
        frame.origin.y += frame.size.height - targetHeight - inset
        frame.size.width = targetWidth
        frame.size.height = targetHeight
        return frame
    }
}

#endif
