//  MSS_AD_UA_651BLE.m
//  SEAMS
//  Created by Michael McEvoy on 2/21/15.
//  Copyright (c) 2015 Michael McEvoy. All rights reserved.
// Header import

#import <CoreBluetooth/CoreBluetooth.h>
#import "FORA_BP.h"
#import "TransafeRx-Swift.h"

@implementation FORA_BP
    
- (instancetype)initWithDelegate:(id<ForaBpBluetoothDelegate>)delegate
    {
        NSArray *services = [NSArray arrayWithObjects:
                             [CBUUID UUIDWithString:@"0x1523"],
                             [CBUUID UUIDWithString:@"0x1524"],
                             [CBUUID UUIDWithString:@"0x1810"],
                             [CBUUID UUIDWithString:@"0x1702"],
                             [CBUUID UUIDWithString:@"0x1704"],
                             [CBUUID UUIDWithString:@"00001524-1212-EFDE-1523-785FEABCD123"],
                             [CBUUID UUIDWithString:@"00001523-1212-efde-1523-785feabcd123"],
                            nil];
        NSArray *characteristics = [NSArray arrayWithObject:[CBUUID UUIDWithString:@"00001524-1212-efde-1523-785feabcd123"]];
        
        return [super initWithDelegate:delegate deviceName:@"TEST-N-GO BP" services:services characteristics:characteristics];
    }

