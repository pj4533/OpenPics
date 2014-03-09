//
//  KinveyPing.h
//  KinveyKit
//
//  Copyright (c) 2008-2014, Kinvey, Inc. All rights reserved.
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
#import "KinveyHeaderInfo.h"

/*! Result returned from the Ping operation.
 
 The response from "pinging" Kinvey.
 
 */
@interface KCSPingResult : NSObject

///---------------------------------------------------------------------------------------
/// @name Obtaining Information
///---------------------------------------------------------------------------------------
/*! The description returned by the ping, can be error information, or a success message, the results are not meant to be shown to an end-user in a production application. */
@property (readonly, nonatomic) NSString *description;
/*! The result of the ping, YES if a round-trip request went from the device to Kinvey and back to the device.  NO otherwise. */
@property (readonly, nonatomic) BOOL pingWasSuccessful;

///---------------------------------------------------------------------------------------
/// @name Initialization & disposal
///---------------------------------------------------------------------------------------
/*! Create a Ping Response
 
 This is the designated initializer for Ping Responses.  The description can be anything, but should be releated to the result,
 but result must be NO unless a roundtrip request completed successfully.
 @param description The description of the result
 @param result YES if a complete roundtrip request was successful, NO otherwise.
 @return The KCSPingResult object.
 */
- (instancetype)initWithDescription: (NSString *)description withResult: (BOOL)result;

@end

/*! Callback upon ping request finishing
 
 This block is used as a callback by the Ping service and is called on both success and failure.  The block is responsible for checking
 the KCSPingResult pingWasSuccessful property to determine success or failure.
 */
typedef void(^KCSPingBlock)(KCSPingResult *result);


/*! Ping Services
 
 Helper class to perform roundtrip pings to the Kinvey Service.
 
 */
@interface KCSPing : NSObject

///---------------------------------------------------------------------------------------
/// @name Pinging the Kinvey Service
///---------------------------------------------------------------------------------------
/*! Ping Kinvey and perform a callback when complete.
 
 This method makes a request on Kinvey and uses the callback to indicate the completion, if you
 wish to check to see if the Kinvey Service is alive and responding, please use checkKinveyServiceStatusWithAction:
 
 @warning The results passed to completionAction have changed, to get the old style, initialzie Kinvey
 with the KCS_USE_OLD_PING_STYLE_KEY (or, if you're using a plist, "kcsPingStyle") key set to YES in your options.
 @param completionAction The callback to perform on completion.
 */
+ (void)pingKinveyWithBlock:(KCSPingBlock)completionAction;


@end
