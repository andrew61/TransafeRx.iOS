//
//  DateFormatters.swift
//  WeightManagement
//
//  Created by Tachl on 3/21/17.
//  Copyright © 2017 Tachl. All rights reserved.
//

import Foundation

extension NSDate{
    static func dateWith(month: Int, day: Int, hour: Int, minute: Int) -> Date{
        let calendar : Calendar = Calendar.current
        let unitFlags = Set<Calendar.Component>([.day, .month, .hour, .minute, .second, .year])
        var nowComps : DateComponents = calendar.dateComponents(unitFlags, from: Date())
        var comps : DateComponents = calendar.dateComponents(unitFlags, from: Date())
        comps.month = month
        comps.day = day
        comps.hour = hour
        comps.minute = minute
        comps.second = 0
        comps.year = nowComps.year
        
        return calendar.date(from: comps)!
    }
    
    static func dateWith(year: Int, month: Int, day: Int, hour: Int, minute: Int) -> Date{
        let calendar : Calendar = Calendar.current
        let unitFlags = Set<Calendar.Component>([.day, .month, .hour, .minute, .second, .year])
        var nowComps : DateComponents = calendar.dateComponents(unitFlags, from: Date())
        var comps : DateComponents = calendar.dateComponents(unitFlags, from: Date())
        comps.month = month
        comps.day = day
        comps.hour = hour
        comps.minute = minute
        comps.second = 0
        comps.year = year + 2000
        
        return calendar.date(from: comps)!
    }
}

extension Date{
    static let dateTimeAppleFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM d, yyyy hh:mm a"
        return formatter
    }()
    static let dateTimeGraphFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = "E, MMM d, yyyy"
        return formatter
    }()
    static let dateTimeZoneFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ssZZZZZ"
        return formatter
    }()
    static let dateTimeUTCFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    static let dateTimeUTCReceiveFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formatter
    }()
    static let dateTimeZoneReceiveFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formatter
    }()
    static let dateTimeLocalFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    static let dateTimeLocalReceiveFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formatter
    }()
    static let dateTimeAxisFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "M/dd"
        return formatter
    }()
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    static let dateReceiveFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'"
        return formatter
    }()
    
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "hh:mm a"
        return formatter
    }()
    
    static let timeTransformFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
    
    static let dateInputFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEEE, d MMM"
        return formatter
    }()
    
    static let dateWeekFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = ", d MMM"
        return formatter
    }()
    
    static let dateMonthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = "MMM"
        return formatter
    }()
    
    static let dateWeekDayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = "E"
        return formatter
    }()
    
    var dateTimeApple: String {
        return Date.dateTimeAppleFormatter.string(from: self)
    }
    var dateTimeGraph: String {
        return Date.dateTimeGraphFormatter.string(from: self)
    }
    var dateTimeUTC: String {
        return Date.dateTimeUTCFormatter.string(from: self)
    }
    var dateTimeZone: String {
        return Date.dateTimeZoneFormatter.string(from: self)
    }
    var dateTimeLocal: String {
        return Date.dateTimeLocalFormatter.string(from: self)
    }
    var dateTimeReceive: String {
        return Date.dateTimeZoneReceiveFormatter.string(from: self)
    }
    var dateTimeUTCReceive: String {
        return Date.dateTimeUTCReceiveFormatter.string(from: self)
    }
    var dateTimeAxis: String {
        return Date.dateTimeAxisFormatter.string(from: self)
    }
    var date: String {
        return Date.dateFormatter.string(from: self)
    }
    var time: String {
        return Date.timeFormatter.string(from: self)
    }
    var month: String {
        return Date.dateMonthFormatter.string(from: self)
    }
    var weekDay: String {
        return Date.dateWeekDayFormatter.string(from: self)
    }
    var dateInput: String {
        if Calendar.current.isDateInToday(self){
            return "Today\(Date.dateWeekFormatter.string(from: self))"
        }
        if Calendar.current.isDateInTomorrow(self){
            return "Tomorrow\(Date.dateWeekFormatter.string(from: self))"
        }
        if Calendar.current.isDateInYesterday(self){
            return "Yesterday\(Date.dateWeekFormatter.string(from: self))"
        }
        return Date.dateInputFormatter.string(from: self)
    }
    
    func isGreaterThanDate(dateToCompare: Date) -> Bool{
        var isGreater = false
        
        if self.compare(dateToCompare) == ComparisonResult.orderedDescending{
            isGreater = true
        }
        
        return isGreater
    }
    
    func isLessThanDate(dateToCompare: Date) -> Bool{
        var isLess = false
        
        if self.compare(dateToCompare) == ComparisonResult.orderedAscending{
            isLess = true
        }
        
        return isLess
    }
    
    func isEqualTo(dateToCompare: Date) -> Bool{
        var isEqual = false
        
        if self.compare(dateToCompare) == ComparisonResult.orderedSame{
            isEqual = true
        }
        
        return isEqual
    }
    
    func isBetween(date date1: Date, andDate date2: Date) -> Bool{
        return (date1...date2).contains(self)
        //return date1.compare(self) == self.compare(date2)
    }
    
    func addHours(hoursToAdd: Double) -> Date{
        let dateWithHoursAdded: Date = Date(timeInterval: 3600 * hoursToAdd, since: self)
        return dateWithHoursAdded
    }
    
    func subtractHours(hoursToSubtract: Double) -> Date{
        let dateWithHourshoursSubtracted = Date(timeInterval: -3600 * hoursToSubtract, since: self)
        
        return dateWithHourshoursSubtracted
    }
    
    func addDays(daysToAdd: Double) -> Date{
        let dateWithDaysAdded: Date = Date(timeInterval: 3600 * (daysToAdd * 24), since: self)
        return dateWithDaysAdded
    }
    
    func subtractDays(daysToSubtract: Double) -> Date{
        let dateWithDaysSubtracted: Date = Date(timeInterval: -3600 * (daysToSubtract * 24), since: self)
        return dateWithDaysSubtracted
    }
    
    func subtractYears(yearsToSubtract: Double) -> Date{
        let dateWithYearsSubtracted = Date(timeInterval: -31536000 * yearsToSubtract, since: self)
        
        return dateWithYearsSubtracted
    }
    
    var age: Int{
        return Calendar.current.dateComponents([.year], from: Date()).year!
    }
    
    func calculateAge() -> Int {
        let calendar : Calendar = Calendar.current
        let unitFlags = Set<Calendar.Component>([.day, .month, .year,])//CFCalendarUnit = CFCalendarUnit.year | CFCalendarUnit.month | CFCalendarUnit.day
        var dateComponentNow : DateComponents = calendar.dateComponents(unitFlags, from: Date())
        var dateComponentBirth : DateComponents = calendar.dateComponents(unitFlags, from: self)
        
        if ( (dateComponentNow.month! < dateComponentBirth.month!) ||
            ((dateComponentNow.month! == dateComponentBirth.month!) && (dateComponentNow.day! < dateComponentBirth.day!))
            )
        {
            return dateComponentNow.year! - dateComponentBirth.year! - 1
        }
        else {
            return dateComponentNow.year! - dateComponentBirth.year!
        }
    }
}

