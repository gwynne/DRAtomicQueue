//
//  DRAtomicQueue.m
//  MailChat
//
//  Created by Gwynne Raskind on 12/18/12.
//  Copyright (c) 2012 Dark Rainfall. All rights reserved.
//

#import "DRAtomicQueue.h"

@implementation DRAtomicQueue
{
	NSMutableArray *_container;
	dispatch_queue_t _queueQueue;
}

// Don't need #ifdef for this, the method is harmless on 10.7
+ (BOOL)supportsSecureCoding
{
	return YES;
}

- (instancetype)init
{
	if ((self = [super init]))
	{
		_container = [[NSMutableArray alloc] init];
		_queueQueue = dispatch_queue_create("org.darkrainfall.atomic-queue.queue", DISPATCH_QUEUE_SERIAL);
	}
	return self;
}

- (void)push:(id)object
{
	dispatch_async(_queueQueue, ^ { [_container addObject:object]; });
}

- (id)pop
{
	__block id result = nil;
	
	dispatch_sync(_queueQueue, ^ { result = _container[0]; [_container removeObjectAtIndex:0]; });
	return result;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [self init]))
	{
#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 60000 || (!__IPHONE_OS_VERSION_MIN_REQUIRED && __MAC_OS_X_VERSION_MIN_REQUIRED >= 1080))
		_container = [[aDecoder decodeObjectOfClass:[NSArray class] forKey:@"container"] mutableCopy];
#else
		_container = [[aDecoder decodeObjectForKey:@"container"];
#endif
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	dispatch_sync(_queueQueue, ^ { [aCoder encodeObject:_container.copy forKey:@"container"]; });
}

- (instancetype)copyWithZone:(NSZone *)zone
{
	DRAtomicQueue *queue = [[[self class] alloc] init];
	
	dispatch_sync(_queueQueue, ^ { queue->_container = _container.mutableCopy; });
	return queue;
}

@end
