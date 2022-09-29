//===----------------------------------------------------------*- swift -*-===//
//
// Created by wuyikai on 2022/8/18.
// Copyright © 2022 wuyikai. All rights reserved.
//
//===----------------------------------------------------------------------===//

#if canImport(WebKit)

import Foundation
import WebKit

public struct UserAgent {
    static func webViewUserAgent() -> String {
        let uaKey = "kABUserAgentKey"
        var ua = UserDefaults.standard.string(forKey: uaKey)
        var finish = ua != nil && !ua!.isEmpty
        
        var webView: WKWebView? = WKWebView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        webView?.evaluateJavaScript("navigator.userAgent") { (result: Any?, _: Error?) in
            var userAgent = ""
            if let result = result as? String {
                userAgent += result
                userAgent += " "
            }
            let bundleId = Bundle.main.bundleIdentifier ?? "xx"
            let version = Bundle.main.shortVersion ?? "0.0"
            userAgent += bundleId + "/" + version
            UserDefaults.standard.set(ua, forKey: uaKey)
            
            ua = userAgent
            finish = true
            webView = nil
        }
        
        while !finish {
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.01))
        }
        
        return ua ?? ""
    }
    
    public static func register() {
        let userAgent: String
#if DEBUG
        let startTime = CACurrentMediaTime()
        defer {
            let endTime = CACurrentMediaTime()
            debugPrint("UA cost: \(endTime - startTime)s", userAgent)
        }
#endif
        userAgent = webViewUserAgent()
        UserDefaults.standard.register(defaults: ["UserAgent": userAgent])
    }
}

#endif
