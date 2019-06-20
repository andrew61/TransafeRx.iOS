//
//  FORA_TNG_BG.swift
//  ForaBT
//
//  Created by Tachl on 7/19/17.
//  Copyright © 2017 Tachl. All rights reserved.
//

import Foundation
import CoreBluetooth

class FORA_TNG_BG: CoreBluetoothDevice{
    
    let DEVICE_NAME = "blahblah"
    
    init(delegate: CoreBluetoothDelegate) {
        let services = [CBUUID(string: ""), CBUUID(string: "")]
        let characteristics = [CBUUID(string: "")]
        
        super.init(delegate: delegate, deviceName: DEVICE_NAME, services: services, characteristics: characteristics)
    }
    
    override func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
    }
}
