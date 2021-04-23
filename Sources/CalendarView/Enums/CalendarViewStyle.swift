//
//  CalendarViewStyle.swift
//  CalendarView
//
//  Created by Marek Loose on 11/04/2021.
//

import UIKit

public enum CalendarViewStyle {
    /// Custom tuple to define your own colors instead of using the built-in schemes
    public typealias CustomColorScheme = (dayBackgrond: UIColor,
        weekBackgrond: UIColor,
        week: UIColor,
        weekday: UIColor,
        holiday: (saturday: UIColor, sunday: UIColor),
        otherMonth: UIColor,
        separator: UIColor,
        disable: UIColor
    )
    
    // Basic color
    case standard
    // Custom
    case custom(customColor: CustomColorScheme)
    
    var colors: CalendarView.Colors {
        switch self {
        case .standard: return .init(dayBackgrond: .white, weekBackgrond: .white, holiday: (UIColor.CalendarViewColor.blue, UIColor.CalendarViewColor.red))
            
        // Custom color style
        case .custom(let customColor): return .init(dayBackgrond: customColor.dayBackgrond, weekBackgrond: customColor.weekBackgrond, week: customColor.week, weekday: customColor.weekday, holiday: customColor.holiday, otherMonth: customColor.otherMonth, separator: customColor.separator, disable: customColor.disable)
        }
    }
}
