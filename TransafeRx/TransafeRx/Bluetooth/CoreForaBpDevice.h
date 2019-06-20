//
//  CoreForaBpDevice.h
//  ForaBT
//
//  Created by Tachl on 7/21/17.
//  Copyright © 2017 Tachl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ForaBpBluetoothDelegate.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface CoreForaBpDevice : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (strong, nonatomic) CBCentralManager *bluetoothManager;
@property (strong, nonatomic) CBPeripheral *peripheral;
@property (weak, nonatomic) id <ForaBpBluetoothDelegate> delegate;
@property (strong, nonatomic) id reading;
@property (strong, nonatomic) id count;
@property (strong, nonatomic) id timeResult;
@property (strong, nonatomic) id dataResult;
@property (copy, nonatomic) NSString *deviceName;
@property (strong, nonatomic) NSArray *services;
@property (strong, nonatomic) NSArray *characteristics;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSData *data;

- (instancetype)initWithDelegate:(id<ForaBpBluetoothDelegate>)delegate deviceName:(NSString *)deviceName services:(NSArray *)services characteristics:(NSArray *)characteristics;
- (void)connectWithTimeout:(int)timeout;
- (void)disconnect;
- (void)sendData:(NSData *)data;
- (void)foraBpReadData;
- (void)foraBpReadModel;
- (void)foraBpTurnOff;
- (void)foraBpWriteClock:(int)hour andMinute:(int)minute andDay:(int)Day andMonth:(int)Month andYear:(int)Year;
- (void)foraBpReadStorageTime:(int)index;
- (void)foraBpReadStorageResults:(int)index;
- (void)foraBpReadStorageNumber;
- (void)foraBpEnterCommData;
- (void)foraBpTakeBPData;
- (void)foraBpClearMemory;
- (void)notifyCharactersitics;

@end
