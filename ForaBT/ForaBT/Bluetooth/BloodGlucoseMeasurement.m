//
//  BloodGlucoseMeasurement.m
//  MyHealthApp
//
//  Created by Jonathan on 1/15/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import "BloodGlucoseMeasurement.h"

@implementation BloodGlucoseMeasurement
    
- (instancetype)init
{
    self = [super init];
    
    if (self != nil) {
        self.readingDate = [NSDate date];
    }
    
    return self;
}

- (instancetype)initWithGlucoseLevel:(int)glucoseLevel
{
    self = [super init];
    
    if (self != nil) {
        self.bloodGlucoseId = 0;
        self.glucoseLevel = @(glucoseLevel);
        self.readingDate = [NSDate date];
    }
    
    return self;
}

@end
