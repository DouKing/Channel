#if canImport(UIKit)

import UIKit

public protocol IBConstructible: AnyObject {
  static var nibName: String { get }
  static var bundle: Bundle { get }
}

extension IBConstructible {
  public static var nibName: String {
    return String(describing: Self.self)
  }

  public static var bundle: Bundle {
    return Bundle(for: Self.self)
  }
}

extension IBConstructible where Self: UIViewController {
  static var fromNib: Self {
    let storyboard = UIStoryboard(name: nibName, bundle: bundle)
    guard let viewController = storyboard.instantiateInitialViewController() as? Self else {
      fatalError("Missing view controller in \(nibName).storyboard")
    }
    return viewController
  }
}

extension IBConstructible where Self: UIView {
  public static var fromNib: Self {
    let xib = UINib(nibName: nibName, bundle: bundle)
    guard let view = xib.instantiate(withOwner: nil, options: nil).first as? Self else {
      fatalError("Missing view in \(nibName).xib")
    }
    return view
  }
}

extension UIView: IBConstructible {}
extension UIViewController: IBConstructible {}

#endif
