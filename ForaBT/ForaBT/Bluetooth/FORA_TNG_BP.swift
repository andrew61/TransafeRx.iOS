//
//  FORA_TNG_BP.swift
//  ForaBT
//
//  Created by Tachl on 7/19/17.
//  Copyright © 2017 Tachl. All rights reserved.
//

import Foundation
import CoreBluetooth

class FORA_TNG_BP: CoreBluetoothDevice{

    let DEVICE_NAME = "TEST-N-GO BP"
    
    init(delegate: CoreBluetoothDelegate) {
        let services = NSArray(objects: [CBUUID(string: "0x1523"), CBUUID(string: "0x1524"), CBUUID(string: "0x1810"), CBUUID(string: "00001523-1212-efde-1523-785feabcd123"), nil])

        let characteristics = NSArray(object: CBUUID(string: "00001524-1212-efde-1523-785feabcd123"))//[CBUUID(string: "00001524-1212-efde-1523-785feabcd123")]
        
        super.init(delegate: delegate, deviceName: DEVICE_NAME, services: services as! [Any], characteristics: characteristics as! [Any])
    }
    
    override func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("\n\nUpdated Characteristic: \(characteristic)\n\n");
    }
}

//NSArray *services = [NSArray arrayWithObjects:
//    [CBUUID UUIDWithString:@"0x1523"],
//    [CBUUID UUIDWithString:@"0x1524"],
//    [CBUUID UUIDWithString:@"0x1810"],
//    [CBUUID UUIDWithString:@"00001523-1212-efde-1523-785feabcd123"],
//    nil];
//NSArray *characteristics = [NSArray arrayWithObject:[CBUUID UUIDWithString:@"00001524-1212-efde-1523-785feabcd123"]];
//
//return [super initWithDelegate:delegate deviceName:DEVICE_NAME services:services characteristics:characteristics];
