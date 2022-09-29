//===----------------------------------------------------------*- swift -*-===//
//
// Created by wuyikai on 2022/8/25.
// Copyright © 2022 wuyikai. All rights reserved.
//
//===----------------------------------------------------------------------===//

#if canImport(UIKit)

import UIKit

extension NSDiffableDataSourceSnapshot {
    public func sectionIdentifier(for indexPath: IndexPath) -> SectionIdentifierType? {
        let section = indexPath.section
        if section < sectionIdentifiers.count {
            return sectionIdentifiers[section]
        }
        return nil
    }
}

#endif
