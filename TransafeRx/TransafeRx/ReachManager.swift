//
//  ReachManager.swift
//  TransafeRx
//
//  Created by Andrew West on 2/26/19.
//  Copyright © 2019 Tachl. All rights reserved.
//

import Foundation

@objc open class ReachManager: NSObject{
    
    static let shared = ReachManager()
    
    
    // MARK: - Initialization
    public override init(){
    }
    
    func connectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
    
    func showConnectionAlert(vc: UIViewController){
        let alertController = UIAlertController(title: "Not Connected to a Network", message:
            "Certain Parts of the App will not Function", preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        vc.present(alertController, animated: true, completion: nil)
    }
}
