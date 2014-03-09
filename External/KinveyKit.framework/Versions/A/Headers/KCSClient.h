//
//  KCSClient.h
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

#define MINIMUM_KCS_VERSION_SUPPORTED @"3.0"

@class UIApplication;
@class KCSUser;
@class KCSReachability;

#define KCS_FACEBOOK_APP_KEY @"facebookKey"
#define KCS_TWITTER_CLIENT_KEY @"twitterKey"
#define KCS_TWITTER_CLIENT_SECRET @"twitterSecret"
#define KCS_LINKEDIN_API_KEY @"linkedinKey"
#define KCS_LINKEDIN_SECRET_KEY @"linkedinSecret"
#define KCS_LINKEDIN_ACCEPT_REDIRECT @"linkedinAcceptRedirect"
#define KCS_LINKEDIN_CANCEL_REDIRECT @"linkedinCancelRedirect"
#define KCS_SALESFORCE_IDENTITY_URL @"id"
#define KCS_SALESFORCE_REFRESH_TOKEN @"refresh_token"
#define KCS_SALESFORCE_CLIENT_ID @"client_id"

/** Notification for when a network operation starts 
 @since 1.26.0
 */
KCS_CONSTANT KCSNetworkConnectionDidStart;
/** Notification for when a network operation ends 
 @since 1.26.0
 */
KCS_CONSTANT KCSNetworkConnectionDidEnd;

@class KCSClientConfiguration;

/*! A Singleton Class that provides access to all Kinvey Services.

 This class provides a single interface to most Kinvey services.  It provides access to User Servies, Collection services
 (needed to both fetch and save data), Resource Services and Push Services.
 
 @warning Note that this class is a singleton and the single method to get the instance is @see sharedClient.

 */
@interface KCSClient : NSObject

#pragma mark - Properties

///---------------------------------------------------------------------------------------
/// @name Application Information
///---------------------------------------------------------------------------------------
/*! Kinvey provided App Key, set via @see initializeKinveyServiceForAppKey:withAppSecret:usingOptions */
@property (nonatomic, copy, readonly) NSString *appKey;

/*! Kinvey provided App Secret, set via @see initializeKinveyServiceForAppKey:withAppSecret:usingOptions */
@property (nonatomic, copy, readonly) NSString *appSecret;

/*! Configuration options, set via @see initializeKinveyServiceForAppKey:withAppSecret:usingOptions */
@property (nonatomic, strong, readonly) NSDictionary *options;

///---------------------------------------------------------------------------------------
/// @name Library Information
///---------------------------------------------------------------------------------------

/*! User Agent string returned to Kinvey (used automatically, provided for reference. 
 @deprecated no longer used
 @deprecatedIn 1.26.2
 */
@property (nonatomic, copy, readonly) NSString *userAgent KCS_DEPRECATED(no longer used in the client, 1.26.2);

/*! Library Version string returned to Kinvey (used automatically, provided for reference. */
@property (nonatomic, copy, readonly) NSString *libraryVersion;

///---------------------------------------------------------------------------------------
/// @name Kinvey Service URL Access
///---------------------------------------------------------------------------------------

/*! Kinvey Service Hostname 
 @deprecatedIn 1.20.0
 */
@property (nonatomic, readonly) NSString *serviceHostname KCS_DEPRECATED(@"set via KCSConfiguration", 1.20.0);

/*! Base URL for Kinvey data service */
@property (nonatomic, copy, readonly) NSString *appdataBaseURL;

/*! Base URL for Kinvey Resource Service */
@property (nonatomic, copy, readonly) NSString *resourceBaseURL;

/*! Base URL for Kinvey User Service */
@property (nonatomic, copy, readonly) NSString *userBaseURL;

/*! Connection Timeout value, set this to cause shorter or longer network timeouts. Set via configuration KCS_CONNECTION_TIMEOUT. */
@property (nonatomic, readonly) double connectionTimeout;

