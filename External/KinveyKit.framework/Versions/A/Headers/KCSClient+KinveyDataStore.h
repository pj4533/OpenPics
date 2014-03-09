//
//  KCSClient+KinveyDataStore.h
//  KinveyKit
//
//  Copyright (c) 2013 Kinvey. All rights reserved.
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

#import <Foundation/Foundation.h>
#import "KCSClient.h"
#import "KinveyHeaderInfo.h"

/** If an error is returned from [KCSStore saveObject:withCompletionBlock:withProgressBlock], the error's `userInfo` will contain an array of the ids for the objects not saved. `NSNull`s will be used for objects that have not had their ids set yet. */
KCS_CONSTANT KCS_ERROR_UNSAVED_OBJECT_IDS_KEY;

@protocol KCSOfflineUpdateDelegate;

@interface KCSClient (KinveyDataStore)

- (void) setOfflineDelegate:(id<KCSOfflineUpdateDelegate>)delegate;

@end
