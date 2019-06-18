//
//  ChartModel.swift
//  TransafeRx
//
//  Created by Tachl on 9/25/17.
//  Copyright © 2017 Tachl. All rights reserved.
//

import Foundation
import ObjectMapper

class ChartModel: NSObject, Mappable{
    var StartDate: Date?
    var EndDate: Date?
    var Aggregate: Int?
    
    init(startDate: Date?, endDate: Date?, aggregate: Int?){
        StartDate = startDate
        EndDate = endDate
        Aggregate = aggregate
    }
    
    override init(){
        
    }
    
    required public init?(map: Map){
        
    }
    
    public func mapping(map: Map) {
        StartDate <- (map["StartDate"], UTCDateTransform())
        EndDate <- (map["EndDate"], UTCDateTransform())
        Aggregate <- map["Aggregate"]
    }
}
