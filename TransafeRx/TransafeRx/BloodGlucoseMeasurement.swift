//
//  BloodGlucoseMeasurement.swift
//  TransafeRx
//
//  Created by Tachl on 7/25/17.
//  Copyright © 2017 Tachl. All rights reserved.
//

import Foundation
import ObjectMapper
import GRDB

@objc public class BloodGlucoseMeasurement: NSObject, Mappable{
    var BloodGlucoseId : Int?
    var GlucoseLevel : Int?
    var ReadingDate : Date?
    var Model : String?
    
    //Chart
    var Glucose: Int?
    var ReadingDateUTC: Date?
    
    override init(){
        
    }
    
    init(bloodGlucoseId: Int?, glucoseLevel: Int?, readingDate: Date?){
        BloodGlucoseId = bloodGlucoseId
        GlucoseLevel = glucoseLevel
        ReadingDate = readingDate
    }
    
    init(glucoseLevel: Int, readingDate: Date?, model: String?){
        GlucoseLevel = glucoseLevel
        ReadingDate = readingDate
        Model = model
    }
    
    init(glucoseLevel: Int, readingDate: Date?){
        GlucoseLevel = glucoseLevel
        ReadingDate = readingDate
    }
    
    init(glucoseLevel: Int){
        GlucoseLevel = glucoseLevel
        ReadingDate = Date()
    }
    
    init(bg: BloodGlucoseDB){
        BloodGlucoseId = bg.BloodGlucoseId
        GlucoseLevel = bg.GlucoseLevel
        ReadingDate = bg.ReadingDate.dateFromDateTimeUTC
        Model = bg.Model
    }
    
    required public init?(map: Map){
        
    }
    
    func getMeasurement() -> String?{
        var measurement: String?
        
        if GlucoseLevel != nil && ReadingDate != nil{
            measurement = String(format: "%d  %@", GlucoseLevel!, ReadingDate!.dateTimeLocal)
        }
        
        return measurement
    }
    
    public func mapping(map: Map) {
        BloodGlucoseId <- map["BloodGlucoseId"]
        GlucoseLevel <- map["GlucoseLevel"]
        ReadingDate <- (map["ReadingDate"], UTCDateTransform())
        Model <- map["Model"]

        Glucose <- map["Glucose"]
        ReadingDateUTC <- (map["ReadingDateUTC"], DateTimeTransform())
    }
}
struct BloodGlucoseDB: FetchableRecord {
    var BloodGlucoseId: Int
    var GlucoseLevel: Int
    var ReadingDate: String
    var Model: String
    
    init(row: Row) {
        BloodGlucoseId = row["BloodGlucoseId"]
        GlucoseLevel = row["GlucoseLevel"]
        ReadingDate = row["ReadingDate"]
        Model = row["Model"]
    }
}
