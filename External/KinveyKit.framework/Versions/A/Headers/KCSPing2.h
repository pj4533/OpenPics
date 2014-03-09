//
//  KCSPing2.h
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
#import "KinveyCore.h"

KCS_CONSTANT KCS_PING_KINVEY_VERSION;
KCS_CONSTANT KCS_PING_APP_NAME;

/* Callback upon ping request finishing
 
 This block is used as a callback by the Ping service and is called on both success and failure.  The block is responsible for checking
 the KCSPingResult pingWasSuccessful property to determine success or failure.
 */
typedef void(^KCSPingBlock2)(NSDictionary* appInfo, NSError* error);


@interface KCSPing2 : NSObject

/* Ping Kinvey and perform a callback when complete.
 
 @param completionAction The callback to perform on completion.
 */
+ (void)pingKinveyWithBlock:(KCSPingBlock2)completion;

@end