/*! Current Kinvey Cacheing policy 
 deprecatedIn 1.20.0
 */
@property (nonatomic, readonly) NSURLCacheStoragePolicy cachePolicy KCS_DEPRECATED(@"set via KCSConfiguration", 1.20.0);

/** The Configuration Options */
@property (nonatomic, retain) KCSClientConfiguration* configuration;

/*! Overall Network Status Reachability Object */
@property (nonatomic, strong, readonly) KCSReachability *networkReachability;

/*! Kinvey Host Specific Reachability Object */
@property (nonatomic, strong, readonly) KCSReachability *kinveyReachability;

///---------------------------------------------------------------------------------------
/// @name User Authentication
///---------------------------------------------------------------------------------------

/*! Current Kinvey User
 @deprecatedIn 1.19.0
 */
@property (nonatomic, strong) KCSUser *currentUser KCS_DEPRECATED(Use [KCSuser activeUser] instead, 1.19.0);

///---------------------------------------------------------------------------------------
/// @name Data Type Support
///---------------------------------------------------------------------------------------

/** NSDateFormatter String for Date storage. Set via configuration. */
@property (retain, nonatomic, readonly) NSString *dateStorageFormatString;



#pragma mark -
#pragma mark Initializers

// Singleton
///---------------------------------------------------------------------------------------
/// @name Accessing the Singleton
///---------------------------------------------------------------------------------------

/*! Return the instance of the singleton.  (NOTE: Thread Safe)
 
 This routine will give you access to all the Kinvey Services by returning the Singleton KCSClient that
 can be used for all client needs.
 
 @returns The instance of the singleton client.
 
 */
+ (instancetype)sharedClient;

///---------------------------------------------------------------------------------------
/// @name Initializing the Singleton
///---------------------------------------------------------------------------------------

/*! Initialize the singleton KCSClient with this application's key and the secret for this app, along with any needed options.
 
 This routine (or initializeKinveyServiceWithPropertyList) MUST be called prior to using the Kinvey Service otherwise all access will fail.  This routine authenticates you with
 the Kinvey Service.  The appKey and appSecret are available in the Kinvey Console.  Options can be used to configure push, etc.
 
 The options array supports the following Values (note that the values are followed by the NSStrings expected in the plist file if you're using
 plists for initialization):
 
 - KCS_APP_KEY_KEY @"kcsAppKey"  -- The app key obtained from the console
 - KCS_APP_SECRET_KEY @"kcsSecret" -- The app secret obtained from the console (not the master secret)
 - KCS_SERVICE_KEY @"kcsServiceKey" -- Not currently used
 - KCS_PUSH_KEY_KEY @"kcsPushKey" -- The PUSH Key obtained from the console
 - KCS_PUSH_SECRET_KEY @"kcsPushSecret" -- The PUSH Secret obtained from the console 
 - KCS_PUSH_IS_ENABLED_KEY @"kcsPushEnabled" -- YES if push is to be enabled, NO if push is not needed
 - KCS_PUSH_MODE_KEY @"kcsPushMode" -- , KCS_PUSH_DEBUG or KCS_PUSH_RELEASE the keys must match the mode
 - KCS_PUSH_DEBUG @"debug"
 - KCS_PUSH_RELEASE @"release"
 - KCS_USE_OLD_PING_STYLE_KEY @"kcsPingStyle" -- Enable old style push behavior, deprecated functionality

 
 @param appKey The Kinvey provided App Key used to identify this application
 @param appSecret The Kinvey provided App Secret used to authenticate this application.
 @param options The NSDictionary used to configure optional services.
 @return The KCSClient singleton (can be used to chain several calls)
 
 For example, KCSClient *client = [[KCSClient sharedClient] initializeKinveyServiceForAppKey:@"key" withAppSecret:@"secret" usingOptions:nil];
 
 */
