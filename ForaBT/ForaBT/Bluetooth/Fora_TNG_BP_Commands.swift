//
//  Fora_TNG_BP_Commands.swift
//  ForaBT
//
//  Created by Tachl on 7/19/17.
//  Copyright © 2017 Tachl. All rights reserved.
//

import Foundation

struct Fora_TNG_BP_Commands{
    let Command_ReadDevice = [0x51,   0x24,  0x00,    0x00,    0x00,   0x00,  0xA3,   0x18]//checksum = 24 or 18?
    let Command_StartBP = [0x51,   0x43,  0x00,    0x00,    0x01,   0x01,  0xA3,   0x39]
    let Command_EnterCommunication = [0x51,   0x54,  0x00,    0x00,    0x00,   0x00,  0xA3,   0x48]
    
    //CHECK SUM
    /*
 
 byte bytes[] = {0x51,   0x54,  0x00,    0x00,    0x00,   0x00,  (byte)0xA3};
 byte checksum = 0x00;
 
 for(byte b : bytes){
 checksum += (0xff & b);
 }
 
 Log.d("DBG", "CheckSum: " + checksum);
 */
    //service UUID: 0x1523
    //charactericstic 0x1524 Write/Notify
    //00001524-1212-efde-1523-785feabcd123//TAKE BP Characteristic
    //00002a35-0000-1000-8000-00805f9b34fb//ENTER COMMUNICATION Characteristic
}
