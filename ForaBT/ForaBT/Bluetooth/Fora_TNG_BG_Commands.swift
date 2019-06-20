//
//  Fora_TNG_BG_Commands.swift
//  ForaBT
//
//  Created by Tachl on 7/20/17.
//  Copyright © 2017 Tachl. All rights reserved.
//

import Foundation

struct Fora_TNG_BG_Commands{
    let Command_TurnOff = [0x51,   0x50,  0x00,    0x00,    0x00,   0x00,  0xA3,   0x68]//68 raw checksum... if hex, decimal = 104| if decimal, hex = 44
    
    //service UUID: 0x1523
    //charactericstic 0x1524 Write/Notify
    //00001524-1212-efde-1523-785feabcd123//TAKE BP Characteristic
    //00002a35-0000-1000-8000-00805f9b34fb//ENTER COMMUNICATION Characteristic
}
