//===----------------------------------------------------------*- swift -*-===//
//
// Created by wuyikai on 2022/8/18.
// Copyright © 2022 wuyikai. All rights reserved.
//
//===----------------------------------------------------------------------===//

import Foundation

extension Bundle {
    public var shortVersion: String? {
        infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    public var buildVersion: String? {
        infoDictionary?["CFBundleVersion"] as? String
    }
}
