//
//  LoginInformation.swift
//  WeightManagement
//
//  Created by Tachl on 4/13/17.
//  Copyright © 2017 Tachl. All rights reserved.
//

import Foundation
import ObjectMapper
import CoreTelephony
import CoreLocation

class LoginInformation: NSObject, Mappable, CLLocationManagerDelegate{
    
    var LoginInformationId: Int?
    var DateDTO: Date?
    var Longitude: String?
    var Latitude: String?
    var Model: String?
    var OS: String?
    var Network: String?
    var PhoneType: String?
    var AppVersion: String?
    var DateCTZ: String?

    let locationManager = CLLocationManager()
    let networkInfo = CTTelephonyNetworkInfo()
    
    override init(){
        super.init()
        let carrier = networkInfo.subscriberCellularProvider
        locationManager.delegate = self
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestLocation()
        DateDTO = Date()
        DateCTZ = TimeZone.current.identifier
        Model = UIDevice.current.modelName
        OS = UIDevice.current.systemVersion
        Network = carrier != nil ? carrier!.carrierName : "N/A"
        PhoneType = "Apple"
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            AppVersion = version
        }
        if locationManager.location != nil{
            Longitude = String((locationManager.location?.coordinate.longitude)!)
            Latitude = String((locationManager.location?.coordinate.latitude)!)
        }else{
            Longitude = "N/A"
            Latitude = "N/A"
        }
    }
    
    required public init?(map: Map){
    }
    
    public func mapping(map: Map) {
        LoginInformationId <- map["LoginInformationId"]
        DateDTO <- (map["DateDTO"], DTODateTransform())
        Longitude <- map["Longitude"]
        Latitude <- map["Latitude"]
        Model <- map["Model"]
        OS <- map["OS"]
        Network <- map["Network"]
        PhoneType <- map["PhoneType"]
        AppVersion <- map["AppVersion"]
        DateCTZ <- map["DateCTZ"]
    }
    
    // MARK: - CLLocation Manager Delegate Methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Location: \(locations.first)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error: \(error)")
    }
}
