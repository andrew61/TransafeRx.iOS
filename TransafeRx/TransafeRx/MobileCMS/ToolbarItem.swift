//
//  ToolbarItem.swift
//  MobileCMS
//
//  Created by Jonathan on 3/15/17.
//  Copyright © 2017 Tachl. All rights reserved.
//

import Foundation
import ObjectMapper

public class ToolbarItem: NSObject, Mappable {
    var ToolbarItemId : Int = 0
    var Name : String?
    var ActionId : Int = 0
    var ItemText : String?
    var Icon : String?
    var TargetItemId : Int = 0
    var TargetItemTypeId : Int = 0
    
    var Navigation : ItemNavigation!
    
    override init() {
        
    }
    
    required public init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        ToolbarItemId <- map["ToolbarItemId"]
        Name <- map["Name"]
        ActionId <- map["ActionId"]
        ItemText <- map["ItemText"]
        Icon <- map["Icon"]
        TargetItemId <- map["TargetItemId"]
        TargetItemTypeId <- map["TargetItemTypeId"]
    }
}
