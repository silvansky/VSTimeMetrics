//
//  VSTimeMetrics.m
//
//  Created by Valentine Silvansky on 31.05.13.
//  Copyright (c) 2013 Valentine Silvansky. All rights reserved.
//

#import "VSTimeMetrics.h"
#import "VSReadWriteLock.h"

#define RLOCK(key)  [[self lockForKey:key] lock]
#define WRLOCK(key) [[self lockForKey:key] lockForWriting]

#define UNLOCK(key) [[self lockForKey:key] unlock]

#define RLOCK_G  [self.globalLock lock]
#define WRLOCK_G [self.globalLock lockForWriting]
#define UNLOCK_G [self.globalLock unlock]

#pragma mark - VSDatePair

@interface VSDatePair : NSObject

@property (nonatomic, retain) NSDate *start;
@property (nonatomic, retain) NSDate *finish;

- (id)initWithStart:(NSDate *)start finish:(NSDate *)finish;

@end

@implementation VSDatePair

- (void)dealloc
{
	self.start = nil;
	self.finish = nil;
	[super dealloc];
}

- (id)initWithStart:(NSDate *)start finish:(NSDate *)finish
{
	self = [super init];
	if (self)
	{
		self.start = start;
		self.finish = finish;
	}
	return self;
}

- (NSTimeInterval)interval
{
	if (self.finish && self.start)
	{
		return [self.finish timeIntervalSinceDate:self.start];
	}
	return 0.f;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@ { start: %@, finish: %@ }", [super description], self.start, self.finish];
}

@end

#pragma mark - VSTimeMetrics

@interface VSTimeMetrics ()

// NSString key -> NSMutableArray of VSDatePair
@property (nonatomic, retain) NSMutableDictionary *measurements;
// NSString key -> NSObject lock
@property (nonatomic, retain) NSMutableDictionary *measurementsLocks;

@property (nonatomic, retain) VSReadWriteLock *globalLock;
@property (nonatomic, retain) VSReadWriteLock *locksLock;

- (NSMutableArray *)arrayForKey:(NSString *)key;
- (VSReadWriteLock *)lockForKey:(NSString *)key;

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

- (id)init
{
	self = [super init];
	if (self)
	{
		self.measurements = [NSMutableDictionary dictionary];
		self.measurementsLocks = [NSMutableDictionary dictionary];
		self.globalLock = [[[VSReadWriteLock alloc] init] autorelease];
		self.locksLock = [[[VSReadWriteLock alloc] init] autorelease];
	}
	return self;
}

- (void)dealloc
{
	WRLOCK_G;
	self.measurements = nil;
	self.measurementsLocks = nil;
	UNLOCK_G;
	self.globalLock = nil;
	self.locksLock = nil;
	[super dealloc];
}

- (void)startMeasuringForKey:(NSString *)key
{
	NSDate *startTime = [NSDate date];
	WRLOCK_G;
	NSMutableArray *array = [[[self arrayForKey:key] retain] autorelease];
	UNLOCK_G;
	WRLOCK(key);
	VSDatePair *pair = [[[VSDatePair alloc] initWithStart:startTime finish:nil] autorelease];
	[array addObject:pair];
	UNLOCK(key);
}

- (void)finishMeasuringForKey:(NSString *)key
{
	NSDate *finishTime = [NSDate date];
	RLOCK_G;
	NSMutableArray *array = [[self.measurements[key] retain] autorelease];
	UNLOCK_G;
	if (!array)
	{
		return;
	}
	WRLOCK(key);
	for (VSDatePair *pair in array)
	{
		if (!pair.finish)
		{
			pair.finish = finishTime;
			break;
		}
	}
	UNLOCK(key);
}

- (void)resetMeasuringForKey:(NSString *)key
{
	RLOCK_G;
	NSMutableArray *array = [[self.measurements[key] retain] autorelease];
	UNLOCK_G;
	if (!array)
	{
		return;
	}
	WRLOCK(key);
	[array removeAllObjects];
	UNLOCK(key);
}

- (void)resetAllMeasurements
{
	RLOCK_G;
	NSArray *keys = [self.measurements allKeys];
	UNLOCK_G;
	for (NSString *key in keys)
	{
		[self resetMeasuringForKey:key];
	}
}

- (NSTimeInterval)lastMeasurementForKey:(NSString *)key
{
	RLOCK_G;
	NSMutableArray *array = [[self.measurements[key] retain] autorelease];
	UNLOCK_G;
	if (!array)
	{
		return 0.f;
	}
	RLOCK(key);
	VSDatePair *pair = [array lastObject];
	NSTimeInterval interval = 0.;
	if (pair)
	{
		interval = [pair interval];
	}
	UNLOCK(key);
	return interval;
}

- (NSTimeInterval)totalMeasurementForKey:(NSString *)key
{
	RLOCK_G;
	NSMutableArray *array = [[self.measurements[key] retain] autorelease];
	UNLOCK_G;
	if (!array)
	{
		return 0.f;
	}
	RLOCK(key);
	NSTimeInterval interval = 0.;
	for (VSDatePair *pair in array)
	{
		interval += [pair interval];
	}
	UNLOCK(key);
	return interval;
}

- (NSTimeInterval)averageMeasurementForKey:(NSString *)key
{
	RLOCK_G;
	NSMutableArray *array = [[self.measurements[key] retain] autorelease];
	UNLOCK_G;
	if (!array)
	{
		return 0.f;
	}
	RLOCK(key);
	NSTimeInterval interval = 0.;
	for (VSDatePair *pair in array)
	{
		interval += [pair interval];
	}
	NSInteger count = [array count];
	UNLOCK(key);
	return interval / count;
}

- (NSString *)measurementReport
{
	RLOCK_G;
	NSDictionary *dict = self.measurements;
	NSMutableString *result = [NSMutableString stringWithFormat:@"VSTimeMetrics report\n---\n\n"];
	NSArray *keys = [dict allKeys];
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
	[formatter setDateFormat:@"YYYY:MM:dd-HH:mm:ss.SSS"];
	for (NSString *key in keys)
	{
		NSMutableString *reportForKey = [NSMutableString stringWithFormat:@"KEY %@:\n\n", key];
		NSArray *array = dict[key];
		NSTimeInterval total = 0.;
		for (NSInteger i = 0; i < [array count]; i++)
		{
			VSDatePair *pair = array[i];
			NSTimeInterval interval = [pair interval];
			total += interval;
			NSString *start = pair.start ? [formatter stringFromDate:pair.start] : @"(null)";
			NSString *finish = pair.finish ? [formatter stringFromDate:pair.finish] : @"(null)";
			NSString *s = [NSString stringWithFormat:@"%ld: start %@, finish %@, time %f\n", i, start, finish, interval];
			[reportForKey appendString:s];
		}
		[result appendFormat:@"%@\n\ntotal: %f\naverage: %f\n\n", reportForKey, total, total / [array count]];
	}
	UNLOCK_G;
	return result;
}

#pragma mark - Private

- (NSMutableArray *)arrayForKey:(NSString *)key
{
	NSMutableArray *array = self.measurements[key];
	if (!array)
	{
		array = [NSMutableArray array];
		self.measurements[key] = array;
	}
	return array;
}

- (VSReadWriteLock *)lockForKey:(NSString *)key
{
	[self.locksLock lock];
	id lock = self.measurementsLocks[key];
	[self.locksLock unlock];
	if (!lock)
	{
		lock = [[VSReadWriteLock new] autorelease];
		[self.locksLock lockForWriting];
		self.measurementsLocks[key] = lock;
		[self.locksLock unlock];
	}
	return lock;
}

@end
