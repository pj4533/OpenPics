//
//  KinveyPing.h
//  KinveyKit
//
//  Copyright (c) 2008-2011, Kinvey, Inc. All rights reserved.
//
//  This software contains valuable confidential and proprietary information of
//  KINVEY, INC and is subject to applicable licensing agreements.
//  Unauthorized reproduction, transmission or distribution of this file and its
//  contents is a violation of applicable laws.

#import <Foundation/Foundation.h>

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
- (id)initWithDescription: (NSString *)description withResult: (BOOL)result;

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
/// @name Network Reachability
///---------------------------------------------------------------------------------------

/*! Verify the device will be able to access a network
 
 This method returns true if the device will be able to make network requests.  This checks
 to make sure that the device is not in Airplane mode, has the radios turned on, has a WiFi
 connection, etc.  It does not check to see if we can communicate with Kinvey, only that
 a network connection is possible.
 
 @warning This method *DOES NOT* verify that the Kinvey Service is active, only that a network request will leave the phone.
 @return YES if the network is reachable, NO if the network is not reachable.
 */
+ (BOOL)networkIsReachable;

/*! Verify the device will be able to access a network, and that the Kinvey service is a known address
 
 This method returns true if the device will be able to make network requests, and if the network
 knows how to find the Kinvey Service. This checks to make sure that the device is not in Airplane mode,
 has the radios turned on, has a WiFi connection, etc.  It also checks that we can resolve the Kinvey
 service.  It does not check to see if we can communicate with Kinvey, only that
 a network connection is possible.
 
 @warning This method *DOES NOT* verify that the Kinvey Service is active, only that a network request will leave the phone
 and be sent to Kinvey.
 @return YES if the network is reachable and Kinvey is known, NO if the network is not reachable or Kinvey is not known.
 */
+ (BOOL)kinveyServiceIsReachable;


/*! Verify the Kinvey Service is active

 This method checks to see if the Kinvey service is available and accepting requests.  The callback is called
 with the results of the status check.

 @param completionAction The callback to perform on completion.
 */
+ (void)checkKinveyServiceStatusWithAction:(KCSPingBlock)completionAction;

///---------------------------------------------------------------------------------------
/// @name Pinging the Kinvey Service
///---------------------------------------------------------------------------------------
/*! Ping Kinvey and perform a callback when complete.
 
 This method makes a request on Kinvey and uses the callback to indicate the completion, if you
 wish to check to see if the Kinvey Service is alive and responding, please use checkKinveyServiceStatusWithAction:
 
 @warning This request is authenticated, so indirectly verifies *all* steps that are required to talk to the Kinvey Service.
 @warning The results passed to completionAction have changed, to get the old style, initialzie Kinvey
 with the KCS_USE_OLD_PING_STYLE_KEY (or, if you're using a plist, "kcsPingStyle") key set to YES in your options.
 @param completionAction The callback to perform on completion.
 */
+ (void)pingKinveyWithBlock:(KCSPingBlock)completionAction;


@end
