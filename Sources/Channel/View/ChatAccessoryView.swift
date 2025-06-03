//===----------------------------------------------------------*- swift -*-===//
//
// Created by wuyikai on 2022/8/25.
// Copyright © 2022 wuyikai. All rights reserved.
//
//===----------------------------------------------------------------------===//

#if canImport(UIKit)

import UIKit

class ChatAccessoryView: UIView {
	let minHeight: CGFloat = 44
	let maxHeight: CGFloat = 100
	let verticalPadding: CGFloat = 8
    
    var didChangeHeight: ((CGFloat) -> Void)?

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupSubviews()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupSubviews()
	}

	override func didMoveToSuperview() {
		super.didMoveToSuperview()
		if #available(iOS 11.0, *) {
			if let window = window {
				bottomAnchor.constraint(lessThanOrEqualToSystemSpacingBelow: window.safeAreaLayoutGuide.bottomAnchor, multiplier: 1.0).isActive = true
			}
		}
	}

	override var intrinsicContentSize: CGSize {
		var newSize = self.bounds.size
		newSize.height = minHeight + verticalPadding * 2

		if textView.bounds.size.height > 0 {
			newSize.height = textView.bounds.size.height + verticalPadding * 2
		}
		if newSize.height > maxHeight + verticalPadding * 2 {
			newSize.height = maxHeight + verticalPadding * 2
		}
		return newSize
	}

	private func setupSubviews() {
		translatesAutoresizingMaskIntoConstraints = false
		addSubview(textView)
		addSubview(sendButton)
		NSLayoutConstraint.activate([
			sendButton.widthAnchor.constraint(equalToConstant: 100),
			sendButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: verticalPadding),
			sendButton.heightAnchor.constraint(equalToConstant: minHeight),
			sendButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -verticalPadding),

			textView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: verticalPadding),
			textView.topAnchor.constraint(equalTo: self.topAnchor, constant: verticalPadding),
			textView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -verticalPadding),
			textView.rightAnchor.constraint(equalTo: sendButton.leftAnchor, constant: verticalPadding)
		])
	}
	
	lazy var textView: UITextView = {
		let tv = GrowingTextView()
		tv.translatesAutoresizingMaskIntoConstraints = false
		tv.delegate = self
		tv.minHeight = minHeight
		tv.maxHeight = maxHeight
		tv.placeholder = NSLocalizedString("输入内容", comment: "")
		return tv
	}()

	lazy var sendButton: UIButton = {
		let btn = UIButton(type: .system)
		btn.translatesAutoresizingMaskIntoConstraints = false
		btn.setTitle(NSLocalizedString("发送", comment: ""), for: .normal)
		return btn
	}()
}

extension ChatAccessoryView: GrowingTextViewDelegate {
	func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        didChangeHeight?(height + 16)
	}
}

#endif
