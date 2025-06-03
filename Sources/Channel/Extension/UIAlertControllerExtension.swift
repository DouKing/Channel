//===----------------------------------------------------------*- swift -*-===//
//
// Created by wuyikai on 2022/9/28.
// Copyright © 2022 wuyikai. All rights reserved.
//
//===----------------------------------------------------------------------===//

#if canImport(UIKit)

import UIKit

extension UIAlertAction {
    private enum Key: String {
        case titleTextColor
        case titleTextAlignment
        case image
        case imageTintColor
    }
    
    public var titleTextColor: UIColor? {
        get { value(forKey: Key.titleTextColor.rawValue) as? UIColor }
        set { setValue(newValue, forKey: Key.titleTextColor.rawValue) }
    }
    
    public var titleTextAlignment: NSTextAlignment? {
        get { value(forKey: Key.titleTextAlignment.rawValue) as? NSTextAlignment }
        set { setValue(newValue, forKey: Key.titleTextAlignment.rawValue) }
    }
    
    public var image: UIImage? {
        get { value(forKey: Key.image.rawValue) as? UIImage }
        set { setValue(newValue, forKey: Key.image.rawValue) }
    }
    
    public var imageTintColor: UIColor? {
        get { value(forKey: Key.imageTintColor.rawValue) as? UIColor }
        set { setValue(newValue, forKey: Key.imageTintColor.rawValue) }
    }
}

extension UIAlertAction {
    public func withTitleTextColor(_ color: UIColor?) -> UIAlertAction {
        titleTextColor = color
        return self
    }
}

extension UIAlertController {
    private enum Key: String {
        case attributedTitle
        case attributedMessage
        case contentViewController
    }
    
    public var attributedTitle: NSAttributedString? {
        get { value(forKey: Key.attributedTitle.rawValue) as? NSAttributedString }
        set { setValue(newValue, forKey: Key.attributedTitle.rawValue) }
    }
    
    public var attributedMessage: NSAttributedString? {
        get { value(forKey: Key.attributedMessage.rawValue) as? NSAttributedString }
        set { setValue(newValue, forKey: Key.attributedMessage.rawValue) }
    }
    
    public var contentViewController: UIViewController? {
        get { value(forKey: Key.contentViewController.rawValue) as? UIViewController }
        set { setValue(newValue, forKey: Key.contentViewController.rawValue) }
    }
}

#endif
