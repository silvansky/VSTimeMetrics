//
//  VSReadWriteLock.m
//
//  Created by Valentine Silvansky on 31.05.13.
//  Copyright (c) 2013 Valentine Silvansky. All rights reserved.
//
// Based on code of CHReadWriteLock from http://cocoaheads.byu.edu/wiki/locks

#import "VSReadWriteLock.h"
#import <pthread.h>

@interface VSReadWriteLock ()
{
	pthread_rwlock_t _lock;
}

@end

@implementation VSReadWriteLock

- (id)init
{
	if (self = [super init])
	{
		pthread_rwlock_init(&_lock, NULL);
	}
	return self;
}

- (void)dealloc
{
	pthread_rwlock_destroy(&_lock);
	[super dealloc];
}

- (void)finalize
{
	pthread_rwlock_destroy(&_lock);
	[super finalize];
}

- (void)lock
{
	pthread_rwlock_rdlock(&_lock);
}

- (void)unlock
{
	pthread_rwlock_unlock(&_lock);
}

- (void)lockForWriting
{
	pthread_rwlock_wrlock(&_lock);
}

- (BOOL)tryLock
{
	return (pthread_rwlock_tryrdlock(&_lock) == 0);
}

- (BOOL)tryLockForWriting
{
	return (pthread_rwlock_trywrlock(&_lock) == 0);
}

@end