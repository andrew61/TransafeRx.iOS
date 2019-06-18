//
//  Resource.swift
//  eHEARTT
//
//  Created by Tachl on 11/21/16.
//  Copyright © 2016 Tachl. All rights reserved.
//

import Foundation
import ObjectMapper

class Resource: Item {
    var ResourceId : Int = 0
    var Url : String?
    
    override init() {
        super.init()
    }
    
    required public init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        ResourceId <- map["ResourceId"]
        Url <- map["Url"]
    }
}