- (instancetype)initializeKinveyServiceForAppKey: (NSString *)appKey withAppSecret: (NSString *)appSecret usingOptions: (NSDictionary *)options;

/*! Initialize the singleton KCSClient with a dictionary plist containing options to run
 
 This routine (or initializeKinveyServiceForAppKey:withAppSecret:usingOptions:) MUST be called prior to using the Kinvey Service
 otherwise all access will fail.  If the plist does not contain an App Key and an App Secret, then attempts to access the Kinvey
 service will fail.
 
 The plist MUST be loadable into an NSDictionary, the plist MUST be located in the root directory of the main bundle and MUST be named
 KinveyOptions.plist.
 
 @exception KinveyInitializationError Raised to indicate an issue loading the plist file, Kinvey Services will not be available.
 @return The KCSClient singleton (can be used to chain several calls)
 */
- (instancetype)initializeKinveyServiceWithPropertyList;


/** Initialize the singleton KCSClient with the supplied conifguration.
 
 @param configuration the app's configuration, including the app key and app secret
 @return The KCSClient singleton (can be used to chain several calls)
 @since 1.20.0
 */
- (void) initializeWithConfiguration:(KCSClientConfiguration*)configuration;


///---------------------------------------------------------------------------------------
/// @name Logging Control
///---------------------------------------------------------------------------------------
/*! Controls what internal data is reported while using the KinveyKit debug library
 
 When using the debugging build KinveyKit is configured to log debugging information.  This information
 may or may not be useful to you as a developer, so what is printed is configurable.
 
 The information logged is as follows:
 Network: Information regarding network information and RES actions
 Debug: Information used for internally debugging the Kinvey Library
 Trace: Tracing the execution of the Kinvey Library
 Warning: Warning statements about issues detected by the library
 Error: Errors detected by the Kinvey Library
 
 Warnings and Errors are presented to a developer using NSErrors for issues that can be fixed or where
 execution can continue and exceptions where execution cannot.  The logged information is extra and is
 not required for correct operation or handling of errors.
 
 This method allows you to specify which data you are interested in viewing.  You must explicitly enable
 information you wish to see
 
 @warning No extra logged information is available in the release version of the library.
 @warning By default all debugging information is turned off.
 
 @param networkIsEnabled Set to YES if you want to see network debugging information.
 @param debugIsEnabled Set to YES if you want to see debugging information.
 @param traceIsEnabled Set to YES if you want to see tracing information
 @param warningIsEnabled Set to YES if you want to see warning information.
 @param errorIsEnabled Set to YES if you want to see error information.
 
 
 */
+ (void)configureLoggingWithNetworkEnabled: (BOOL)networkIsEnabled
                              debugEnabled: (BOOL)debugIsEnabled
                              traceEnabled: (BOOL)traceIsEnabled
                            warningEnabled: (BOOL)warningIsEnabled
                              errorEnabled: (BOOL)errorIsEnabled;


///---------------------------------------------------------------------------------------
/// @name Utilities
///---------------------------------------------------------------------------------------

/** Clears out all the caches maintained by the library.
 
 Right now the only caches used are those created by `KCSCachedStore` to cache app data. 
 */
- (void) clearCache;

///---------------------------------------------------------------------------------------
/// @name Data Protection
///---------------------------------------------------------------------------------------

/** Helper method to preform data protection activities when the device is unlocked. 
 
 This __MUST__ be forwarded from your application delegate.
 
 @param application The singleton app object.
 @see applicationProtectedDataWillBecomeUnavailable:
 @since 1.24.0
 */
- (void)applicationProtectedDataDidBecomeAvailable:(UIApplication *)application;

/** Helper method to preform data protection activities when the device is locked.
 
 This __MUST__ be forwarded from your application delegate.
 
 @param application The singleton app object.
 @see applicationProtectedDataDidBecomeAvailable:
 @since 1.24.0
 */
- (void)applicationProtectedDataWillBecomeUnavailable:(UIApplication *)application;

@end