-(NSString *)toBinary:(NSUInteger)input strLength:(int)length{
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
    
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
    {
        if ([peripheral.name rangeOfString:@"TEST-N-GO BP"].location != NSNotFound || [peripheral.name rangeOfString:@"TNG BP"].location != NSNotFound)
        {
            NSData *valueData = characteristic.value;
            
            if (valueData != nil)
            {
                NSString *valueString = [[valueData description] stringByReplacingOccurrencesOfString:@" " withString:@""];
                NSMutableArray *buffer = [NSMutableArray arrayWithCapacity:[valueString length]];
                
                for (int i = 0; i < [valueString length]; i++)
                {
                    [buffer addObject:[NSString stringWithFormat:@"%C", [valueString characterAtIndex:i]]];
                }
                
                NSString *response = [buffer componentsJoinedByString:@""];
                response = [response stringByReplacingOccurrencesOfString:@"<" withString:@""];
                response = [response stringByReplacingOccurrencesOfString:@">" withString:@""];
                
                if([response isEqualToString:@"0100"]){
                    [self.delegate deviceDidReadCharacteristics];
                }

                if(response.length > 10 && response.length < 17){
                    NSString *responseType = [response substringWithRange:NSMakeRange(2, 2)];
                    
                    if ([responseType isEqualToString:@"24"]){//read model
                        NSString *model = [response substringWithRange:NSMakeRange(4, 4)];
                        if (self.delegate && [self.delegate respondsToSelector:@selector(gotDeviceModel:)]){
                            [self.delegate gotDeviceModel:model];
                        }
                    }
                    
                    if ([responseType isEqualToString:@"25"]){//read storage data time
                        NSString *m_date_1 = [response substringWithRange:NSMakeRange(4, 2)];
                        NSString *m_date_2 = [response substringWithRange:NSMakeRange(6, 2)];
                        
                        NSString *m_minute = [response substringWithRange:NSMakeRange(8, 2)];
                        NSString *m_hour = [response substringWithRange:NSMakeRange(10, 2)];
                        
                        NSUInteger hexAsInt1;
                        [[NSScanner scannerWithString:m_date_1]scanHexInt:&hexAsInt1];
                        NSString *binary1 = [NSString stringWithFormat:@"%@", [self toBinary:hexAsInt1 strLength:[m_date_1 length]]];
                        NSString *binary1_date = [binary1 substringWithRange:NSMakeRange(([binary1 length] - 8), 8)];
                        
                        NSUInteger hexAsInt2;
                        [[NSScanner scannerWithString:m_date_2]scanHexInt:&hexAsInt2];
                        NSString *binary2 = [NSString stringWithFormat:@"%@", [self toBinary:hexAsInt2 strLength:[m_date_2 length]]];
                        NSString *binary2_date = [binary2 substringWithRange:NSMakeRange(([binary2 length] - 8), 8)];
                        
                        NSString *yearBinary = [binary2_date substringWithRange:NSMakeRange(0, 7)];
                        NSString *monthBinary_1 = [binary2_date substringWithRange:NSMakeRange(7, 1)];
                        NSString *monthBinary_2 = [binary1_date substringWithRange:NSMakeRange(0, 3)];
                        NSString *monthBinary = [NSString stringWithFormat:@"%@%@", monthBinary_1, monthBinary_2];
                        NSString *dayBinary = [binary1_date substringWithRange:NSMakeRange(3, 5)];
                        
                        long year = strtol([yearBinary UTF8String], NULL, 2);
                        long month = strtol([monthBinary UTF8String], NULL, 2);
                        long day = strtol([dayBinary UTF8String], NULL, 2);
                        
                        unsigned int minute;
                        [[NSScanner scannerWithString:m_minute] scanHexInt:&minute];
                        
                        unsigned int hour;
                        [[NSScanner scannerWithString:m_hour] scanHexInt:&hour];
                        
                        NSDate *date = [NSDate dateWithYear:year month:month day:day hour:hour
                                                      minute:minute];
                        
                        if (self.delegate && [self.delegate respondsToSelector:@selector(gotTimeResult:)]){
                            [self.delegate gotTimeResult:date];
                        }
                    }
                    
                    if ([responseType isEqualToString:@"26"]){//read storage data results
                        NSString *systolicStr = [response substringWithRange:NSMakeRange(4, 2)];
                        NSString *mapStr = [response substringWithRange:NSMakeRange(6, 2)];
                        NSString *diastolicStr = [response substringWithRange:NSMakeRange(8, 2)];
                        NSString *pulseStr = [response substringWithRange:NSMakeRange(10, 2)];
                        
                        unsigned int systolic;
                        [[NSScanner scannerWithString:systolicStr] scanHexInt:&systolic];
                        
                        unsigned int diastolic;
                        [[NSScanner scannerWithString:diastolicStr] scanHexInt:&diastolic];
                        
                        unsigned int pulse;
                        [[NSScanner scannerWithString:pulseStr] scanHexInt:&pulse];
                        
                        BloodPressureMeasurement *bloodPressureMeasurement = [[BloodPressureMeasurement alloc]initWithSystolic:systolic diastolic:diastolic pulse:pulse];
                        
                        if (self.delegate && [self.delegate respondsToSelector:@selector(gotDataResult:)]){
                            [self.delegate gotDataResult:bloodPressureMeasurement];
                        }
                    }
                    
                    if ([responseType isEqualToString:@"2b"]){//read storage number of data
                        NSString *storageNumber = [response substringWithRange:NSMakeRange(4, 2)];
                        
                        unsigned int number;
                        [[NSScanner scannerWithString:storageNumber] scanHexInt:&number];
                        
                        NSNumber *value = [NSNumber numberWithInt:number];
                        
                        if (self.delegate && [self.delegate respondsToSelector:@selector(gotDataCount:)]){
                            [self.delegate gotDataCount:value];
                        }
                    }
                    
                    if ([responseType isEqualToString:@"33"]){
                        if (self.delegate && [self.delegate respondsToSelector:@selector(deviceClockWritten)]){
                            [self.delegate deviceClockWritten];
                        }
                    }
                    
                    if ([responseType isEqualToString:@"51"]){//Blood Pressure--Received at End of Blood Pressure
                        if (self.delegate && [self.delegate respondsToSelector:@selector(deviceDidStartBp)]){
                            [self.delegate deviceDidStartBp];
                        }
                    }
                    
                    if ([responseType isEqualToString:@"47"]){//taking bp
                        if (self.delegate && [self.delegate respondsToSelector:@selector(deviceDidStartBp)]){
                            [self.delegate deviceDidStartBp];
                        }
                    }
                    
                    if ([responseType isEqualToString:@"43"]){//Blood Pressure--Received at End of Blood Pressure
                        
                        NSString *systolicStr = [response substringWithRange:NSMakeRange(4, 4)];
                        NSString *diastolicStr = [response substringWithRange:NSMakeRange(8, 2)];
                        NSString *pulseStr = [response substringWithRange:NSMakeRange(10, 2)];
                        
                        unsigned int systolic;
                        [[NSScanner scannerWithString:systolicStr] scanHexInt:&systolic];
                        
                        unsigned int diastolic;
                        [[NSScanner scannerWithString:diastolicStr] scanHexInt:&diastolic];
                        
                        unsigned int pulse;
                        [[NSScanner scannerWithString:pulseStr] scanHexInt:&pulse];
                        
                        BloodPressureMeasurement *bloodPressureMeasurement = [[BloodPressureMeasurement alloc]initWithSystolic:systolic diastolic:diastolic pulse:pulse];
                        
                        if (self.delegate && [self.delegate respondsToSelector:@selector(gotReading:)]){
                            [self.delegate gotReading:bloodPressureMeasurement];
                        }
                    }
                    
                    if ([responseType isEqualToString:@"52"]){//cleared data
                        if (self.delegate && [self.delegate respondsToSelector:@selector(deviceDidClearData)])
                        {
                            [self.delegate deviceDidClearData];
                        }
                    }
                    
                    if ([responseType isEqualToString:@"54"]){//Data Measurement Complete
                        NSLog(@"\n\nData Measurement Complete\n\n");
                    }
                    
                    self.data = nil;
                }
            }
        }
    }
    
@end
