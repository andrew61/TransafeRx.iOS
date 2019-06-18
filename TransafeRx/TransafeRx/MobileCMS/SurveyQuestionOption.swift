//
//  SurveyQuestionOptions.swift
//  eHEARTT
//
//  Created by Tachl on 11/7/16.
//  Copyright © 2016 Tachl. All rights reserved.
//

import Foundation
import ObjectMapper

public class SurveyQuestionOption: NSObject, Mappable {
    var OptionId: Int = 0
    var QuestionId: Int = 0
    var CategoryId: Int = 0
    var CategoryName: String?
    var OptionText: String?
    var OptionImage: String?
    var OptionOrder: Int = 0
    var ShapeType: NSNumber?
    var Coordinates: String?
    var Feedback: String?
    var FeedbackColor: String?
    var FeedbackBackgroundColor: String?
    var FeedbackBackgroundAlpha: Float?
    var FeedbackFontId: Int = 0
    var FeedbackFontSize: Int = 0
    
    override init() {
        
    }
    
    required public init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        OptionId <- map["OptionId"]
        QuestionId <- map["QuestionId"]
        CategoryId <- map["CategoryId"]
        CategoryName <- map["CategoryName"]
        OptionText <- map["OptionText"]
        OptionImage <- map["OptionImage"]
        OptionOrder <- map["OptionOrder"]
        ShapeType <- map["ShapeType"]
        Coordinates <- map["Coordinates"]
        Feedback <- map["Feedback"]
        FeedbackColor <- map["FeedbackColor"]
        FeedbackBackgroundColor <- map["FeedbackBackgroundColor"]
        FeedbackBackgroundAlpha <- map["FeedbackBackgroundAlpha"]
        FeedbackFontId <- map["FeedbackFontId"]
        FeedbackFontSize <- map["FeedbackFontSize"]
    }
}
