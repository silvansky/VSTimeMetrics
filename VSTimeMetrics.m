//
//  VSTimeMetrics.m
//  imosx
//
//  Created by Valentine Silvansky on 31.05.13.
//  Copyright (c) 2013 Valentine Silvansky. All rights reserved.
//

#import "VSTimeMetrics.h"

@interface VSTimeMetrics ()

@end

@implementation VSTimeMetrics

+ (VSTimeMetrics *)sharedInstance
{
	static VSTimeMetrics *_instance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_instance = [[VSTimeMetrics alloc] init];
	});
	return _instance;
}

- (void)startMeasuringForKey:(NSString *)key
{

}

- (void)addMeasuringForKey:(NSString *)key
{

}

- (NSTimeInterval)lastMeasurementForKey:(NSString *)key
{

}

- (NSTimeInterval)totalMeasurementForKey:(NSString *)key
{

}

- (NSTimeInterval)averageMeasurementForKey:(NSString *)key
{
	
}


@end
