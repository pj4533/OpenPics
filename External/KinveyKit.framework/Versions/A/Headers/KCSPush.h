//
//  KCSPush.h
//  KinveyKit
//
//  Copyright (c) 2008-2012, Kinvey, Inc. All rights reserved.
//
//  This software contains valuable confidential and proprietary information of
//  KINVEY, INC and is subject to applicable licensing agreements.
//  Unauthorized reproduction, transmission or distribution of this file and its
//  contents is a violation of applicable laws.

#ifndef NO_URBAN_AIRSHIP_PUSH

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

/*! Push Service (APNS) Helper Container

 This Singleton is used as a collection of all items related to the Push Service offered by Kinvey.
 
 */
@interface KCSPush : NSObject

#pragma mark push notifications

///---------------------------------------------------------------------------------------
/// @name Initialization & disposal
///---------------------------------------------------------------------------------------
/*! Return the single shared instance of the Push Notification Service
 
 This routine returns the shared Push Service object, creating it if required.  This should be used
 to gain access to all push methods.
 
 @return The shared Push Service object.
 */
+ (KCSPush *)sharedPush;

///---------------------------------------------------------------------------------------
/// @name Startup / Shutdown
///---------------------------------------------------------------------------------------
/*! Start the Push Service
 
 This routine is used to register with the Kinvey Push service (not the same as registering with APNS)
 and to prepare to receive notifications.  This handles device management and user management.
 
 To use this routine, place a call to this in the applicationDidLoad:withOptions method in the App Delegate.
 `[[KCSPush sharedPush] onLoadHelper:options];`
 
 Where options (documented in KCSClient) contains the Keys for the Push service.
 
 @warning Push notifications will not work if this method has not been called.
 
 @param options The options dictionary (see KCSClient) that contains the settings for the push service.
 @deprecated Use onLoadHelper:error: instead.
 @depcratedIn 1.9
 */
- (void)onLoadHelper: (NSDictionary *)options __attribute__((deprecated("use onLoadHelper:error: instead")));

/*! Start the Push Service
 
 This routine is used to register with the Kinvey Push service (not the same as registering with APNS)
 and to prepare to receive notifications.  This handles device management and user management.
 
 To use this routine, place a call to this in the applicationDidLoad:withOptions method in the App Delegate.
 `[[KCSPush sharedPush] onLoadHelper:options error:error];`
 
 Where options (documented in KCSClient) contains the Keys for the Push service.
 
 @warning Push notifications will not work if this method has not been called.
 
 @param options The options dictionary (see KCSClient) that contains the settings for the push service.
 @param error The error if this method fails
 @return `NO` if the push notifications are not able to be set-up correctly. Check the out error for possible reasons.
 @since 1.9
 */
- (BOOL) onLoadHelper:(NSDictionary *)options error:(NSError**)error;

/*! Clean-up Push Service
 
 This routine is used to clean-up the push service prior to application termination.  This will perform some basic clean-up and will be used to
 help generate accurate analytics.
 
 This method should be called in the applicationWillTerminate: method of the App Delegate class
 `[[KCSPush sharedPush] onUnloadHelper];`
 
 @warning Calling this on application will terminate *does not* prevent Push Notifications from being received by devices, the push notifications will still be received.
 */
- (void)onUnloadHelper;

///---------------------------------------------------------------------------------------
/// @name Receiving Notifications
///---------------------------------------------------------------------------------------

/*! Do library specific remote notification processing
 
 The Kinvey library requires the remote notification to be forwarded this Push Service to provide convienience functions and management,
 this method allows us to obtain all necessary information.
 
 Call this in your implementation for handling remote notifications:
 
    - (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
        [[KCSPush sharedPush] application:application didReceiveRemoteNotification:userInfo];
        // Additional push notification handling code should be performed here
    }
 
 @param application The application sending this message.
 @param userInfo The userInfo dictionary provided by the application.
 */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;

///---------------------------------------------------------------------------------------
/// @name Registering for Notifications
///---------------------------------------------------------------------------------------
/*! Register device for remote notifications
 
 The Kinvey library requires information from the registration of remote notifications to perform several tasks.
 This information needs to be forwarded to the library when received by the App Delegate.
 
 Call this in your implementation for handling registration:

    - (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
        [[KCSPush sharedPush] application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
        // Additional registration goes here (if neeeded).
    }

 
 @param application The application sending this message.
 @param deviceToken The device token of the device this instance of the application is running on.
 */
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;

///---------------------------------------------------------------------------------------
/// @name Badge Management
///---------------------------------------------------------------------------------------
/*! Set the number of unread push notifications on the app badge
 
 Reset the number of waiting push notifications on for the app's badge.
 This is a wrapper around the UrbanAirship feature.
 
 @param number The number to set the badge to
 
 */
- (void)setPushBadgeNumber: (int)number;

/*! Reset the app's unread pushes to 0
 
 Reset the push count
 
 */
- (void)resetPushBadge;

// - (void) exposeSettingsViewInView: (UIViewController *)parentViewController


- (void) removeDeviceToken;

@end

#endif /* NO_URBAN_AIRSHIP_PUSH */

