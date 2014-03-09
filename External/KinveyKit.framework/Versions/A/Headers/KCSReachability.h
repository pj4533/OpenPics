// KCSReachability.h
// KinveyKit
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

#import "KinveyHeaderInfo.h"

/** Notification for kinvey reachability changes */
KCS_CONSTANT KCSReachabilityChangedNotification;

/** Reachability helper object. Use to test for existence of connection or changes in connectivity. Note that a `YES` isReachable doesn't necessarily mean that the conncetion will succeed, just that it is possible. */
@interface KCSReachability: NSObject

/** Use to check the reachability to the network */
+ (instancetype) reachabilityForInternetConnection;

/** Use to check the reachability of a particular host name. */
+ (instancetype) reachabilityWithHostName:(NSString*)hostName;


/** The main direct test of reachability.
 
 Always true before reachability is initialized (async).
 @return `YES` if a network connection is available.
 */
- (BOOL) isReachable;

/** Test if the connection is cellular 
 @return `YES` if 3G, EDGE, LTE etc
 */
- (BOOL) isReachableViaWWAN;

/** Test if connection is wifi. 
 @return `YES` if connection is wifi.
 */
- (BOOL) isReachableViaWiFi;
@end
