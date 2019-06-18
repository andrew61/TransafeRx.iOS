#define DEVICE_NAME @"TNG VOICE"

//  MSS_AD_UA_651BLE.m
//  SEAMS
//  Created by Michael McEvoy on 2/21/15.
//  Copyright (c) 2015 Michael McEvoy. All rights reserved.
// Header import

#import <CoreBluetooth/CoreBluetooth.h>
#import "FORA_BG.h"

@implementation FORA_BG
    
- (instancetype)initWithDelegate:(id<CoreBluetoothDelegate>)delegate
    {
        NSArray *services = [NSArray arrayWithObjects:
                             [CBUUID UUIDWithString:@"0x1523"],
                             [CBUUID UUIDWithString:@"0x1524"],
                             [CBUUID UUIDWithString:@"0x1702"],
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
                    
                    if ([responseType isEqualToString:@"23"]){//read clock
                        NSLog(@"\nReading Clock\n");
                        
                        NSString *date = [response substringWithRange:NSMakeRange(4, 4)];
                        NSString *minute = [response substringWithRange:NSMakeRange(8, 2)];
                        NSString *hour = [response substringWithRange:NSMakeRange(10, 2)];

                        NSLog(@"\nClock Date: %@\nClock Hour: %@\nClock Minute:%@\n", date, hour, minute);
                    }
                    
                    if ([responseType isEqualToString:@"24"]){//read model
                        NSLog(@"\nReading Model\n");
                        
                        NSString *model = [response substringWithRange:NSMakeRange(4, 4)];
                        NSLog(@"\nModel: %@\n", model);
                    }
                    
                    if ([responseType isEqualToString:@"25"]){//read storage data time
                        NSLog(@"\nReading Storage Data Time\n");
                        
                        NSString *m_date = [response substringWithRange:NSMakeRange(4, 4)];
                        NSString *m_time = [response substringWithRange:NSMakeRange(8, 4)];
                        NSLog(@"\nDate: %@\nTime: %@\n", m_date, m_time);
                    }
                    
                    if ([responseType isEqualToString:@"26"]){//read storage data results
                        NSLog(@"\nReading Storage Data Results\n");
                        
                        NSString *glucoseStr = [response substringWithRange:NSMakeRange(4, 2)];
                        NSString *param = [response substringWithRange:NSMakeRange(8, 4)];
                        
                        NSLog(@"\nGlucose: %@\nGlucoseType: %@\n", glucoseStr, param);

                        unsigned int glucose;
                        [[NSScanner scannerWithString:glucoseStr] scanHexInt:&glucose];
                        
                        NSLog(@"\nGlucose Value: %u\n", glucose);
                    }
                    
                    if ([responseType isEqualToString:@"2b"]){//read storage number of data
                        NSLog(@"\nReading Storage Number of Data\n");
                        
                        NSString *storageNumber = [response substringWithRange:NSMakeRange(4, 4)];
                        NSLog(@"\nStorageNumber: %@\n", storageNumber);
                    }
                    
                    if ([responseType isEqualToString:@"50"]){//device turn off
                        NSLog(@"\nTurning Off Device\n");
                    }
                }
            }
        }
    }
    
    @end
