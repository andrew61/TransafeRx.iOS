//  MSSCoreBluetoothDevice.m
//  SEAMS
//  Created by Michael McEvoy on 2/21/15.
//  Copyright (c) 2015 Michael McEvoy. All rights reserved.
// Header import
#define CONNECTION_TIMEOUT 10

#import <CoreBluetooth/CoreBluetooth.h>
#import "CoreForaBgDevice.h"
#import "TransafeRx-Swift.h"

@implementation CoreForaBgDevice

- (instancetype)initWithDelegate:(id<ForaBgBluetoothDelegate>)delegate deviceName:(NSString *)deviceName services:(NSArray *)services characteristics:(NSArray *)characteristics
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
                
        [self.bluetoothManager scanForPeripheralsWithServices:nil options:nil];
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
    
    if (localName != nil && ([localName rangeOfString:self.deviceName].location != NSNotFound || [localName rangeOfString:@"TEST-N-GO VOICE"].location != NSNotFound))
    {
        NSLog(@"FOUND: %@", localName);
        
//        if([[KeychainManager sharedManager]getBGDevice] == nil){
//            [[KeychainManager sharedManager]setBGDevice:localName];
//        }
        
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
            [self.delegate deviceDidReadCharacteristics];
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

- (void)foraBgTurnOff{
    char const Command[] = {0x51,   0x50,  0x00,    0x00,    0x00,   0x00,  0xA3,   0x44};
    NSData *commandData = [NSData dataWithBytes: Command length:(unsigned)sizeof(Command)];
    
    self.data = commandData;
    
    if (self.peripheral != nil && self.peripheral.state == CBPeripheralStateConnected)
    {
        [self.peripheral discoverServices:self.services];
    }
    else
    {
        [self connectWithTimeout:CONNECTION_TIMEOUT];
    }
}

- (void)foraBgReadClock{
    char const Command[] = {0x51,   0x23,  0x00,    0x00,    0x00,   0x00,  0xA3,   0x17};//23 dec or 17 hex(checksum value of bytes 1-7)
    NSData *commandData = [NSData dataWithBytes: Command length:(unsigned)sizeof(Command)];
    
    self.data = commandData;
    
    if (self.peripheral != nil && self.peripheral.state == CBPeripheralStateConnected)
    {
        [self.peripheral discoverServices:self.services];
    }
    else
    {
        [self connectWithTimeout:CONNECTION_TIMEOUT];
    }
}

- (void)foraBgWriteClock:(int)hour andMinute:(int)minute andDay:(int)Day andMonth:(int)Month andYear:(int)Year{
    
    NSString *binaryDay = [NSString stringWithFormat:@"%@", [self toBinary:Day strLength:(int)[NSString stringWithFormat:@"%d", Day].length]];
    NSString *binaryMonth = [NSString stringWithFormat:@"%@", [self toBinary:Month strLength:(int)[NSString stringWithFormat:@"%d", Month].length]];
    NSString *binaryYear = [NSString stringWithFormat:@"%@", [self toBinary:Year strLength:2]];
    
    if([binaryDay length] == 1){
        binaryDay = [NSString stringWithFormat:@"0000000%@", binaryDay];
    }else if([binaryDay length] == 4){
        binaryDay = [NSString stringWithFormat:@"0000%@", binaryDay];
    }
    if([binaryMonth length] == 1){
        binaryMonth = [NSString stringWithFormat:@"0000000%@", binaryMonth];
    }else if([binaryMonth length] == 4){
        binaryMonth = [NSString stringWithFormat:@"0000%@", binaryMonth];
    }
    
    NSString *data_1 = [NSString stringWithFormat:@"%@%@", [binaryYear substringWithRange:NSMakeRange(3, 5)], [binaryMonth substringWithRange:NSMakeRange(4, 1)]];;
    NSString *data_0 = [NSString stringWithFormat:@"%@%@", [binaryMonth substringWithRange:NSMakeRange(5, 3)], [binaryDay substringWithRange:NSMakeRange(3, 5)]];
    
    long data_1_long = strtol([data_1 UTF8String], NULL, 2);
    long data_0_long = strtol([data_0 UTF8String], NULL, 2);
    
    unsigned char data_1_char = (unsigned char)data_1_long;
    unsigned char data_0_char = (unsigned char)data_0_long;
    unsigned char minuteChar = (unsigned char)minute;
    unsigned char hourChar = (unsigned char)hour;

    int sum = 39 + (int)data_1_long + (int)data_0_long + minute + hour;
    unsigned char checksum = (unsigned char)sum;
    
    char const Command[] = {0x51,   0x33, data_0_char, data_1_char, minuteChar, hourChar, 0xA3, checksum};//39 dec or 27 hex(checksum value of bytes 1-7)
    NSData *commandData = [NSData dataWithBytes: Command length:(unsigned)sizeof(Command)];
    
    self.data = commandData;
    
    if (self.peripheral != nil && self.peripheral.state == CBPeripheralStateConnected)
    {
        [self.peripheral discoverServices:self.services];
    }
    else
    {
        [self connectWithTimeout:CONNECTION_TIMEOUT];
    }
}

- (void)foraBgReadModel{
    char const Command[] = {0x51,   0x24,  0x00,    0x00,    0x00,   0x00,  0xA3,   0x18};//24 dec or 18 hex
    NSData *commandData = [NSData dataWithBytes: Command length:(unsigned)sizeof(Command)];
    
    self.data = commandData;
    
    if (self.peripheral != nil && self.peripheral.state == CBPeripheralStateConnected)
    {
        [self.peripheral discoverServices:self.services];
    }
    else
    {
        [self connectWithTimeout:CONNECTION_TIMEOUT];
    }
}

- (void)foraBgReadStorageTime:(int)index{
    
    unsigned char slotIndex = (unsigned char)index;
    int sum = 25 + index;
    unsigned char checksum = (unsigned char)sum;
    
    char const Command[] = {0x51, 0x25, slotIndex, 0x00, 0x00, 0x00, 0xA3, checksum};//26 dec or 1A hex
    NSData *commandData = [NSData dataWithBytes: Command length:(unsigned)sizeof(Command)];
    
    self.data = commandData;
    
    if (self.peripheral != nil && self.peripheral.state == CBPeripheralStateConnected)
    {
        [self.peripheral discoverServices:self.services];
    }
    else
    {
        [self connectWithTimeout:CONNECTION_TIMEOUT];
    }
}

//- (void)foraBgReadStorageTime{                    //index part1&2
//    char const Command[] = {0x51,   0x25,  0x00,    0x00,    0x01,   0x00,  0xA3,   0x1A};//26 dec or 1A hex
//    NSData *commandData = [NSData dataWithBytes: Command length:(unsigned)sizeof(Command)];
//    
//    self.data = commandData;
//    
//    if (self.peripheral != nil && self.peripheral.state == CBPeripheralStateConnected)
//    {
//        [self.peripheral discoverServices:self.services];
//    }
//    else
//    {
//        [self connectWithTimeout:CONNECTION_TIMEOUT];
//    }
//}

- (void)foraBgReadStorageResults:(int)index{
    
    unsigned char slotIndex = (unsigned char)index;
    int sum = 26 + index;
    unsigned char checksum = (unsigned char)sum;
    
    char const Command[] = {0x51, 0x26, slotIndex, 0x00, 0x00, 0x00, 0xA3, checksum};//27 dec or 1B hex
    NSData *commandData = [NSData dataWithBytes: Command length:(unsigned)sizeof(Command)];
    
    self.data = commandData;
    
    if (self.peripheral != nil && self.peripheral.state == CBPeripheralStateConnected)
    {
        [self.peripheral discoverServices:self.services];
    }
    else
    {
        [self connectWithTimeout:CONNECTION_TIMEOUT];
    }
}
//- (void)foraBgReadStorageResults{                 //index part1&2
//    char const Command[] = {0x51,   0x26,  0x00,    0x00,    0x01,   0x00,  0xA3,   0x1B};//27 dec or 1B hex
//    NSData *commandData = [NSData dataWithBytes: Command length:(unsigned)sizeof(Command)];
//    
//    self.data = commandData;
//    
//    if (self.peripheral != nil && self.peripheral.state == CBPeripheralStateConnected)
//    {
//        [self.peripheral discoverServices:self.services];
//    }
//    else
//    {
//        [self connectWithTimeout:CONNECTION_TIMEOUT];
//    }
//}

- (void)foraBgReadStorageNumber{
    char const Command[] = {0x51,   0x2B,  0x00,    0x00,    0x00,   0x00,  0xA3,   0x1F};//31 dec or 1F hex
    NSData *commandData = [NSData dataWithBytes: Command length:(unsigned)sizeof(Command)];
    
    self.data = commandData;
    
    if (self.peripheral != nil && self.peripheral.state == CBPeripheralStateConnected)
    {
        [self.peripheral discoverServices:self.services];
    }
    else
    {
        [self connectWithTimeout:CONNECTION_TIMEOUT];
    }
}

- (void)foraBgClearMemory{
    char const Command[] = {0x51,  0x52,  0x00,    0x00,    0x00,   0x00,  0xA3,   0x46};//70 dec or 46 hex
    NSData *commandData = [NSData dataWithBytes: Command length:(unsigned)sizeof(Command)];
    
    self.data = commandData;
    
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

- (NSString *)toBinary:(NSUInteger)input strLength:(int)length{
    if (input == 1 || input == 0){
        
        NSString *str=[NSString stringWithFormat:@"%u", input];
        return str;
    }
    else {
        NSString *str=[NSString stringWithFormat:@"%@%u", [self toBinary:input / 2 strLength:0], input % 2];
        if(length>0){
            int reqInt = length * 4;
            for(int i= [str length];i < reqInt;i++){
                str=[NSString stringWithFormat:@"%@%@",@"0",str];
            }
        }
        return str;
    }
}

@end
