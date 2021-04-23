//
//  ContentPosition.swift
//  CalendarView
//
//  Created by Marek Loose on 11/04/2021.
//

import UIKit

public enum ContentPosition {
    case topLeft, topCenter, topRight
    case left, center, right
    case bottomLeft, bottomCenter, bottomRight
    case custom(x: CGFloat, y: CGFloat)
}
