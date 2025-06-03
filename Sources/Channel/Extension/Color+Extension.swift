//===----------------------------------------------------------*- swift -*-===//
//
// Created by wuyikai on 2022/8/18.
// Copyright © 2022 wuyikai. All rights reserved.
//
//===----------------------------------------------------------------------===//

#if canImport(UIKit)
import UIKit

// -----------------------------------------------------------------------------
// MARK: - HEX
// -----------------------------------------------------------------------------

extension UIColor {
    public static func hex(_ hex: Int) -> UIColor {
        return UIColor(hex: hex)
    }
    
    public static func hex(_ hex: String) -> UIColor {
        return UIColor(hexString: hex)
    }
    
    public convenience init(_ hexString: String) {
        self.init(hexString: hexString, alpha: 1.0)
    }
    
	/// 根据十六进制生成颜色
	/// 3 位数及 6 位数，代表 RGB
	/// 4 位数及 8 位数，代表 ARGB
	///
	///      Color(hexString: "#1A191E")
	///      Color(hexString: "0x1A191E")
	///      Color(hexString: "1A191E")
	///
	/// - Parameters:
	///   - hexString: 十六进制字符串
	///   - alpha: 透明度
	public convenience init(hexString: String, alpha: Float = 1.0) {
		var str = hexString
		if str.hasPrefix("#") {
			str = str.replacingOccurrences(of: "#", with: "")
		} else if str.hasPrefix("0x") {
			str = str.replacingOccurrences(of: "0x", with: "")
		}

		let scanner = Scanner(string: str)

		var hex: UInt64 = 0
		scanner.scanHexInt64(&hex)

		var red: CGFloat = 0
		var green: CGFloat = 0
		var blue: CGFloat = 0
		var mAlpha: CGFloat = CGFloat(alpha)

		switch str.count {
			case 3: // rgb
				red = CGFloat((hex >> 8) & 0xF) / 15.0
				green = CGFloat((hex >> 4) & 0xF) / 15.0
				blue = CGFloat(hex & 0xF) / 15.0
			case 4: // argb
				mAlpha = CGFloat((hex >> 12) & 0xF) / 15.0
				red = CGFloat((hex >> 8) & 0xF) / 15.0
				green = CGFloat((hex >> 4) & 0xF) / 15.0
				blue = CGFloat(hex & 0xF) / 15.0
			case 6: // rgb
				red = CGFloat(hex >> 16 & 0xFF) / 255.0
				green = CGFloat(hex >> 8 & 0xFF) / 255.0
				blue = CGFloat(hex & 0xFF) / 255.0
			case 8: // argb
				mAlpha = CGFloat((hex >> 24) & 0xFF) / 255.0
				red = CGFloat((hex >> 16) & 0xFF) / 255.0
				green = CGFloat((hex >> 8) & 0xFF) / 255.0
				blue = CGFloat(hex & 0xFF) / 255.0
			default: break
		}
		self.init(red: red, green: green, blue: blue, alpha: mAlpha)
	}

	/// 根据十六进制生成颜色
	///
	///       let hex = 0x1A191E  //RGB
	///       Color(hex: hex)
	///
	/// - Parameters:
	///   - hex: 十六进制整数，RGB
	///   - alpha: 透明度
	public convenience init(hex: Int, alpha: Float = 1.0) {
		let hexString = String(format: "%06X", hex)
		self.init(hexString: hexString, alpha: alpha)
	}
}

extension String {
    public func color() -> UIColor {
        return UIColor(hexString: self)
    }
}

//--------------------------------------------------------------------------------
// MARK: - Components
//--------------------------------------------------------------------------------

extension UIColor {
    public func alpha(_ value: Float) -> UIColor {
        let (red, green, blue, _) = components()
        return UIColor(red: red, green: green, blue: blue, alpha: CGFloat(value))
    }
    
    public func red(_ value: Float) -> UIColor {
        let (_, green, blue, alpha) = components()
        return UIColor(red: CGFloat(value) / 255.0, green: green, blue: blue, alpha: alpha)
    }
    
    public func green(_ value: Float) -> UIColor {
        let (red, _, blue, alpha) = components()
        return UIColor(red: red, green: CGFloat(value) / 255.0, blue: blue, alpha: alpha)
    }
    
    public func blue(_ value: Float) -> UIColor {
        let (red, green, _, alpha) = components()
        return UIColor(red: red, green: green, blue: CGFloat(value) / 255.0, alpha: alpha)
    }
    
    /// 获取 RGBA 值
    /// - Returns: 包含 RGBA 的元组
    public func components() -> (CGFloat, CGFloat, CGFloat, CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (red, green, blue, alpha)
    }
}

extension UIColor {
    public class var random: UIColor {
        let red = CGFloat.random(in: 0...1)
        let green = CGFloat.random(in: 0...1)
        let blue = CGFloat.random(in: 0...1)
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
    
    public class func random(alpha: CGFloat = 1.0) -> UIColor {
        let r = CGFloat.random(in: 0...1)
        let g = CGFloat.random(in: 0...1)
        let b = CGFloat.random(in: 0...1)
        return UIColor(red: r, green: g, blue: b, alpha: alpha)
    }
}

//--------------------------------------------------------------------------------
// MARK: - Image
//--------------------------------------------------------------------------------

extension UIColor {
    public func toImage(size: CGSize = CGSize(width: 1, height: 1), alpha: CGFloat = 1) -> UIImage? {
        autoreleasepool { () -> UIImage? in
            let rect = CGRect(origin: .zero, size: size)
            UIGraphicsBeginImageContext(size)
            let context = UIGraphicsGetCurrentContext()
            context?.setAlpha(alpha)
            context?.setFillColor(self.cgColor)
            context?.fill(rect)
            let image: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        }
    }
}

#endif
