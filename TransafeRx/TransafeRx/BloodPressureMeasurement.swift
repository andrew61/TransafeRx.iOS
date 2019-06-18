//
//  BloodPressureMeasurement.swift
//  TransafeRx
//
//  Created by Tachl on 7/25/17.
//  Copyright © 2017 Tachl. All rights reserved.
//

import Foundation
import ObjectMapper
import GRDB

@objc public class BloodPressureMeasurement: NSObject, Mappable{
    var BloodPressureId : Int?
    var Systolic : Int?
    var Diastolic : Int?
    var Map : Int?
    var Pulse : Int?
    var ReadingDate : Date?
    var Model : String?
    
    //Chart
    var ReadingDateUTC : Date?

    override init(){
        
    }
    
    init(bloodPressureId: Int?, systolic: Int?, diastolic: Int?, pulse: Int?, readingDate: Date?){
        BloodPressureId = bloodPressureId
        Systolic = systolic
        Diastolic = diastolic
        Pulse = pulse
        ReadingDate = readingDate
    }
    
    init(systolic: Int, diastolic: Int, pulse: Int, model: String?){
        Systolic = systolic
        Diastolic = diastolic
        Pulse = pulse
        ReadingDate = Date()
        Model = model
    }
    
    init(systolic: Int, diastolic: Int, pulse: Int){
        Systolic = systolic
        Diastolic = diastolic
        Pulse = pulse
        ReadingDate = Date()
    }
    
    init(bp: BloodPressureDB){
        BloodPressureId = bp.BloodPressureId
        Systolic = bp.Systolic
        Diastolic = bp.Diastolic
        Pulse = bp.Pulse
        ReadingDate = bp.ReadingDate.dateFromDateTimeUTC
        Model = bp.Model
    }
    
    required public init?(map: Map){
        
    }
    
    func getMeasurement() -> String?{
        var measurement: String?
        
        if Systolic != nil && Diastolic != nil && ReadingDate != nil{
            measurement = String(format: "%d/%d  %@", Systolic!, Diastolic!, ReadingDate!.dateTimeLocal)
        }
        
        return measurement
    }
    
    public func mapping(map: Map) {
        BloodPressureId <- map["BloodPressureId"]
        Systolic <- map["Systolic"]
        Diastolic <- map["Diastolic"]
        Pulse <- map["Pulse"]
        ReadingDate <- (map["ReadingDate"], UTCDateTransform())
        Model <- map["Model"]

        ReadingDateUTC <- (map["ReadingDateUTC"], DateTimeTransform())
    }
}

struct BloodPressureDB: FetchableRecord {
    var BloodPressureId: Int
    var Systolic: Int
    var Diastolic: Int
    var Pulse: Int
    var ReadingDate: String
    var Model: String
    
    init(row: Row) {
        BloodPressureId = row["BloodPressureId"]
        Systolic = row["Systolic"]
        Diastolic = row["Diastolic"]
        Pulse = row["Pulse"]
        ReadingDate = row["ReadingDate"]
        Model = row["Model"]
    }
}
