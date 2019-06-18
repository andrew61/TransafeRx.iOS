//
//  MedicationActivity.swift
//  TransafeRx
//
//  Created by Tachl on 8/28/17.
//  Copyright © 2017 Tachl. All rights reserved.
//

import Foundation
import ObjectMapper

class MedicationActivity: NSObject, Mappable{
    
    var ActivityTypeId: Int?
    var UserMedicationId: Int?
    var ScheduleId: Int?
    var ScheduleDate: Date?
    var ActivityUTC: Date?
    var ActivityDTO: Date?
    var ActivityCTZ: String?

    override init(){
        ActivityUTC = Date()
        ActivityDTO = Date()
        ActivityCTZ = TimeZone.current.identifier
    }
    
    init(activityTypeId: Int?, userMedicationId: Int?){
        ActivityTypeId = activityTypeId
        UserMedicationId = userMedicationId
        ActivityUTC = Date()
        ActivityDTO = Date()
        ActivityCTZ = TimeZone.current.identifier
    }
    
    init(activityTypeId: Int?, userMedicationId: Int?, scheduleId: Int?, scheduleDate: Date?){
        ActivityTypeId = activityTypeId
        UserMedicationId = userMedicationId
        ScheduleId = scheduleId
        ScheduleDate = scheduleDate
        ActivityUTC = Date()
        ActivityDTO = Date()
        ActivityCTZ = TimeZone.current.identifier
    }
    
    required public init?(map: Map){
        
    }
    
    public func mapping(map: Map) {
        ActivityTypeId <- map["ActivityTypeId"]
        UserMedicationId <- map["UserMedicationId"]
        ScheduleId <- map["ScheduleId"]
        ScheduleDate <- (map["ScheduleDate"], DateTimeTransform())
        ActivityUTC <- (map["ActivityUTC"], UTCDateTransform())
        ActivityDTO <- (map["ActivityDTO"], DTODateTransform())
        ActivityCTZ <- map["ActivityCTZ"]
    }
}
