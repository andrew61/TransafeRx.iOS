//
//  ForaBpBluetoothDelegate.h
//  TransafeRx
//
//  Created by Tachl on 7/27/17.
//  Copyright © 2017 Tachl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol ForaBpBluetoothDelegate <NSObject>
    
- (void)deviceDidConnect;
- (void)deviceDidFailToConnect;
- (void)deviceDidDisconnect;
- (void)deviceDidTimeout;
- (void)deviceDidReadCharacteristics;
- (void)deviceDidStartBp;
- (void)deviceDidClearData;
- (void)deviceClockWritten;
- (void)gotDeviceModel:(id)model;
- (void)gotReading:(id)reading;
- (void)gotDataCount:(id)count;
- (void)gotTimeResult:(id)timeResult;
- (void)gotDataResult:(id)dataResult;
@end
