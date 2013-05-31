//
//  VSReadWriteLock.h
//
//  Created by Valentine Silvansky on 31.05.13.
//  Copyright (c) 2013 Valentine Silvansky. All rights reserved.
//
// Based on code of CHReadWriteLock from http://cocoaheads.byu.edu/wiki/locks

#import <Foundation/Foundation.h>

@interface VSReadWriteLock : NSObject <NSLocking>

- (void)lockForWriting;
- (BOOL)tryLock;
- (BOOL)tryLockForWriting;

@end