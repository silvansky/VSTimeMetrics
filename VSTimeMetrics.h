//
//  VSTimeMetrics.h
//
//  Created by Valentine Silvansky on 31.05.13.
//  Copyright (c) 2013 Valentine Silvansky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VSTimeMetrics : NSObject

+ (VSTimeMetrics *)sharedInstance;

- (void)startMeasuringForKey:(NSString *)key;
- (void)finishMeasuringForKey:(NSString *)key;
- (void)resetMeasuringForKey:(NSString *)key;
- (void)resetAllMeasurements;

- (NSTimeInterval)lastMeasurementForKey:(NSString *)key;
- (NSTimeInterval)totalMeasurementForKey:(NSString *)key;
- (NSTimeInterval)averageMeasurementForKey:(NSString *)key;

- (NSString *)measurementReport;

@end
