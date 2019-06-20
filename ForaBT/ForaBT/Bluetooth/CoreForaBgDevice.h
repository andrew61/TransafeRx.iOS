//
//  CoreForaBgDevice.h
//  ForaBT
//
//  Created by Tachl on 7/21/17.
//  Copyright © 2017 Tachl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreBluetoothDelegate.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface CoreForaBgDevice : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (strong, nonatomic) CBCentralManager *bluetoothManager;
@property (strong, nonatomic) CBPeripheral *peripheral;
@property (weak, nonatomic) id <CoreBluetoothDelegate> delegate;
@property (strong, nonatomic) id reading;
@property (copy, nonatomic) NSString *deviceName;
@property (strong, nonatomic) NSArray *services;
@property (strong, nonatomic) NSArray *characteristics;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSData *data;

- (instancetype)initWithDelegate:(id<CoreBluetoothDelegate>)delegate deviceName:(NSString *)deviceName services:(NSArray *)services characteristics:(NSArray *)characteristics;
- (void)connectWithTimeout:(int)timeout;
- (void)disconnect;
- (void)sendData:(NSData *)data;
- (void)foraBgTurnOff;
- (void)foraBgReadClock;
- (void)foraBgReadModel;
- (void)foraBgReadStorageTime;
- (void)foraBgReadStorageResults;
- (void)foraBgReadStoageNumber;
- (void)foraBgClearMemory;

- (void)notifyCharactersitics;

@end
