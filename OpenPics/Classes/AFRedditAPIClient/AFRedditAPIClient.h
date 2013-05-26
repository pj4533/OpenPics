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
@property (strong, nonatomic) NSString *modHash;
@property (strong, nonatomic) NSString *cookie;

+ (instancetype)sharedClient;
- (void)loginToRedditWithUsername:(NSString*)username password:(NSString*)password success:(void (^)(NSDictionary*))success;
- (void)postImage:(UIImage*)image toSubreddit:(NSString*)subreddit withTitle:(NSString*)title success:(void (^)(NSDictionary*))success;
- (BOOL) isAuthenticated;
@end
