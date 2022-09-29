//===----------------------------------------------------------*- swift -*-===//
//
// Created by wuyikai on 2022/9/7.
// Copyright © 2022 wuyikai. All rights reserved.
//
//===----------------------------------------------------------------------===//

#if canImport(UIKit)

import UIKit

public protocol ConstraintsConvertable {
    var constraints: [NSLayoutConstraint] { get }
}

extension Array: ConstraintsConvertable where Element: NSLayoutConstraint {
    public var constraints: [NSLayoutConstraint] { self }
}

extension NSLayoutConstraint: ConstraintsConvertable {
    public var constraints: [NSLayoutConstraint] { [self] }
}

extension NSLayoutConstraint {
    public class func activate(_ constraints: [ConstraintsConvertable]) {
        var results: [NSLayoutConstraint] = []
        for item in constraints {
            results.append(contentsOf: item.constraints)
        }
        activate(results)
    }
}

extension UIView {
    public class EdgesMaker {
        typealias Edges = (NSLayoutYAxisAnchor, NSLayoutXAxisAnchor, NSLayoutYAxisAnchor, NSLayoutXAxisAnchor)
        let edges: Edges
        unowned let view: UIView
        
        init(edges: Edges, view: UIView) {
            self.edges = edges
            self.view = view
        }
        
        public func constraints(equalTo view: UIView, inserts: UIEdgeInsets = .zero, exclude: Edge = []) -> [NSLayoutConstraint] {
            var results: [NSLayoutConstraint] = []
            
            if !exclude.contains(.top) {
                results.append(edges.0.constraint(equalTo: view.topAnchor, constant: inserts.top))
            }
            
            if !exclude.contains(.leading) {
                results.append(edges.1.constraint(equalTo: view.leadingAnchor, constant: inserts.left))
            }
            
            if !exclude.contains(.bottom) {
                results.append(edges.2.constraint(equalTo: view.bottomAnchor, constant: inserts.bottom))
            }
            
            if !exclude.contains(.trailing) {
                results.append(edges.3.constraint(equalTo: view.trailingAnchor, constant: inserts.right))
            }
            
            return results
        }
        
        public func constraints(equalToSafeArea view: UIView, inserts: UIEdgeInsets = .zero, exclude: Edge = []) -> [NSLayoutConstraint] {
            var results: [NSLayoutConstraint] = []
            
            if !exclude.contains(.top) {
                results.append(edges.0.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: inserts.top))
            }
            
            if !exclude.contains(.leading) {
                results.append(edges.1.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: inserts.left))
            }
            
            if !exclude.contains(.bottom) {
                results.append(edges.2.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: inserts.bottom))
            }
            
            if !exclude.contains(.trailing) {
                results.append(edges.3.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: inserts.right))
            }
            
            return results
        }
        
        public func fill(inserts: UIEdgeInsets = .zero, exclude: Edge = []) -> [NSLayoutConstraint] {
            guard let superview = view.superview else {
                return []
            }
            return constraints(equalTo: superview, inserts: inserts, exclude: exclude)
        }
        
        public func fillToSafeArea(inserts: UIEdgeInsets = .zero, exclude: Edge = []) -> [NSLayoutConstraint] {
            guard let superview = view.superview else {
                return []
            }
            return constraints(equalToSafeArea: superview, inserts: inserts, exclude: exclude)
        }
    }
    
    public struct Edge : OptionSet, @unchecked Sendable {
        public let rawValue: UInt
        
        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }
        
        public static let top: Edge = .init(rawValue: 1 << 0)
        public static let leading: Edge = .init(rawValue: 1 << 1)
        public static let bottom: Edge = .init(rawValue: 1 << 2)
        public static let trailing: Edge = .init(rawValue: 1 << 3)
    }
    
    public var edgesAnchor: EdgesMaker {
        EdgesMaker(edges: (topAnchor, leadingAnchor, bottomAnchor, trailingAnchor),
                   view: self)
    }
}

#endif
