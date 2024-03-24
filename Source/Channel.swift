//===----------------------------------------------------------*- swift -*-===//
//
// Created by Yikai Wu on 2024/3/24.
// Copyright © 2024 Yikai Wu. All rights reserved.
//
//===----------------------------------------------------------------------===//

import Foundation
// Enforce minimum Swift version for all platforms and build systems.
#if swift(<5.0)
#error("Channel doesn't support Swift versions below 5.0.")
#endif

public enum ChannelInfo {
    /// Current Channel version.
    public static let version = "1.0"
}
