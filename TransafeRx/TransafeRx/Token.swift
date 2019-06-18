//
//  Token.swift
//  WeightManagement
//
//  Created by Tachl on 11/30/16.
//  Copyright © 2016 Tachl. All rights reserved.
//

import Foundation
import ObjectMapper

class Token: NSObject, Mappable{
    var Expires : String?
    var Issued : String?
    var AccessToken : String = ""
    var ClientID : String?
    var ExpiresIn : NSNumber?
    var RefreshToken : String?
    var TokenType : String?
    
    override init(){
        
    }
    
    init(expires: String, issued: String, accessToken: String, clientId: String, expiresIn: NSNumber, refreshToken: String, tokenType: String){
        self.Expires = expires
        self.Issued = issued
        self.AccessToken = accessToken
        self.ClientID = clientId
        self.ExpiresIn = expiresIn
        self.RefreshToken = refreshToken
        self.TokenType = tokenType
    }
    
    required public init?(map: Map){
        
    }
    
    public func mapping(map: Map) {
        Expires <- map[".expires"]
        Issued <- map[".issued"]
        AccessToken <- map["access_token"]
        ClientID <- map["as:client_id"]
        ExpiresIn <- map["expires_in"]
        RefreshToken <- map["refresh_token"]
        TokenType <- map["token_type"]
    }
}
