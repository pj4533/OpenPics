//
//  KCSDataStore.h
//  KinveyKit
//
//  Copyright (c) 2013-2014 Kinvey. All rights reserved.
//
// This software is licensed to you under the Kinvey terms of service located at
// http://www.kinvey.com/terms-of-use. By downloading, accessing and/or using this
// software, you hereby accept such terms of service  (and any agreement referenced
// therein) and agree that you have read, understand and agree to be bound by such
// terms of service and are of legal age to agree to such terms with Kinvey.
//
// This software contains valuable confidential and proprietary information of
// KINVEY, INC and is subject to applicable licensing agreements.
// Unauthorized reproduction, transmission or distribution of this file and its
// contents is a violation of applicable laws.
//

#import "KinveyDataStore.h"

typedef void(^KCSDataStoreCompletion)(NSArray* objects, NSError* error);
typedef void(^KCSDataStoreCountCompletion)(NSUInteger count, NSError* error);

@class KCSQuery2;
@protocol KCSNetworkOperation;

@interface KCSDataStore : NSObject

- (instancetype)initWithCollection:(NSString*)collection;

- (void) getAll:(KCSDataStoreCompletion)completion;
- (void) countAll:(KCSDataStoreCountCompletion)completion;

- (void) query:(KCSQuery2*)query options:(NSDictionary*)options completion:(KCSDataStoreCompletion)completion; //todo return response object
- (void) countQuery:(KCSQuery2*)query completion:(KCSDataStoreCountCompletion)completion;

//TODO: KK2(base methods should be void, advanced should have the op return)
- (id<KCSNetworkOperation>) deleteEntity:(NSString*)_id completion:(KCSDataStoreCountCompletion)completion;
- (id<KCSNetworkOperation>) deleteByQuery:(KCSQuery2*)query completion:(KCSDataStoreCountCompletion)completion;

@end
