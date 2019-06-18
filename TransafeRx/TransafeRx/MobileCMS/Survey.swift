//
//  Survey.swift
//  eHEARTT
//
//  Created by Tachl on 11/8/16.
//  Copyright © 2016 Tachl. All rights reserved.
//

import Foundation
import ObjectMapper

class Survey: Item {
    var SurveyId : Int = 0
    var TotalQuestions : Int = 0
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
    var AllowRestart : Bool = false
    var AutoSubmit : Bool = false
    
    var Session: SurveySession?
    
    override init() {
        super.init()
    }
    
    required public init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        SurveyId <- map["SurveyId"]
        TotalQuestions <- map["TotalQuestions"]
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
        AllowRestart <- map["AllowRestart"]
        AutoSubmit <- map["AutoSubmit"]
        Session <- map["Session"]
    }
}
