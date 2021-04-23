//
//  DictionaryExtensions.swift
//  CalendarView
//
//  Created by Marek Loose on 11/04/2021.
//

import Foundation

extension Dictionary where Value: Equatable {
    func keys(of element: Value) -> [Key] {
        return filter { $0.1 == element }.map { $0.0 }
    }
}
