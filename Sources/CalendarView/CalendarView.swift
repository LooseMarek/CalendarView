//
//  CalendarView.swift
//  CalendarView
//
//  Created by Marek Loose on 10/04/2021.
//  Copyright © 2021 Marek Loose. All rights reserved.
//

import Foundation
import UIKit

// MARK: - CalendarViewDelegate

@objc public protocol CalendarViewDelegate: class {
    /**
     Tells the delegate that the date at the specified index path was selected.
     
     - Parameter calendarView:    The current CalendarView instance.
     - Parameter date:      The date of the cell that was selected.
     - Parameter indexPath: The index path of the cell that was selected.
     */
    @objc optional func calendarView(_ calendarView: CalendarView, didSelect date: Date?, forItemAt indexPath: IndexPath)
    
    /**
     Tells the delegate that the displayed month is changed.
     
     - Parameter calendarView:     The current CalendarView instance.
     - Parameter dateString: The current date string.
     */
    @objc optional func calendarView(_ calendarView: CalendarView, currentDateString dateString: String)
    
    /**
     The calendar calls this method before select days
     
     - Parameter calendarView:  The current CalendarView instance.
     - Parameter date:    The first date in selected date.
     - Parameter toDate:  The end date in selected date.
     - Parameter length:  The length of selected date.
     
     - Returns: true if the item should be selected or false if it should not.
     */
    @objc optional func calendarView(_ calendarView: CalendarView, shouldSelectDates date: Date?, to toDate: Date?, withPeriodLength length: Int) -> Bool
    
    /**
     Returns selection color for individual cells.
     
     - Parameter calendar:    The current CalendarView instance.
     - Parameter indexPath: The index path of the cell that was selected.
     - Parameter date:      The date representing current item.
     
     - Returns: A color for selection background for item at the `indexPath` or nil for default selection color.
     */
    @objc optional func calendarView(_ calendarView: CalendarView, selectionColorForItemAt indexPath: IndexPath, date: Date) -> UIColor?
    
    /**
     Returns selection text color for individual cells.
     
     - Parameter calendar:    The current CalendarView instance.
     - Parameter indexPath: The index path of the cell that was selected.
     - Parameter date:      The date representing curredisablePastDateSelectionnt item.
     
     - Returns: A text color for the label for item at the `indexPath` or nil for default selection color.
     */
    @objc optional func calendarView(_ calendarView: CalendarView, selectionTextColorForItemAt indexPath: IndexPath, date: Date) -> UIColor?
}

// MARK: - CalendarView

@IBDesignable
final public class CalendarView: UICollectionView {
    
    struct Colors {
        let dayBackgrond, weekBackgrond: UIColor
        let week, weekday: UIColor
        let holiday: (saturday: UIColor, sunday: UIColor)
        let otherMonth: UIColor
        let separator: UIColor
        let disable: UIColor
        
        init(dayBackgrond: UIColor, weekBackgrond: UIColor, week: UIColor = UIColor.CalendarViewColor.black, weekday: UIColor = UIColor.CalendarViewColor.black, holiday: (saturday: UIColor, sunday: UIColor) = (UIColor.CalendarViewColor.blue, UIColor.CalendarViewColor.red), otherMonth: UIColor = UIColor.CalendarViewColor.lightGray, separator: UIColor = UIColor.CalendarViewColor.lightGray, disable: UIColor = UIColor.CalendarViewColor.darkGray) {
            self.dayBackgrond  = dayBackgrond
            self.weekBackgrond = weekBackgrond
            
            self.week = week
            self.weekday = weekday
            self.holiday.saturday = holiday.saturday
            self.holiday.sunday   = holiday.sunday
            self.otherMonth = otherMonth
            self.separator  = separator
            self.disable = disable
        }
    }
    
    public var style: CalendarViewStyle = .standard {
        didSet {
            dayBackgrondColor  = style.colors.dayBackgrond
            weekBackgrondColor = style.colors.weekBackgrond
            weekColor = style.colors.week
            weekdayColor = style.colors.weekday
            holidayColor = style.colors.holiday
            otherMonthColor = style.colors.otherMonth
            backgroundColor = style.colors.separator
            sectionSeparator.backgroundColor = style.colors.separator
            disablePastDayColor = style.colors.disable
        }
    }
    
    public var selectionMode: SelectionMode = .single(style: .circle) {
        didSet {
            model.selectionMode = {
                switch selectionMode {
                case .single(_):   return .single
                case .multiple(_): return .multiple
                case .sequence(_): return .sequence
                case .none:        return .none
                }
            }()
        }
    }
    
