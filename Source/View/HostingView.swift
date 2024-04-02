//===----------------------------------------------------------*- Swift -*-===//
//
// Created by Yikai Wu on 2024/4/2.
// Copyright © 2024 Yikai Wu. All rights reserved.
//
//===----------------------------------------------------------------------===//

import UIKit
import SwiftUI

#if os(macOS)
public typealias PlatformViewType = NSView
#elseif !os(watchOS)
import UIKit
public typealias PlatformViewType = UIView
#endif

#if !os(watchOS)
@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
@MainActor open class HostingView<Content> : PlatformViewType where Content : View {
#if os(macOS)
    typealias HostingController = NSHostingController
#else
    typealias HostingController = UIHostingController
#endif
    
    private let hostingVC: HostingController<Content>
    
    public var rootView: Content {
        get { return self.hostingVC.rootView }
        set { self.hostingVC.rootView = newValue }
    }
    
    public init(rootView: Content, frame: CGRect = .zero) {
        self.hostingVC = HostingController(rootView: rootView)
        super.init(frame: frame)
        
        self.addSubview(self.hostingVC.view)
        self.hostingVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.hostingVC.view.topAnchor.constraint(equalTo: self.topAnchor),
            self.hostingVC.view.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.hostingVC.view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.hostingVC.view.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
    
    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
#endif
