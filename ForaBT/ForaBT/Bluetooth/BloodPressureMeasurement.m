//
//  BloodPressureMeasurement.m
//  MyHealthApp
//
//  Created by Jonathan on 12/17/15.
//  Copyright © 2015 MUSC. All rights reserved.
//

#import "BloodPressureMeasurement.h"

@implementation BloodPressureMeasurement

- (instancetype)init
{
    self = [super init];
    
    if (self != nil) {
        self.readingDate = [NSDate date];
    }
    
    return self;
}

- (instancetype)initWithSystolic:(int)systolic diastolic:(int)diastolic map:(int)map pulse:(int)pulse
{
    self = [super init];
    
    if (self != nil) {
        self.bloodPressureId = 0;
        self.systolic = @(systolic);
        self.diastolic = @(diastolic);
        self.map = @(map);
        self.pulse = @(pulse);
        self.readingDate = [NSDate date];
    }
    
    return self;
}

@end
