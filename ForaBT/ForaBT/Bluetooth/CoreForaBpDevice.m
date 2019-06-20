//  MSSCoreBluetoothDevice.m
//  SEAMS
//  Created by Michael McEvoy on 2/21/15.
//  Copyright (c) 2015 Michael McEvoy. All rights reserved.
// Header import
#define CONNECTION_TIMEOUT 10

#import <CoreBluetooth/CoreBluetooth.h>
#import "CoreForaBpDevice.h"

@implementation CoreForaBpDevice

- (instancetype)initWithDelegate:(id<CoreBluetoothDelegate>)delegate deviceName:(NSString *)deviceName services:(NSArray *)services characteristics:(NSArray *)characteristics
{
    self = [super init];
    if (self != nil)
    {
        self.delegate = delegate;
        self.deviceName = deviceName;
        self.services = services;
        self.characteristics = characteristics;
        self.bluetoothManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    return self;
}

- (void)connectWithTimeout:(int)timeout
{
    if (self.bluetoothManager.state == CBCentralManagerStatePoweredOn)
    {
        if (timeout > 0)
        {
            self.timer = [NSTimer scheduledTimerWithTimeInterval:timeout target:self selector:@selector(deviceDidTimeout) userInfo:nil repeats:NO];
        }
        
        //        if (self.peripheral != nil)
        //        {
        //            NSArray *knownPeripherals = [self.bluetoothManager retrievePeripheralsWithIdentifiers:[NSArray arrayWithObject:[CBUUID UUIDWithNSUUID:self.peripheral.identifier]]];
        //
        //            if ([knownPeripherals count] > 0)
        //            {
        //                for (CBPeripheral *peripheral in knownPeripherals)
        //                {
        //                    if (peripheral.identifier == self.peripheral.identifier)
        //                    {
        //                        self.peripheral = peripheral;
        //                        [self.bluetoothManager connectPeripheral:self.peripheral options:nil];
        //                        return;
        //                    }
        //                }
        //            }
        //        }
        [self.bluetoothManager scanForPeripheralsWithServices:self.services options:nil];
    }
}

- (void)deviceDidTimeout
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(deviceDidTimeout)])
    {
        [self.delegate deviceDidTimeout];
    }
}

- (void)disconnect
{
    if (self.peripheral != nil)
    {
        [self.bluetoothManager cancelPeripheralConnection:self.peripheral];
    }
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state)
    {
        case CBCentralManagerStatePoweredOn:
            break;
        default:
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSString *localName = advertisementData[@"kCBAdvDataLocalName"];
    
    NSLog(@"localName: %@", localName);
    if (localName != nil && [localName rangeOfString:self.deviceName].location != NSNotFound)
    {
        NSLog(@"FOUND: %@", localName);
        
        [self.timer invalidate];
        
        self.peripheral = peripheral;
        [self.bluetoothManager stopScan];
        [self.bluetoothManager connectPeripheral:self.peripheral options:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    if (peripheral == self.peripheral)
    {
        [self.timer invalidate];
        
        peripheral.delegate = self;
        [self.delegate deviceDidConnect];
        [peripheral discoverServices:self.services];
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    if (peripheral == self.peripheral)
    {
        [self.delegate deviceDidFailToConnect];
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    if (peripheral == self.peripheral)
    {
        [self.delegate deviceDidDisconnect];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSLog(@"Service Count: %lu", [peripheral services].count);
    for (CBService *service in [peripheral services])
    {
        NSLog(@"Service: %@ \nService UUID: %@ \n Characteristic Count: %lu", service, service.UUID, service.characteristics.count);
        [peripheral discoverCharacteristics:self.characteristics forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    for (CBCharacteristic *characteristic in [service characteristics])
    {
        NSLog(@"Characteristic: %@;\n UUID: %@", characteristic, characteristic.UUID);
        
        if(self.data != nil){
            NSLog(@"Data being sent: %@", self.data);
            [peripheral writeValue:self.data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
        }
        else{
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (!characteristic.isNotifying)
    {
        [peripheral readValueForCharacteristic:characteristic];
    }
}

- (void)sendData:(NSData *)data
{
    self.data = data;
    
    if (self.peripheral != nil && self.peripheral.state == CBPeripheralStateConnected)
    {
        [self.peripheral discoverServices:self.services];
    }
    else
    {
        [self connectWithTimeout:CONNECTION_TIMEOUT];
    }
}

- (void)foraBpReadData{
    char const Command_ReadDevice[] = {0x51,   0x24,  0x00,    0x00,    0x00,   0x00,  0xA3,   0x18};//18 decimal/12 hex
    NSData *readDeviceData = [NSData dataWithBytes: Command_ReadDevice length:(unsigned)sizeof(Command_ReadDevice)];
    
    self.data = readDeviceData;
    
    if (self.peripheral != nil && self.peripheral.state == CBPeripheralStateConnected)
    {
        [self.peripheral discoverServices:self.services];
    }
    else
    {
        [self connectWithTimeout:CONNECTION_TIMEOUT];
    }
}

- (void)foraBpEnterCommData{
    char const Command_EnterCommunication[] = {0x51,   0x54,  0x00,    0x00,    0x00,   0x00,  0xA3,   0x48};//48 decimal/30hex
    NSData *enterCommData = [NSData dataWithBytes: Command_EnterCommunication length:(unsigned)sizeof(Command_EnterCommunication)];
    
    self.data = enterCommData;
    
    if (self.peripheral != nil && self.peripheral.state == CBPeripheralStateConnected)
    {
        [self.peripheral discoverServices:self.services];
    }
    else
    {
        [self connectWithTimeout:CONNECTION_TIMEOUT];
    }
}

- (void)foraBpTakeBPData{
    char const Command_TakeBP[] = {0x51,   0x43,  0x00,    0x00,    0x01,   0x01,  0xA3,   0x39};//39 decimal/27 hex
    NSData *takeBPData = [NSData dataWithBytes: Command_TakeBP length:(unsigned)sizeof(Command_TakeBP)];
    
    self.data = takeBPData;
    
    if (self.peripheral != nil && self.peripheral.state == CBPeripheralStateConnected)
    {
        [self.peripheral discoverServices:self.services];
    }
    else
    {
        [self connectWithTimeout:CONNECTION_TIMEOUT];
    }
}

- (void)notifyCharactersitics
{
    self.data = nil;
    if (self.peripheral != nil && self.peripheral.state == CBPeripheralStateConnected)
    {
        [self.peripheral discoverServices:self.services];
    }
    else
    {
        [self connectWithTimeout:CONNECTION_TIMEOUT];
    }
}

@end
