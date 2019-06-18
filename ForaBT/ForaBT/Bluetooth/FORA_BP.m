#define DEVICE_NAME @"TEST-N-GO BP"

//  MSS_AD_UA_651BLE.m
//  SEAMS
//  Created by Michael McEvoy on 2/21/15.
//  Copyright (c) 2015 Michael McEvoy. All rights reserved.
// Header import

#import <CoreBluetooth/CoreBluetooth.h>
#import "FORA_BP.h"
#import "BloodPressureMeasurement.h"

@implementation FORA_BP
    
- (instancetype)initWithDelegate:(id<CoreBluetoothDelegate>)delegate
    {
        NSArray *services = [NSArray arrayWithObjects:
                             [CBUUID UUIDWithString:@"0x1523"],
                             [CBUUID UUIDWithString:@"0x1524"],
                             [CBUUID UUIDWithString:@"0x1810"],
                             [CBUUID UUIDWithString:@"00001523-1212-efde-1523-785feabcd123"],
                            nil];
        NSArray *characteristics = [NSArray arrayWithObject:[CBUUID UUIDWithString:@"00001524-1212-efde-1523-785feabcd123"]];
        
        return [super initWithDelegate:delegate deviceName:DEVICE_NAME services:services characteristics:characteristics];
    }
    
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
    {
        NSLog(@"\n\nUpdated Characteristic: %@\n\n", characteristic);
        if ([peripheral.name rangeOfString:DEVICE_NAME].location != NSNotFound)
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
                
                NSLog(@"Response %@", response);

                if(response.length > 10){
                    NSString *responseType = [response substringWithRange:NSMakeRange(2, 2)];
                    
                    NSLog(@"ResponseType %@", responseType);
                    
                    if ([responseType isEqualToString:@"43"]){//Blood Pressure--Received at End of Blood Pressure
                        
                        NSString *systolicStr = [response substringWithRange:NSMakeRange(4, 4)];
                        NSString *diastolicStr = [response substringWithRange:NSMakeRange(8, 2)];
                        NSString *pulseStr = [response substringWithRange:NSMakeRange(10, 2)];
                        
                        NSLog(@"\nSystolic: %@\nDiastolic: %@\nPulse: %@\n", systolicStr, diastolicStr, pulseStr);
                        
                        unsigned int systolic;
                        [[NSScanner scannerWithString:systolicStr] scanHexInt:&systolic];
                        
                        unsigned int diastolic;
                        [[NSScanner scannerWithString:diastolicStr] scanHexInt:&diastolic];
                        
                        unsigned int pulse;
                        [[NSScanner scannerWithString:pulseStr] scanHexInt:&pulse];
                        
                        NSLog(@"\nInteger Values\nSystolic: %u\nDiastolic: %u\nPulse: %u\n", systolic, diastolic, pulse);
                    }
                    
                    if ([responseType isEqualToString:@"54"]){//Data Measurement Complete
                        NSLog(@"\n\nData Measurement Complete\n\n");
                    }
                }
            }
        }
    }
    
@end
