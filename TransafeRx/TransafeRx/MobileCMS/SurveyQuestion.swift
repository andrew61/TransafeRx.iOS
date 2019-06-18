//
//  SurveyQuestion.swift
//  eHEARTT
//
//  Created by Tachl on 11/7/16.
//  Copyright © 2016 Tachl. All rights reserved.
//

import Foundation
import ObjectMapper

public class SurveyQuestion: NSObject, Mappable {
    var QuestionId: Int = 0
    var SurveyId: Int = 0
    var QuestionTypeId: Int = 0
    var Name: String?
    var QuestionText: String?
    var QuestionImage: String?
    var QuestionOrder: Int = 0
    var OptionImage: String?
    var Body: String?
    var ListColor : String?
    var ListBackgroundColor : String?
    var ListBackgroundAlpha : Float?
    var ListFontId : Int = 0
    var ListFontSize : Int = 0
    var SelectedColor : String?
    var SelectedBackgroundColor : String?
    var SelectedBackgroundAlpha : Float?
    var SelectedFontId : Int = 0
    var SelectedFontSize : Int = 0
    var SelectedIconColor : String?
    var ButtonColor : String?
    var ButtonBackgroundColor : String?
    var ButtonBackgroundAlpha : Float?
    var ButtonFontId : Int = 0
    var ButtonFontSize : Int = 0
    var ProgressBarColor : String?
    var ProgressBarBackgroundColor : String?
    var ProgressBarBackgroundAlpha : Float?
    var TooltipColor : String?
    var TooltipBackgroundColor : String?
    var TooltipBackgroundAlpha : Float?
    var TooltipFontId : Int = 0
    var TooltipFontSize : Int = 0
    var SeparatorColor: String?
    var IsFirstQuestion: Bool = false
    var Required: Bool = false
    
    var Answer: SurveyAnswer?
    var Answers = [SurveyAnswer]()
    var Options = [SurveyQuestionOption]()
    
    override init() {
        
    }
    
    required public init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        QuestionId <- map["QuestionId"]
        SurveyId <- map["SurveyId"]
        QuestionTypeId <- map["QuestionTypeId"]
        Name <- map["Name"]
        QuestionText <- map["QuestionText"]
        QuestionImage <- map["QuestionImage"]
        QuestionOrder <- map["QuestionOrder"]
        OptionImage <- map["OptionImage"]
        Body <- map["Body"]
        ListColor <- map["ListColor"]
        ListBackgroundColor <- map["ListBackgroundColor"]
        ListBackgroundAlpha <- map["ListBackgroundAlpha"]
        ListFontId <- map["ListFontId"]
        ListFontSize <- map["ListFontSize"]
        SelectedColor <- map["SelectedColor"]
        SelectedBackgroundColor <- map["SelectedBackgroundColor"]
        SelectedBackgroundAlpha <- map["SelectedBackgroundAlpha"]
        SelectedFontId <- map["SelectedFontId"]
        SelectedFontSize <- map["SelectedFontSize"]
        SelectedIconColor <- map["SelectedIconColor"]
        ButtonColor <- map["ButtonColor"]
        ButtonBackgroundColor <- map["ButtonBackgroundColor"]
        ButtonBackgroundAlpha <- map["ButtonBackgroundAlpha"]
        ButtonFontId <- map["ButtonFontId"]
        ButtonFontSize <- map["ButtonFontSize"]
        ProgressBarColor <- map["ProgressBarColor"]
        ProgressBarBackgroundColor <- map["ProgressBarBackgroundColor"]
        ProgressBarBackgroundAlpha <- map["ProgressBarBackgroundAlpha"]
        TooltipColor <- map["TooltipColor"]
        TooltipBackgroundColor <- map["TooltipBackgroundColor"]
        TooltipBackgroundAlpha <- map["TooltipBackgroundAlpha"]
        TooltipFontId <- map["TooltipFontId"]
        TooltipFontSize <- map["TooltipFontSize"]
        SeparatorColor <- map["SeparatorColor"]
        IsFirstQuestion <- map["IsFirstQuestion"]
        Required <- map["Required"]
        
        Answer <- map["Answer"]
        Answers <- map["Answers"]
        Options <- map["Options"]
    }
}
