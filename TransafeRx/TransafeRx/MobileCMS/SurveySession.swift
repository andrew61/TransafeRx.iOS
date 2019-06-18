//
//  SurveySession.swift
//  MobileCMS
//
//  Created by Jonathan Tindall on 5/3/17.
//  Copyright © 2017 Tachl. All rights reserved.
//

import Foundation
import ObjectMapper

public class SurveySession: NSObject, Mappable {
    var SessionId: Int = 0
    var SurveyId: Int = 0
    var StartDateUTC: Date?
    var StartDateDTO: Date?
    var StartDateCTZ: Date?
    var EndDateUTC: Date?
    var EndDateDTO: Date?
    var EndDateCTZ: String?
    
    override init() {
        
    }
    
    required public init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        SessionId <- map["SessionId"]
        SurveyId <- map["SurveyId"]
        StartDateUTC <- (map["StartDateUTC"], UTCDateTransform())
        StartDateDTO <- (map["StartDateDTO"], DTODateTransform())
        StartDateCTZ <- map["StartDateCTZ"]
        EndDateUTC <- (map["EndDateUTC"], UTCDateTransform())
        EndDateDTO <- (map["EndDateDTO"], DTODateTransform())
        EndDateCTZ <- map["EndDateCTZ"]
    }
}
