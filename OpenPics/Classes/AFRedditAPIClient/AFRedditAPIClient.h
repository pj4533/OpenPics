//
//  AFRedditAPIClient.h
//  OpenPics
//
//  Created by David Ohayon on 5/25/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import "AFHTTPClient.h"

@interface AFRedditAPIClient : AFHTTPClient

@property (strong, nonatomic) NSString *modHash;
@property (strong, nonatomic) NSString *cookie;
@property (strong, nonatomic) NSString *imgurClientID;

+ (instancetype) sharedClient;

- (void) loginToRedditWithUsername:(NSString*)username password:(NSString*)password completion:(void (^)(NSDictionary*, BOOL))completion;

- (BOOL) isAuthenticated;

- (void) postItem:(NSDictionary*)item toSubreddit:(NSString*)subreddit withTitle:(NSString*)title completion:(void (^)(NSDictionary*, BOOL))completion;

- (void) getUsersSubscribedSubredditsWithCompletion:(void (^)(NSArray*, BOOL))completion;

- (void) getCaptchaIDWithCompletion:(void (^)(NSString*, BOOL))completion;

- (void) postPath:(NSString *)path parameters:(NSDictionary *)parameters completion:(void (^)(NSDictionary*, BOOL))completion;

- (void) getPath:(NSString *)path parameters:(NSDictionary *)parameters completion:(void (^)(NSDictionary*, BOOL))completion;

- (void) uploadToImgur:(UIImage*)image title:(NSString*)title completion:(void (^)(NSDictionary*))completion;

@end
