//
//  KeychainManager.swift
//  VoiceCrisisAlert
//
//  Created by Tachl on 6/12/17.
//  Copyright © 2017 Tachl. All rights reserved.
//

import Foundation
import KeychainAccess

@objc open class KeychainManager: NSObject{
    
    static let sharedManager = KeychainManager()
    
    let keychain = Keychain()

    // MARK: - Initialization
    public override init(){
        
    }
    
    func getBPDevice() -> String?{
        var device: String?
        if keychain["BPDEVICE"] != nil{
            device = keychain["BPDEVICE"]
        }
        return device
    }
    
    func setBPDevice(_ device: String){
        keychain["BPDEVICE"] = device
    }
    
    func getBGDevice() -> String?{
        var device: String?
        if keychain["BGDEVICE"] != nil{
            device = keychain["BGDEVICE"]
        }
        return device
    }
    
    func setBGDevice(_ device: String){
        keychain["BGDEVICE"] = device
    }
    
    func setIsLoggedIn(loggedIn: Bool){
        keychain["LoggedIn"] = loggedIn.description
    }
    
    func getIsLoggedIn() -> Bool{
        var loggedIn = false
        
        if keychain["LoggedIn"] != nil{
            loggedIn = Bool(keychain["LoggedIn"]!)!
        }
        
        return loggedIn
    }
}