    public struct LineView {
        public enum Position { case top, center, bottom }
        public var height: CGFloat    = 1
        public var widthRate: CGFloat = 1
        public var position: Position = .center
    }
    public var lineView: LineView = .init()
    
    @IBInspectable public var isHiddenOtherMonth: Bool = false
    
    @IBInspectable public var disablePastDateSelection: Bool = false
        
    // Layout properties
    @IBInspectable public var sectionSpace: CGFloat = 1.5 {
        didSet {
            sectionSeparator.frame.size.height = sectionSpace
        }
    }
    @IBInspectable public var cellSpace: CGFloat = 0.5 {
        didSet {
            if let layout = collectionViewLayout as? CalendarViewLayout, layout.cellSpace != cellSpace {
                setCollectionViewLayout(self.layout, animated: false)
            }
        }
    }
    @IBInspectable public var weekCellHeight: CGFloat = 25 {
        didSet {
            sectionSeparator.frame.origin.y = inset.top + weekCellHeight
            if let layout = collectionViewLayout as? CalendarViewLayout, layout.weekCellHeight != weekCellHeight {
                setCollectionViewLayout(self.layout, animated: false)
            }
        }
    }
    @IBInspectable public var circularViewDiameter: CGFloat = 0.75 {
        didSet {
            reloadData()
        }
    }
    
    public var inset: UIEdgeInsets = .zero {
        didSet {
            if let layout = collectionViewLayout as? CalendarViewLayout, layout.inset != inset {
                setCollectionViewLayout(self.layout, animated: false)
            }
        }
    }
    public var dayPosition: ContentPosition  = .center
    public var weekPosition: ContentPosition = .center
    
    // Week cell text
    public var weeks: (String, String, String, String, String, String, String) {
        get {
            return model.weeks
        }
        set {
            model.weeks = newValue
            reloadData()
        }
    }
    @IBInspectable public var currentDateFormat: String = "MMMM yyyy"
    
    // Color properties of the appearance
    @IBInspectable public var sectionSeparatorColor: UIColor = UIColor.CalendarViewColor.lightGray {
        didSet {
            sectionSeparator.backgroundColor = sectionSeparatorColor
        }
    }
    @IBInspectable public var separatorColor: UIColor = UIColor.CalendarViewColor.lightGray {
        didSet {
            backgroundColor = separatorColor
        }
    }
    @IBInspectable public var weekColor: UIColor    = UIColor.CalendarViewColor.black
    @IBInspectable public var weekdayColor: UIColor = UIColor.CalendarViewColor.black
    @IBInspectable public var otherMonthColor: UIColor = UIColor.CalendarViewColor.lightGray
    @IBInspectable public var disablePastDayColor: UIColor = UIColor.CalendarViewColor.darkGray
    @IBInspectable public var dayBackgrondColor: UIColor  = .white
    @IBInspectable public var weekBackgrondColor: UIColor = .white
    public var holidayColor: (saturday: UIColor, sunday: UIColor) = (UIColor.CalendarViewColor.blue, UIColor.CalendarViewColor.red)
    
    @IBInspectable public var selectedStyleColor: UIColor = UIColor.CalendarViewColor.red
    
    public enum SelectedTextState { case change(UIColor), keeping }
    public var selectedDayTextState: SelectedTextState = .change(.black)
    
    // CalendarViewDelegate
    public weak var calendarDelegate: CalendarViewDelegate?
    
    // Fileprivate properties
    fileprivate var highlightedDayColor = UIColor.CalendarViewColor.black
    fileprivate var highlightedDayBackgrondColor: UIColor = .white
    
    fileprivate var dateNow: Date = Date()
    
    fileprivate lazy var model: DateModel = .init(dateNow: dateNow)
    fileprivate let sectionSeparator: UIView = .init()
    
    fileprivate var layout: UICollectionViewLayout {
        return CalendarViewLayout(inset: inset, cellSpace: cellSpace, sectionSpace: sectionSpace, weekCellHeight: weekCellHeight)
    }
    
    fileprivate var dayLabelFont: UIFont?
    fileprivate var weekLabelFont: UIFont?
        
