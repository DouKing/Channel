//===----------------------------------------------------------*- swift -*-===//
//
// Created by wuyikai on 2022/9/4.
// Copyright © 2022 wuyikai. All rights reserved.
//
//===----------------------------------------------------------------------===//

import Foundation

public struct Regular {
    public static func regulayExpression(regularExpress: String, validateString: String) -> [String] {
        do {
            let regex = try NSRegularExpression.init(pattern: regularExpress, options: [])
            let matches = regex.matches(in: validateString, options: [],
                                        range: NSRange(location: 0, length: validateString.count))
            var res: [String] = []
            for item in matches {
                let str = (validateString as NSString).substring(with: item.range)
                res.append(str)
            }
            return res
        } catch {
            return []
        }
    }
    
    public static func replace(validateStr: String, regularExpress: String, contentStr: String) -> String {
        do {
            let regrex = try NSRegularExpression.init(pattern: regularExpress, options: [])
            let modified = regrex.stringByReplacingMatches(in: validateStr, options: [],
                                                           range: NSRange(location: 0, length: validateStr.count),
                                                           withTemplate: contentStr)
            return modified
        } catch {
            return validateStr
        }
    }
    
    public static func validateMobile(_ number: String?) -> Bool {
        guard let number = number else {
            return false
        }
        
        let regx = "0?(13|14|15|18|17)[0-9]{9}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regx)
        return predicate.evaluate(with: number)
    }
}
