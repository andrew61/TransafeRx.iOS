//
//  TimeTransform.swift
//  WeightManagement
//
//  Created by Tachl on 5/18/17.
//  Copyright © 2017 Tachl. All rights reserved.
//

import Foundation
import ObjectMapper

open class TimeTransform: TransformType {
    
    public typealias Object = Date
    public typealias JSON = String
    
    public init() {}
    
    open func transformFromJSON(_ value: Any?) -> Date? {
        
        if let timeStr = value as? String {
            let date = timeStr.dateFromTime
            return date
        }
        
        return nil
    }
    
    open func transformToJSON(_ value: Date?) -> String? {
        if let date = value {
            return String(date.time)
        }
        return nil
    }
}
