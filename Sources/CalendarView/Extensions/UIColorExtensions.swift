//
//  UIColorExtensions.swift
//  CalendarView
//
//  Created by Marek Loose on 11/04/2021.
//

import UIKit

extension UIColor {
    
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let red   = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hex & 0xFF00) >> 8) / 255.0
        let blue  = CGFloat((hex & 0xFF)) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    public struct CalendarViewColor {
        
        // Using [iOS 7 colors] as reference.
        // http://ios7colors.com/
        
        public static let lightBlack: UIColor  = .init(hex: 0x4A4A4A)
        public static let black: UIColor       = .init(hex: 0x2B2B2B)
        public static let darkBlack: UIColor   = .init(hex: 0x1F1F21)
        public static let lightGray: UIColor   = .init(hex: 0x8E8E93)
        public static let darkGray: UIColor    = .init(hex: 0x555558)
        public static let lightYellow: UIColor = .init(hex: 0xFFDB4C)
        public static let lightPurple: UIColor = .init(hex: 0xC86EDF)
        public static let lightGreen: UIColor  = .init(hex: 0xA4E786)
        public static let lightPink: UIColor   = .init(hex: 0xFFD3E0)
        
        // Using [iOS Human Interface Guidelines] as reference.
        // https://developer.apple.com/ios/human-interface-guidelines/visual-design/color/
        
        public static let red: UIColor      = .init(hex: 0xff3b30)
        public static let orange: UIColor   = .init(hex: 0xff9500)
        public static let green: UIColor    = .init(hex: 0x4cd964)
        public static let blue: UIColor     = .init(hex: 0x007aff)
        public static let purple: UIColor   = .init(hex: 0x5856d6)
        public static let yellow: UIColor   = .init(hex: 0xffcc00)
        public static let tealBlue: UIColor = .init(hex: 0x5ac8fa)
        public static let pink: UIColor     = .init(hex: 0xff2d55)
    }
}
