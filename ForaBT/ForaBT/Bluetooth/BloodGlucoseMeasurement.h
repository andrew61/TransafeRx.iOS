//
//  BloodGlucoseMeasurement.h
//  MyHealthApp
//
//  Created by Jonathan on 1/15/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BloodGlucoseMeasurement : NSObject

@property (strong, nonatomic) NSNumber *bloodGlucoseId;
@property (strong, nonatomic) NSNumber *glucoseLevel;
@property (strong, nonatomic) NSDate *readingDate;

- (instancetype)initWithGlucoseLevel:(int)glucoseLevel;

@end
