//
//  OPAppDelegate.m
//  OpenPics
//
//  Created by PJ Gray on 4/6/13.
// 
// Copyright (c) 2013 Say Goodnight Software
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


#import "OPAppDelegate.h"
#import "OPAppTokens.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "AFNetworkActivityLogger.h"
#import "OPProviderController.h"

#import "OPNYPLProvider.h"
#import "OPLOCProvider.h"
#import "OPCDLProvider.h"
#import "OPDPLAProvider.h"
#import "OPEuropeanaProvider.h"
#import "OPLIFEProvider.h"
#import "OPTroveProvider.h"
#import "OPPopularProvider.h"
#import "OPFavoritesProvider.h"
#import "OPFlickrCommonsProvider.h"
#import "OPFlickrBPLProvider.h"
#import "OPFlickrCHSProvider.h"
#import "OPRedditHistoryPornProvider.h"
#import "OPRedditOldSchoolCoolProvider.h"
#import "OPRedditTheWayWeWereProvider.h"

#import "OPBackend.h"

#import "TMCache.h"

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>


@interface OPAppDelegate () {
}

@end

@implementation OPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [Fabric with:@[[Crashlytics class]]];

    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:8 * 1024 * 1024 diskCapacity:20 * 1024 * 1024 diskPath:nil];
    [NSURLCache setSharedURLCache:URLCache];
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    [[AFNetworkActivityLogger sharedLogger] startLogging];
    [AFNetworkActivityLogger sharedLogger].level = AFLoggerLevelInfo;
        
    TMCache* sharedCache = [TMCache sharedCache];

    // disk limit 100mb
    sharedCache.diskCache.byteLimit = 104857600;
    
    if ([[OPBackend shared] usingRemoteBackend]) {
        NSLog(@"Using Remote Backend");
        [[OPProviderController shared] addProvider:[[OPPopularProvider alloc] initWithProviderType:OPProviderTypePopular]];
    } else {
        NSLog(@"No Remote Backend");
    }
    
    [[OPProviderController shared] addProvider:[[OPFlickrCommonsProvider alloc] initWithProviderType:OPProviderTypeFlickrCommons]];
    [[OPProviderController shared] addProvider:[[OPRedditHistoryPornProvider alloc] initWithProviderType:OPProviderTypeRedditHistoryPorn]];
    [[OPProviderController shared] addProvider:[[OPRedditOldSchoolCoolProvider alloc] initWithProviderType:OPProviderTypeRedditOldSchoolCool]];
    [[OPProviderController shared] addProvider:[[OPRedditTheWayWeWereProvider alloc] initWithProviderType:OPProviderTypeRedditTheWayWeWere]];
    [[OPProviderController shared] addProvider:[[OPFlickrBPLProvider alloc] initWithProviderType:OPProviderTypeFlickrBPL]];
    [[OPProviderController shared] addProvider:[[OPFlickrCHSProvider alloc] initWithProviderType:OPProviderTypeFlickrCHS]];
    [[OPProviderController shared] addProvider:[[OPLIFEProvider alloc] initWithProviderType:OPProviderTypeLIFE]];
    [[OPProviderController shared] addProvider:[[OPNYPLProvider alloc] initWithProviderType:OPProviderTypeNYPL]];
    [[OPProviderController shared] addProvider:[[OPLOCProvider alloc] initWithProviderType:OPProviderTypeLOC]];
    [[OPProviderController shared] addProvider:[[OPDPLAProvider alloc] initWithProviderType:OPProviderTypeDPLA]];
    [[OPProviderController shared] addProvider:[[OPCDLProvider alloc] initWithProviderType:OPProviderTypeCDL]];
    [[OPProviderController shared] addProvider:[[OPEuropeanaProvider alloc] initWithProviderType:OPProviderTypeEuropeana]];
    [[OPProviderController shared] addProvider:[[OPTroveProvider alloc] initWithProviderType:OPProviderTypeTrove]];
    [[OPProviderController shared] addProvider:[[OPFavoritesProvider alloc] initWithProviderType:OPProviderTypeFavorites]];
        
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

@end
