//
//  Settings.swift
//  MobileCMS
//
//  Created by Tachl on 1/20/17.
//  Copyright © 2017 Tachl. All rights reserved.
//

import Foundation
import ObjectMapper

public class Settings: NSObject, Mappable {
    var Id: Int = 0
    var ApplicationName: String?
    var RootItemId: Int = 0
    var RootItemTypeId: Int = 0
    
    override init() {
        
    }
    
    required public init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        Id <- map["Id"]
        ApplicationName <- map["ApplicationName"]
        RootItemId <- map["RootItemId"]
        RootItemTypeId <- map["RootItemTypeId"]
    }
}
