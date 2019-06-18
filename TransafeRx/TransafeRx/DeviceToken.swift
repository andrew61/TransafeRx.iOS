//
//  DeviceToken.swift
//  TransafeRx
//
//  Created by Tachl on 9/14/17.
//  Copyright © 2017 Tachl. All rights reserved.
//

import Foundation
import ObjectMapper

class DeviceToken: NSObject, Mappable{
    
    var Token: String?
    
    override init(){
        
    }
    
    init(token: String?){
        Token = token
    }
    
    
    required public init?(map: Map){
        
    }
    
    public func mapping(map: Map) {
        Token <- map["Token"]
    }
}
