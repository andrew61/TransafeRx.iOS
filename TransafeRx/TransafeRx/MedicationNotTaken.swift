//
//  MedicationNotTaken.swift
//  TransafeRx
//
//  Created by Tachl on 9/13/17.
//  Copyright © 2017 Tachl. All rights reserved.
//

import Foundation
import ObjectMapper

class MedicationNotTaken: NSObject, Mappable{
    var ScheduleId: Int?
    var UserMedicationId: Int?
    var ScheduleTime: Date?
    var Dosage: Int?
    var DrugName: String?
    var Instructions: String?
    
    var isChecked = false
    
    override init(){
        
    }
    
    required public init?(map: Map){
        
    }
    
    public func mapping(map: Map) {
        ScheduleId <- map["ScheduleId"]
        UserMedicationId <- map["UserMedicationId"]
        ScheduleTime <- (map["ScheduleTime"], MedicationNotTakenDateTransformer())
        Dosage <- map["Dosage"]
        DrugName <- map["DrugName"]
        Instructions <- map["Instructions"]
    }
}
