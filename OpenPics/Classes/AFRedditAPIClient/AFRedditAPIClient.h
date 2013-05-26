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
@property (strong, nonatomic) NSString *captcha;

+ (instancetype)sharedClient;
- (void)loginToRedditWithUsername:(NSString*)username password:(NSString*)password completion:(void (^)(NSDictionary*, BOOL))completion;
- (void)postItem:(NSDictionary*)item toSubreddit:(NSString*)subreddit withTitle:(NSString*)title completion:(void (^)(NSDictionary*, BOOL))completion;
- (void) getUsersSubscribedSubredditsWithCompletion:(void (^)(NSArray*, BOOL))completion;
- (BOOL) isAuthenticated;
- (void) getCaptchaID;
@end