    // MARK: - Initialization
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
        collectionViewLayout = layout
    }
    
    // Internal initializer for @IBDesignable
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
    }
    
    public init(frame: CGRect, sectionSpace: CGFloat = 1.5, cellSpace: CGFloat = 0.5, inset: UIEdgeInsets = .zero, weekCellHeight: CGFloat = 25, dateNow: Date = Date()) {
        super.init(frame: frame, collectionViewLayout: CalendarViewLayout(inset: inset, cellSpace: cellSpace, sectionSpace: sectionSpace, weekCellHeight: weekCellHeight))
        self.sectionSpace = sectionSpace
        self.cellSpace = cellSpace
        self.inset = inset
        self.weekCellHeight = weekCellHeight
        self.dateNow = dateNow
        configure()
    }
    
    // MARK: - Public Methods
    
    public func display(in month: MonthType) {
        model.display(in: month)
        reloadData()
        calendarDelegate?.calendarView?(self, currentDateString: currentDateString(withFormat: currentDateFormat))
    }
    
    @discardableResult
    public func setDayFont(size: CGFloat) -> Self {
        dayLabelFont = UIFont.systemFont(ofSize: size)
        return self
    }
    
    @discardableResult
    public func setWeekFont(size: CGFloat) -> Self {
        weekLabelFont = UIFont.systemFont(ofSize: size)
        return self
    }
    
    public func currentDateString(withFormat format: String = "M/yyyy") -> String {
        return model.dateString(in: .current, withFormat: format)
    }
    
    @discardableResult
    public func select(date: Date, to toDate: Date? = nil) -> Self {
        model.select(from: date, to: toDate)
        return self
    }
    
    @discardableResult
    public func select(dates: [Date]) -> Self {
        dates.forEach { [weak self] date in self?.select(date: date) }
        return self
    }
    
    @discardableResult
    public func unselect(date: Date, to toDate: Date? = nil) -> Self {
        model.unselect(from: date, to: toDate)
        return self
    }
    
    @discardableResult
    public func unselect(dates: [Date]) -> Self {
        dates.forEach { [weak self] date in self?.unselect(date: date) }
        return self
    }
    
    @discardableResult
    public func unselectAll() -> Self {
        model.unselectAll()
        return self
    }
    
    @discardableResult
    public func setDayColor(_ dayColor: UIColor, of date: Date, to toDate: Date? = nil) -> Self {
        model.setHighlightedDates(from: date, to: toDate)
        highlightedDayColor = dayColor
        return self
    }
    
    @discardableResult
    public func setDayBackgrondColor(_ backgroundColor: UIColor, of date: Date, to toDate: Date? = nil) -> Self {
        model.setHighlightedDates(from: date, to: toDate)
        highlightedDayBackgrondColor = backgroundColor
        return self
    }
    
    // MARK: - Override Method -
    
    override public func reloadData() {
        super.reloadData()
        setCollectionViewLayout(layout, animated: false)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        sectionSeparator.frame = CGRect(x: inset.left, y: inset.top + weekCellHeight, width: frame.width - (inset.top + inset.left), height: sectionSpace)
    }
}

// MARK: - Private Methods

private extension CalendarView {
    
    func configure() {
        delegate   = self
        dataSource = self
        isScrollEnabled = false
        
        backgroundColor = separatorColor
        
        register(CalendarViewCell.self, forCellWithReuseIdentifier: CalendarViewCell.identifier)
        
        sectionSeparator.backgroundColor = sectionSeparatorColor
        addSubview(sectionSeparator)
    }
    
