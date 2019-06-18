//
//  Item.swift
//  MobileCMS
//
//  Created by Tachl on 1/20/17.
//  Copyright © 2017 Tachl. All rights reserved.
//

import Foundation
import ObjectMapper

public class Item: NSObject, Mappable {
    var ItemId : Int = 0
    var ItemTypeId : Int = 0
    var Name : String?
    var TemplateId : Int = 0
    var HeaderTitle : String?
    var HeaderImage : String?
    var HeaderFontId : Int = 0
    var HeaderFontSize : Int = 0
    var HeaderColor : String?
    var HeaderBackgroundColor : String?
    var HeaderBackgroundImage : String?
    var HeaderEffect : Int = 0
    var BackButtonType : Int = 0
    var BackButtonColor : String?
    var BackButtonBackgroundColor : String?
    var BodyFontId : Int = 0
    var BodyFontSize : Int = 0
    var BodyColor : String?
    var BodyBackgroundColor : String?
    var BodyBackgroundImage : String?
    
    var Navigation : ItemNavigation!
    
    var ToolbarItems = [ToolbarItem]()
    var Actions = [ItemAction]()
    
    override init() {
        
    }
    
    required public init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        ItemId <- map["ItemId"]
        ItemTypeId <- map["ItemTypeId"]
        Name <- map["Name"]
        TemplateId <- map["TemplateId"]
        HeaderTitle <- map["HeaderTitle"]
        HeaderImage <- map["HeaderImage"]
        HeaderFontId <- map["HeaderFontId"]
        HeaderFontSize <- map["HeaderFontSize"]
        HeaderColor <- map["HeaderColor"]
        HeaderBackgroundColor <- map["HeaderBackgroundColor"]
        HeaderBackgroundImage <- map["HeaderBackgroundImage"]
        HeaderEffect <- map["HeaderEffect"]
        BackButtonType <- map["BackButtonType"]
        BackButtonColor <- map["BackButtonColor"]
        BackButtonBackgroundColor <- map["BackButtonBackgroundColor"]
        BodyFontId <- map["BodyFontId"]
        BodyFontSize <- map["BodyFontSize"]
        BodyColor <- map["BodyColor"]
        BodyBackgroundColor <- map["BodyBackgroundColor"]
        BodyBackgroundImage <- map["BodyBackgroundImage"]
    }
}
