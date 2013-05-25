//
//  AFRedditAPIClient.h
//  OpenPics
//
//  Created by David Ohayon on 5/25/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import "AFHTTPClient.h"

@interface AFRedditAPIClient : AFHTTPClient

@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;
@property (nonatomic) BOOL loggedIn;
@property (strong, nonatomic) NSString *modHash;
@property (strong, nonatomic) NSString *cookie;

+ (instancetype)sharedClient;
- (void)loginToRedditWithUsername:(NSString*)username andPassword:(NSString*)password;
- (void)submitImage:(UIImage*)image toSubreddit:(NSString*)subreddit title:(NSString*)title success:(void (^)(NSDictionary*))success;

@end