    func configure(_ cell: CalendarViewCell, at indexPath: IndexPath) {
        
        // Appearance properties
        let style: CalendarViewCell.CellStyle
        let textColor: UIColor
        let isSelected: Bool
        let backgroundColor: UIColor
        let font: UIFont?
        let content: String
        let postion: ContentPosition
        
        let date = model.date(at: indexPath)
        
        if indexPath.section == 0 {
            
            // Configure appearance properties for week cell
            style = .standard
            textColor  = weekColor
            isSelected = false
            backgroundColor = weekBackgrondColor
            font = weekLabelFont
            content = model.week(at: indexPath.row)
            postion = weekPosition
            
        } else {
            
            // Configure appearance properties for day cell
            isSelected = model.isSelect(with: indexPath)
            
            textColor = {
                var baseColor: UIColor {
                    if let beginning = model.indexAtBeginning(in: .current), indexPath.row < beginning {
                        return otherMonthColor
                    } else if let end = model.indexAtEnd(in: .current), indexPath.row > end {
                        return otherMonthColor
                    } else if disablePastDateSelection && date < dateNow {
                        return disablePastDayColor
                    } else if let type = DateModel.WeekType(indexPath), type == .sunday {
                        return holidayColor.sunday
                    } else if let type = DateModel.WeekType(indexPath), type == .saturday {
                        return holidayColor.saturday
                    } else {
                        return weekdayColor
                    }
                }
                
                if isSelected {
                    switch selectedDayTextState {
                    case .change(let color): return color
                    case .keeping:           return baseColor
                    }
                } else if model.isHighlighted(with: indexPath) {
                    return highlightedDayColor
                } else {
                    return baseColor
                }
            }()
            
            style = {
                var sequencePosition: CalendarViewCell.CellStyle.SequencePosition {
                    let date = model.date(at: indexPath)
                    if let start = model.sequenceDates.start, let _ = model.sequenceDates.end , date == start {
                        return .left
                    } else if let _ = model.sequenceDates.start, let end = model.sequenceDates.end , date == end {
                        return .right
                    } else {
                        return .middle
                    }
                }
                
                switch (selectionMode, isSelected) {
                //Not selected or background style of single, multiple, sequence mode
                case (_, false), (.single(style: .background), true), (.multiple(style: .background), true), (.sequence(style: .background), true):
                    return .standard
                    
                //Selected and circle style of single, multiple, sequence mode
                case (.single(style: .circle), true), (.multiple(style: .circle), true), (.sequence(style: .circle), true):
                    return .circle
                    
                //Selected and sequence mode, semicircleEdge style
                case (.sequence(style: .semicircleEdge), true):
                    return .semicircleEdge(position: sequencePosition)
                    
                case (.single(style: .line), true), (.multiple(style: .line), true):
                    // Position is always nil.
                    return .line(position: nil)
                    
                case (.sequence(style: .line), true):
                    return .line(position: sequencePosition)
                    
                default: return .standard
                }
            }()
            
            backgroundColor = model.isHighlighted(with: indexPath) ? highlightedDayBackgrondColor : dayBackgrondColor
            font = dayLabelFont
            content = model.dayString(at: indexPath, isHiddenOtherMonth: isHiddenOtherMonth)
            postion = dayPosition
        }
        
        // Set cell to appearance properties
        cell.content   = content
        cell.textColor = {
            if isSelected {
                return calendarDelegate?.calendarView?(self, selectionTextColorForItemAt: indexPath, date: date) ?? textColor
            } else {
                return textColor
            }
        }()
        cell.contentPosition = postion
        cell.circularViewDiameter = circularViewDiameter
        let selectionColor: UIColor = {
            if isSelected {
                return calendarDelegate?.calendarView?(self, selectionColorForItemAt: indexPath, date: date) ?? selectedStyleColor
            } else {
                return selectedStyleColor
            }
        }()
        
        if case .line = style {
            cell.lineViewAppearance = lineView
        }
        if let font = font {
            cell.setContentFont(size: font.pointSize)
        }
        
        cell.configureAppearanse(of: style, withColor: selectionColor, backgroundColor: backgroundColor, isSelected: isSelected)
    }
}

// MARK: - UICollectionViewDelegate

extension CalendarView: UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.section != 0 else { return }
        
        // Other month
        if isHiddenOtherMonth && model.isOtherMonth(at: indexPath) {
            return
        }
        
        // CalendarViewDelegate properties
        let date: Date?
        let toDate: Date?
        let length: Int
        
        switch selectionMode {
        case .single(_), .multiple(_):
            date   = model.date(at: indexPath)
            toDate = nil
            length = 1
            
            if let selectedDate = date, selectedDate < dateNow {
                if disablePastDateSelection {
                    return
                }
            }
            
        case .sequence(_):
            let willSelectDates = model.willSelectDates(with: indexPath)
            date   = willSelectDates.from
            toDate = willSelectDates.to
            length = model.selectedPeriodLength(with: indexPath)
            
        case .none: return
        }
        
        if calendarDelegate?.calendarView?(self, shouldSelectDates: date, to: toDate, withPeriodLength: length) == false {
            return
        }
        
        model.select(with: indexPath)
        reloadData()
        
        calendarDelegate?.calendarView?(self, didSelect: date, forItemAt: indexPath)
    }
}

// MARK: - UICollectionViewDataSource

extension CalendarView: UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? DateModel.dayCountPerRow : DateModel.maxCellCount
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarViewCell.identifier, for: indexPath) as? CalendarViewCell else {
            return .init()
        }
        configure(cell, at: indexPath)
        return cell
    }
}
