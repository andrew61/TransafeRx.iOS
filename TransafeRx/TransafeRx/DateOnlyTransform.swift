//
//  DateOnlyTranform.swift
//  WeightManagement
//
//  Created by Tachl on 3/28/17.
//  Copyright © 2017 Tachl. All rights reserved.
//

import Foundation
import ObjectMapper

open class DateOnlyTransform: TransformType {
    
    public typealias Object = Date
    public typealias JSON = String
    
    public init() {}
    
    open func transformFromJSON(_ value: Any?) -> Date? {
        
        if let timeStr = value as? String {
            let date = timeStr.dateFromDate
            return date
        }
        
        return nil
    }
    
    open func transformToJSON(_ value: Date?) -> String? {
        if let date = value {
            return String(date.date)
        }
        return nil
    }
}
