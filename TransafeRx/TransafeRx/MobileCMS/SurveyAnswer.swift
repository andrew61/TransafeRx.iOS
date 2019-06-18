//
//  SurveyAnswer.swift
//  eHEARTT
//
//  Created by Tachl on 11/7/16.
//  Copyright © 2016 Tachl. All rights reserved.
//

import Foundation
import ObjectMapper

class SurveyAnswer: NSObject, Mappable {
    var CategoryId: Int? = nil
    var OptionId: Int? = nil
    var AnswerText: String? = nil
    var AnswerDateUTC: Date?
    var AnswerDateDTO: Date?
    var AnswerDateCTZ: String?
    var Rank: Int? = nil
    
    override init() {
        let date = Date()
        AnswerDateUTC = date
        AnswerDateDTO = date
        AnswerDateCTZ = TimeZone.current.identifier
    }
    
    required public init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        CategoryId <- map["CategoryId"]
        OptionId <- map["OptionId"]
        AnswerText <- map["AnswerText"]
        AnswerDateUTC <- (map["AnswerDateUTC"], UTCDateTransform())
        AnswerDateDTO <- (map["AnswerDateDTO"], DTODateTransform())
        AnswerDateCTZ <- map["AnswerDateCTZ"]
        Rank <- map["Rank"]
    }
}
