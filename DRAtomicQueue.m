//
//  DRAtomicQueue.m
//  MailChat
//
//  Created by Gwynne Raskind on 12/18/12.
//  Copyright (c) 2012 Dark Rainfall. All rights reserved.
//

#import "DRAtomicQueue.h"
#import <objc/runtime.h>

// Shut up the compiler warning on 10.7/iOS 5 SDK
#if !((!defined(__IPHONE_OS_VERSION_MIN_REQUIRED) && __MAC_OS_X_VERSION_MIN_REQUIRED >= 1080) || (__IPHONE_OS_VERSION_MIN_REQUIRED >= 60000))
@interface NSCoder (SecureCodingMethodDeclaration)
- (id)decodeObjectOfClass:(Class)c forKey:(NSString *)k;
@end
#endif

static BOOL DRAtomicQueue_NSCoderHasSecureCoding = NO;

@implementation DRAtomicQueue
{
	NSMutableArray *_container;
	dispatch_queue_t _queueQueue;
}

+ (void)initialize
{
	if ([DRAtomicQueue class] == [self class])
	{
		DRAtomicQueue_NSCoderHasSecureCoding = [NSCoder instancesRespondToSelector:@selector(decodeObjectOfClass:forKey:)] &&
												objc_getProtocol("NSSecureCoding") != NULL;
	}
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
	dispatch_sync(_queueQueue, ^ { [_container addObject:object]; });
}

- (id)pop
{
	__block id result = nil;
	
	dispatch_sync(_queueQueue, ^ { if (_container.count) { result = _container[0]; [_container removeObjectAtIndex:0]; } });
	return result;
}

- (void)unPop:(id)object
{
	dispatch_sync(_queueQueue, ^ { [_container insertObject:object atIndex:0]; });
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [self init]))
	{
		if (DRAtomicQueue_NSCoderHasSecureCoding)
			_container = [[aDecoder decodeObjectOfClass:[NSArray class] forKey:@"container"] mutableCopy];
		else
			_container = [[aDecoder decodeObjectForKey:@"container"] mutableCopy];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	__block NSArray *containerCopy = nil;
	
	dispatch_sync(_queueQueue, ^ { containerCopy = _container.copy; });
	[aCoder encodeObject:containerCopy forKey:@"container"];
}

- (instancetype)copyWithZone:(NSZone *)zone
{
	DRAtomicQueue *queue = [[[self class] alloc] init];
	
	dispatch_sync(_queueQueue, ^ { queue->_container = _container.mutableCopy; });
	return queue;
}

@end
