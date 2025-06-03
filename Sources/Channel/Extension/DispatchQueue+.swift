//===----------------------------------------------------------*- swift -*-===//
//
// Created by wuyikai on 2022/9/21.
// Copyright © 2022 wuyikai. All rights reserved.
//
//===----------------------------------------------------------------------===//

import Foundation

extension DispatchQueue {
    public func asyncAfter(
        _ fromNow: DispatchTimeInterval,
        qos: DispatchQoS = .unspecified,
        flags: DispatchWorkItemFlags = [],
        execute work: @escaping @convention(block) () -> Void
    ) {
        asyncAfter(deadline: .now() + fromNow, qos: qos, flags: flags, execute: work)
    }
}
