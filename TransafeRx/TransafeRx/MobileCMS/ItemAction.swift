//
//  ItemAction.swift
//  MobileCMS
//
//  Created by Jonathan Tindall on 5/9/17.
//  Copyright © 2017 Tachl. All rights reserved.
//

import Foundation
import ObjectMapper

public class ItemAction: NSObject, Mappable {
    var ActionId: Int = 0
    var TargetItemId: Int = 0
    var SelectedMenuItemId : Int?
    
    override init() {
        
    }
    
    required public init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        ActionId <- map["ActionId"]
        TargetItemId <- map["TargetItemId"]
        SelectedMenuItemId <- map["SelectedMenuItemId"]
    }
}
