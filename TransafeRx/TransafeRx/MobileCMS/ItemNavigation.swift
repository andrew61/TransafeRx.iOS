//
//  ItemNavigation.swift
//  MobileCMS
//
//  Created by Jonathan on 3/11/17.
//  Copyright © 2017 Tachl. All rights reserved.
//

import Foundation
import ObjectMapper

public class ItemNavigation: NSObject, Mappable {
    var NavigationId : Int = 0
    var ItemId : Int = 0
    var TemplateId : Int = 0
    var TargetItemId : Int = 0
    var SelectedMenuItemId : Int?
    var Priority : Int = 0
    var NavigationTypeId : Int = 0
    var TransitionTypeId : Int = 0
    var ButtonText : String?
    var ButtonImage : String?
    var ButtonFontId : Int = 0
    var ButtonFontSize : Int = 0
    var ButtonColor : String?
    var ButtonBackgroundColor : String?
    
    override init() {
        
    }
    
    required public init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        NavigationId <- map["NavigationId"]
        ItemId <- map["ItemId"]
        TemplateId <- map["TemplateId"]
        TargetItemId <- map["TargetItemId"]
        SelectedMenuItemId <- map["SelectedMenuItemId"]
        Priority <- map["Priority"]
        NavigationTypeId <- map["NavigationTypeId"]
        TransitionTypeId <- map["TransitionTypeId"]
        ButtonText <- map["ButtonText"]
        ButtonImage <- map["ButtonImage"]
        ButtonFontId <- map["ButtonFontId"]
        ButtonFontSize <- map["ButtonFontSize"]
        ButtonColor <- map["ButtonColor"]
        ButtonBackgroundColor <- map["ButtonBackgroundColor"]
    }
}