extension String {
    var dateFromDateTimeApple: Date? {
        return Date.dateTimeAppleFormatter.date(from: self)
    }
    var dateFromDateTimeGraph: Date? {
        return Date.dateTimeGraphFormatter.date(from: self)
    }
    var dateFromDateTimeUTC: Date? {
        return Date.dateTimeUTCFormatter.date(from: self)
    }
    var dateFromDateTimeZone: Date? {
        return Date.dateTimeZoneFormatter.date(from: self)
    }
    var dateFromDateTimeLocalReceiver: Date? {
        return Date.dateTimeLocalReceiveFormatter.date(from: self)
    }
    var dateFromDateTimeZoneReceiver: Date? {
        return Date.dateTimeZoneReceiveFormatter.date(from: self)
    }
    var dateFromDateTimeUTCReceiver: Date? {
        return Date.dateTimeUTCReceiveFormatter.date(from: self)
    }
    var dateFromTimeTransform: Date? {
        return Date.timeTransformFormatter.date(from: self)
    }
    var dateFromDate: Date? {
        return Date.dateTimeZoneReceiveFormatter.date(from: self)
    }
    var dateFromWeekDay: Date? {
        return Date.dateWeekDayFormatter.date(from: self)
    }
    var dateFromMonth: Date? {
        return Date.dateMonthFormatter.date(from: self)
    }
    var dateFromTime: Date?{
        let completeDate = "2001-01-01 \(self)"
        return Date.dateTimeLocalFormatter.date(from: completeDate)
    }
}

