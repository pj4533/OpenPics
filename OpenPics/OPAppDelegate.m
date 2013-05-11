//
//  OPAppDelegate.m
//  OpenPics
//
//  Created by PJ Gray on 4/6/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import "OPAppDelegate.h"
#import "OPAppTokens.h"
#import "AFNetworking.h"
#import "AFOAuth1Client.h"
#import "OPViewController.h"
#import "OPProviderController.h"

#import "OPNYPLProvider.h"
#import "OPLOCProvider.h"
#import "OPCDLProvider.h"
#import "OPDPLAProvider.h"
#import "OPEuropeanaProvider.h"
#import "OPLIFEProvider.h"

#import "OPAppearance.h"
#import <Crashlytics/Crashlytics.h>
#import "AFStatHatClient.h"

@interface OPAppDelegate () {
    NSDate* _appBecameActiveDate;
}

@end

@implementation OPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:8 * 1024 * 1024 diskCapacity:20 * 1024 * 1024 diskPath:nil];
    [NSURLCache setSharedURLCache:URLCache];
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];

#ifdef kOPAPPTOKEN_CRASHLYTICS
    [Crashlytics startWithAPIKey:kOPAPPTOKEN_CRASHLYTICS];
#endif
    
    [OPAppearance setupGlobalAppearance];
    
    [[OPProviderController shared] addProvider:[[OPNYPLProvider alloc] initWithProviderType:OPProviderTypeNYPL]];
    [[OPProviderController shared] addProvider:[[OPLOCProvider alloc] initWithProviderType:OPProviderTypeLOC]];
    [[OPProviderController shared] addProvider:[[OPCDLProvider alloc] initWithProviderType:OPProviderTypeCDL]];
    [[OPProviderController shared] addProvider:[[OPDPLAProvider alloc] initWithProviderType:OPProviderTypeDPLA]];
    [[OPProviderController shared] addProvider:[[OPEuropeanaProvider alloc] initWithProviderType:OPProviderTypeEuropeana]];
    [[OPProviderController shared] addProvider:[[OPLIFEProvider alloc] initWithProviderType:OPProviderTypeLIFE]];
        
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [[OPViewController alloc] initWithNibName:@"OPViewController" bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
#if !TARGET_IPHONE_SIMULATOR
#ifdef kOPAPPTOKEN_STATHAT
    AFStatHatClient* stathat = [[AFStatHatClient alloc] initWithEZKey:kOPAPPTOKEN_STATHAT];
    NSTimeInterval secondsAppWasActive = [[NSDate date] timeIntervalSinceDate:_appBecameActiveDate];
    [stathat postEZStat:@"Length of time using OpenPics (in minutes)" withValue:@(secondsAppWasActive/60)];
#endif
#endif
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{

    _appBecameActiveDate = [NSDate date];
    
#if !TARGET_IPHONE_SIMULATOR
#ifdef kOPAPPTOKEN_STATHAT
    AFStatHatClient* stathat = [[AFStatHatClient alloc] initWithEZKey:kOPAPPTOKEN_STATHAT];
    [stathat postEZStat:@"OpenPics Launches" withCount:@1];
#endif
#endif
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    NSNotification *notification = [NSNotification notificationWithName:kAFApplicationLaunchedWithURLNotification object:nil userInfo:[NSDictionary dictionaryWithObject:url forKey:kAFApplicationLaunchOptionsURLKey]];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    
    return YES;
}


@end
