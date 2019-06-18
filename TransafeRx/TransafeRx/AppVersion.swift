//
//  AppVersion.swift
//  TransafeRx
//
//  Created by Tachl on 12/14/17.
//  Copyright © 2017 Tachl. All rights reserved.
//

import Foundation
import ObjectMapper

class AppVersion: NSObject, Mappable{
    
    var AppVersionId: Int?
    var AppId: Int?
    var Version: String?
    
    override init(){
        super.init()
    }
    
    required public init?(map: Map){
    }
    
    public func mapping(map: Map) {
        AppVersionId <- map["AppVersionId"]
        AppId <- map["AppId"]
        Version <- map["Version"]
    }
    
    func isCurrentVersion() -> Bool{
        if let bundleVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String{
            let decimalBundleVersion = Double(bundleVersion)!
            if self.Version != nil{
                let decimalDBVersion = Double(self.Version!)!
                if decimalBundleVersion >= decimalDBVersion{
                    return true
                }
            }
        }
        return false
    }
}
