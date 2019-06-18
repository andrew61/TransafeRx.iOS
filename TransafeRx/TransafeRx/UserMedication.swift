//
//  UserMedication.swift
//  TransafeRx
//
//  Created by Tachl on 7/27/17.
//  Copyright © 2017 Tachl. All rights reserved.
//

import Foundation
import ObjectMapper

class UserMedication: NSObject, Mappable{
    var UserMedicationId: Int?
    var DrugName: String?
    var Instructions: String?
    var StartDate: Date?
    var Route: String?
//    var DaysSupply: Int?
    var CreatedDateUTC: Date?
    var CreatedDateDTO: Date?
    var CreatedDateCTZ: String?
    var UpdatedDateUTC: Date?
    var UpdatedDateDTO: Date?
    var UpdatedDateCTZ: String?
    var InActive: Bool?
//    var EndDate: Date?
    
    override init(){
        
    }
    
    required public init?(map: Map){
        
    }
    
    public func mapping(map: Map) {
        UserMedicationId <- map["UserMedicationId"]
        DrugName <- map["DrugName"]
        Instructions <- map["Instructions"]
        StartDate <- (map["StartDate"], UTCDateTransform())
        Route <- map["Route"]
//        DaysSupply <- map["DaysSupply"]
//        CreatedDateUTC <- (map["CreatedDateUTC"], UTCDateTransform())
//        CreatedDateDTO <- (map["CreatedDateDTO"], DTODateTransform())
//        CreatedDateCTZ <- map["CreatedDateCTZ"]
//        UpdatedDateUTC <- (map["UpdatedDateUTC"], UTCDateTransform())
//        UpdatedDateDTO <- (map["UpdatedDateDTO"], DTODateTransform())
//        UpdatedDateCTZ <- map["UpdatedDateCTZ"]
        InActive <- map["InActive"]
//        EndDate <- (map["EndDate"], UTCDateTransform())
    }
}
