//
//  BooleanTransform.swift
//  WeightManagement
//
//  Created by Tachl on 3/23/17.
//  Copyright © 2017 Tachl. All rights reserved.
//

import Foundation
import ObjectMapper

open class BooleanTransform: TransformType {
    
    public typealias Object = Bool
    public typealias JSON = String
    
    public init() {}
    
    open func transformFromJSON(_ value: Any?) -> Bool? {
        
        if let boolValue = value as? Bool {
            return boolValue
        }
        
        return nil
    }
    
    open func transformToJSON(_ value: Bool?) -> String? {
        if let bool = value {
            return bool.description
        }
        return nil
    }
}
