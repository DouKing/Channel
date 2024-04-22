//===----------------------------------------------------------*- Swift -*-===//
//
// Created by wuyikai on 2024/3/28.
// Copyright © 2024 wuyikai. All rights reserved.
//
//===----------------------------------------------------------------------===//

import Foundation

public struct Swizzle {
    public func swizzleInstanceMethod(
        originCls: AnyClass, originSelector: Selector, 
        swizzCls: AnyClass, swizzSelector: Selector
    ) {
        guard let originMethod = class_getInstanceMethod(originCls, originSelector),
              let swizzMethod = class_getInstanceMethod(swizzCls, swizzSelector)
        else {
            return
        }
        
        let isAdd = class_addMethod(originCls,
                                    originSelector,
                                    method_getImplementation(swizzMethod),
                                    method_getTypeEncoding(swizzMethod))
        if isAdd {
            class_replaceMethod(swizzCls,
                                swizzSelector,
                                method_getImplementation(originMethod),
                                method_getTypeEncoding(originMethod))
        } else {
            method_exchangeImplementations(originMethod, swizzMethod)
        }
    }
}
