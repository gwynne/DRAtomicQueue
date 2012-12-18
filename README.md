DRAtomicQueue
=============

A thread-safe FIFO queue for Objective-C. I had intended to build it on OSFIFOQueue, but that doesn't exist for iOS. Then I was gonna implement my own, but lockless queues aren't really possible without a true DCAS instruction, which also doesn't exist. As a result, this is just a somewhat lame wrapper around `NSMutableArray` and `libdispatch`. It is cool and supports everything, though.

