//
//  PhoneNumbers.swift
//  TransafeRx
//
//  Created by Tachl on 3/21/18.
//  Copyright © 2018 Tachl. All rights reserved.
//

import Foundation
import ObjectMapper

public class PhoneNumbers: NSObject, Mappable{
    var Transplant : String?
    var Study : String?
    var Pharmacy : String?
    var Refill : String?
    
    override init(){
        
    }
    
    required public init?(map: Map){
        
    }
    
    public func mapping(map: Map) {
        Transplant <- map["Transplant"]
        Study <- map["Study"]
        Pharmacy <- map["Pharmacy"]
        Refill <- map["Refill"]
    }
}
