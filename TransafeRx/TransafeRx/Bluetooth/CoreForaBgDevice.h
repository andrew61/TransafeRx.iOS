//
//  CoreForaBgDevice.h
//  ForaBT
//
//  Created by Tachl on 7/21/17.
//  Copyright © 2017 Tachl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ForaBgBluetoothDelegate.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface CoreForaBgDevice : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (strong, nonatomic) CBCentralManager *bluetoothManager;
@property (strong, nonatomic) CBPeripheral *peripheral;
@property (weak, nonatomic) id <ForaBgBluetoothDelegate> delegate;
@property (strong, nonatomic) id reading;
@property (strong, nonatomic) id count;
@property (strong, nonatomic) id timeResult;
@property (strong, nonatomic) id dataResult;
@property (copy, nonatomic) NSString *deviceName;
@property (strong, nonatomic) NSArray *services;
@property (strong, nonatomic) NSArray *characteristics;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSData *data;

- (instancetype)initWithDelegate:(id<ForaBgBluetoothDelegate>)delegate deviceName:(NSString *)deviceName services:(NSArray *)services characteristics:(NSArray *)characteristics;
- (void)connectWithTimeout:(int)timeout;
- (void)disconnect;
- (void)sendData:(NSData *)data;
- (void)foraBgTurnOff;
- (void)foraBgReadClock;
- (void)foraBgWriteClock:(int)hour andMinute:(int)minute andDay:(int)Day andMonth:(int)Month andYear:(int)Year;
- (void)foraBgReadModel;
- (void)foraBgReadStorageTime:(int)index;
- (void)foraBgReadStorageResults:(int)index;
- (void)foraBgReadStorageNumber;
- (void)foraBgClearMemory;
- (void)notifyCharactersitics;
- (NSString *)toBinary:(NSUInteger)input strLength:(int)length;
@end
