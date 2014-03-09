//
//  KCSClientConfiguration.h
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

#import "KinveyHeaderInfo.h"

// Keys for options hash
/** App Key plist key: "KCS_APP_KEY" */
KCS_CONSTANT KCS_APP_KEY;
/** App Secret plist key: "KCS_APP_SECRET" */
KCS_CONSTANT KCS_APP_SECRET;

/** Timeout plist key: "KCS_CONNECTION_TIMEOUT" */
KCS_CONSTANT KCS_CONNECTION_TIMEOUT;
/** NSNumber representation of NSURLCachePolicy */
KCS_CONSTANT KCS_URL_CACHE_POLICY;
/** Parsing format for dates handled by the system. ISO6801 format */
KCS_CONSTANT KCS_DATE_FORMAT;
/** This object shoul implement the `KCSLogSink` protocol. Use this along with +[KinveyKit configureLoggingWithNetworkEnabled:debugEnabled:traceEnabled:warningEnabled:errorEnabled:] to send log messages to a custom sink.*/
KCS_CONSTANT KCS_LOG_SINK;

// Data Protection
// See the Apple Data Protection guide in the iOS Programming Guide : Advanced App Tricks for more information

/** 
 @since 1.24.0
*/
typedef enum KCSDataProtectionLevel : NSInteger {
    KCSDataNoProtection, //no encryption
    KCSDataComplete, //data is inaccessible when device locked
    KCSDataCompleteUnlessOpen, //data is locked at first, but remains accessible while the file is open
    KCSDataCompleteUntilFirstLogin, //data is locked until the device has been unlocked once after boot
} KCSDataProtectionLevel;

/** Set this to a KCSDataProtectionLevel combined with data protection entitlements and the appropriate app delegate methods allows your app to lock files managed by the file store, offline caches, and keychain. 
 
    Default is KCSDataCompleteUntilFirstLogin.
 @since 1.24.0
 */
KCS_CONSTANT KCS_DATA_PROTECTION_LEVEL;

/**
 @since 1.25.0
 */
KCS_CONSTANT KCS_USER_CLASS;

/** Keep the user logged when the credentials become invalid.
 
 By default if the user credentials change outside of the apps flow, such that the active user is no longer authorized to use the back-end, the activer user will be logged out. This is because the only way to get the new credentials is to log in, again. 
 @since 1.25.0
 */
KCS_CONSTANT KCS_KEEP_USER_LOGGED_IN_ON_BAD_CREDENTIALS;


KCS_CONSTANT KCS_SERVICE_HOST;


/** Configuration wrapper for setting up a KCSClient. Configurations are adjustable at compile- or run-time. See the guides at http://devecenter.kinvey.com for how configurations work with app environments.
 
 @since 1.20.0
 */
@interface KCSClientConfiguration : NSObject <NSCopying>

/** The application identifier 
 @since 1.20.0
 */
@property (nonatomic, copy) NSString* appKey;

/** The application secret 
 @since 1.20.0
 */
@property (nonatomic, copy) NSString* appSecret;

/** A dictionary of options. 

 - KCS_APP_KEY  -- The app key obtained from the console
 - KCS_APP_SECRET -- The app secret obtained from the console (not the master secret)
 
 Client Options:
 
 - KCS_LOG_SINK -- the KCSLogSink instance to handle log messages
 
 Social Integration Options:
 
 - KCS_FACEBOOK_APP_KEY
 - KCS_TWITTER_CLIENT_KEY
 - KCS_TWITTER_CLIENT_SECRET
 - KCS_LINKEDIN_API_KEY
 - KCS_LINKEDIN_SECRET_KEY
 - KCS_LINKEDIN_ACCEPT_REDIRECT
 - KCS_LINKEDIN_CANCEL_REDIRECT
 - KCS_SALESFORCE_IDENTITY_URL
 - KCS_SALESFORCE_REFRESH_TOKEN
 - KCS_SALESFORCE_CLIENT_ID
 
 The following are advanced options. Don't use unless you know what you're doing
 
 - KCS_CONNECTION_TIMEOUT -- a double representing in-seconds for connection timeouts
 - KCS_URL_CACHE_POLICY -- the url caching policy (NOTE this is for the NSURLConnection's caching and not for the KCSCachedAppdataStore.
 - KCS_DATE_FORMAT -- the format used for date parsing
 
 */
@property (nonatomic, copy) NSDictionary* options;

// internal use
@property (nonatomic, copy) NSString* serviceHostname;

/** Basic configuration with an app key and secret, no options. Uses the default options.
 
 Usage:
 
     KCSClientConfiguration* config = [KCSClientConfiguration configurationWithAppKey:@"<#KEY#>" secret:@"<#SECRET#>"];
     [[KCSClient sharedClient] initializeWithConfiguration:config];
 
 @param appKey the App Key for a specific app's environment. 
 @param appSecret the matching App Secret for the environment.
 @return a configuration with the default options
 @since 1.20.0
 */
+ (instancetype) configurationWithAppKey:(NSString*)appKey secret:(NSString*)appSecret;

/** Basic configuration with an app key and secret and options.
 
 Options can either be default overrides or additional configuration such as social network app keys.
 
 Usage:
 
     KCSClientConfiguration* config = [KCSClientConfiguration configurationWithAppKey:@"<#KEY#>" secret:@"<#SECRET#>" options:@{KCS_CONNECTION_TIMEOUT : @60}];
     [[KCSClient sharedClient] initializeWithConfiguration:config];
 
 @param appKey the App Key for a specific app's environment.
 @param appSecret the matching App Secret for the environment.
 @param options a dictionary of optional configuration.
 @return a configuration with the specified options
 @see options
 @since 1.20.0
 */
+ (instancetype) configurationWithAppKey:(NSString*)appKey secret:(NSString*)appSecret options:(NSDictionary*)options;

/** Builds the configuration from the specified plist.
 
 The plist must be in the main bundle. And include at least values for `KCS_APP_KEY` and `KCS_APP_SECRET`. It can optionally provide any of the other options, as well.
 
 Usage:
 
     KCSClientConfiguration* config = [KCSClientConfiguration configurationFromPlist:@"kinveyOptions"];
     [[KCSClient sharedClient] initializeWithConfiguration:config];
 
 @param plistName the name of the plist.
 @return a configuartion loaded from the plis
 @see options
 @since 1.20.0
 */
+ (instancetype) configurationFromPlist:(NSString*)plistName;

@end
