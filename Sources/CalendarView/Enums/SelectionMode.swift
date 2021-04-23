//
//  SelectionMode.swift
//  CalendarView
//
//  Created by Marek Loose on 11/04/2021.
//

import Foundation

public enum SelectionMode {
    case single(style: Style), multiple(style: Style), sequence(style: SequenceStyle), none
    
    public enum SequenceStyle { case background, circle, line, semicircleEdge }
    public enum Style { case background, circle, line }
}
