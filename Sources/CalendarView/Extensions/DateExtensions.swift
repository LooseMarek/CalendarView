//
//  DateExtensions.swift
//  CalendarView
//
//  Created by Marek Loose on 11/04/2021.
//

import Foundation

extension Date {
    func formated(withFormat format: String = "yyyy/MM/dd") -> Date? {
        let formatter: DateFormatter = .init()
        formatter.dateFormat = format
        let dateString = formatter.string(from: self)
        return formatter.date(from: dateString)
    }
    
    func daysSince(_ anotherDate: Date) -> Int? {
        if let fromDate = dateFromComponents(self), let toDate = dateFromComponents(anotherDate) {
            let components = Calendar.current.dateComponents([.day], from: fromDate, to: toDate)
            return components.day
        }
        return nil
    }
    
    private func dateFromComponents(_ date: Date) -> Date? {
        let calender   = Calendar.current
        let components = calender.dateComponents([.year, .month, .day], from: date)
        return calender.date(from: components)
    }
}
