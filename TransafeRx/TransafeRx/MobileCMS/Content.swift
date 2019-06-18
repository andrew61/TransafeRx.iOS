//
//  Content.swift
//  eHEARTT
//
//  Created by Tachl on 11/10/16.
//  Copyright © 2016 Tachl. All rights reserved.
//

import Foundation
import ObjectMapper

class Content: Item {
    var ContentId : Int = 0
    var Body : String?
    
    override init() {
        super.init()
    }
    
    required public init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        ContentId <- map["ContentId"]
        Body <- map["Body"]
    }
}
