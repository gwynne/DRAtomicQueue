//
//  DRAtomicQueue.h
//  MailChat
//
//  Created by Gwynne Raskind on 12/18/12.
//  Copyright (c) 2012 Dark Rainfall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <libkern/OSAtomic.h>

// DRAtomicQueue is ARC-compatible and retains its objects. Queues are always
//	mutable. DRAtomicQueue requires OS X 10.7 or later, or iOS 5 or later. No
//	guarantees are made about speed.

// Copying a queue is atomic with respect to the state of the queue at the time
//	of the call to -copy (i.e., a snapshot of the queue state is taken). Copying
//	is a slow operation and may block other threads using the queue.

// Serializing a queue is atomic with respect to the state of the queue at the
//	time of the call to -encodeWithCoder (i.e., a snapshot of the queue state is
//	taken). Serialization invokes -copy and comes with all the caveats thereto.
//	For a queue to be successfully serialized, all objects in the queue must
//	also be serializable. The queue supports only keyed coders and will throw an
//	exception if given a non-keyed coder.

@interface DRAtomicQueue : NSObject <NSCopying,
#if ((!defined(__IPHONE_OS_VERSION_MIN_REQUIRED) && __MAC_OS_X_VERSION_MIN_REQUIRED >= 1080) || __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000)
									 NSSecureCoding
#else
									 NSCoding
#endif
									>

- (void)push:(id)object;
- (id)pop;
- (void)unPop:(id)object;

@end
