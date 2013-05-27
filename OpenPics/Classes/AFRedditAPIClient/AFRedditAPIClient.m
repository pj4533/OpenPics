//
//  AFRedditAPIClient.m
//  OpenPics
//
//  Created by David Ohayon on 5/25/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import "AFRedditAPIClient.h"
#import "AFJSONRequestOperation.h"
#import "TTTURLRequestFormatter.h"

static NSString *kImgurAPIKey = @"541b2754d7499e8";

@implementation AFRedditAPIClient

+ (instancetype) sharedClient {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

- (instancetype) init {
    self = [super initWithBaseURL:[NSURL URLWithString:@"http://www.reddit.com"]];
    if (!self) {
        return nil;
    }
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    if ([currentDefaults objectForKey:@"modHash"] && [currentDefaults objectForKey:@"cookie"]) {
        self.modHash = [currentDefaults objectForKey:@"modHash"];
        self.cookie = [currentDefaults objectForKey:@"cookie"];
    }
    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"application/x-www-form-urlencoded"]];
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    return self;
}

- (void) loginToRedditWithUsername:(NSString*)username password:(NSString*)password completion:(void (^)(NSDictionary*, BOOL))completion {
    NSDictionary *params = @{
                             @"user": username,
                             @"passwd": password,
                             @"api_type": @"json",
                             @"rem": @"True"
                             };
    [self postPath:@"api/login" parameters:params completion:^(NSDictionary *response, BOOL success) {
        if (!success) {
            NSLog(@"Failed Login");
        } else {
            self.modHash = response[@"modhash"];
            self.cookie = response[@"cookie"];
            NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
            [currentDefaults setObject:self.modHash forKey:@"modHash"];
            [currentDefaults setObject:self.cookie forKey:@"cookie"];
        }
        completion(response, success);
    }];
}

- (void) getUsersSubscribedSubredditsWithCompletion:(void (^)(NSArray* subreddits, BOOL success))completion {
    if (![self isAuthenticated]) {
        BOOL success = NO;
        NSArray *subreddits = [[NSArray alloc]init];
        completion(subreddits, success);
        return;
    }
    
    NSDictionary *parameters = @{
                                 @"uh": self.modHash,
                                 @"limit": @"100"
                                 };
    [self getPath:@"/subreddits/mine.json" parameters:parameters completion:^(NSDictionary *subreddits, BOOL success) {
        NSArray *arrayOfSubreddits = subreddits[@"children"];
        NSMutableArray *reddits = [[NSMutableArray alloc] init];
        for (NSDictionary *thisSubreddit in arrayOfSubreddits) {
            [reddits addObject:thisSubreddit[@"display_name"]];
        }
        completion([NSArray arrayWithArray:reddits], success);
    }];
}

- (BOOL) isAuthenticated {
    if (self.modHash) {
        NSLog(@"Already Authed");
        return YES;
    } else {
        return NO;
    }
}

- (void) postItem:(NSDictionary*)item toSubreddit:(NSString*)subreddit withTitle:(NSString*)title completion:(void (^)(NSDictionary*, BOOL))completion {
    NSDictionary *params = @{
                             @"api_type": @"json",
                             @"kind": @"link",
                             @"title": title,
                             @"uh": self.modHash,
                             @"url": [NSString stringWithFormat:@"%@", item[@"imageUrl"]],
                             @"sr": subreddit,
                             @"save": @"true"
                             };
    [self postPath:@"api/submit" parameters:params completion:^(NSDictionary *response, BOOL success) {
        completion(response, success);
    }];
}

- (void) getCaptchaIDWithCompletion:(void (^)(NSString*, BOOL))completion {
    [self postPath:@"api/new_captcha" parameters:@{@"api_type": @"json"} completion:^(NSDictionary *response, BOOL success) {
        if (!success) {
            NSLog(@"No New Captcha:\n%@", response);
        }
        completion(response[@"iden"], success);
    }];
}

- (void) postPath:(NSString *)path parameters:(NSDictionary *)parameters completion:(void (^)(NSDictionary*, BOOL))completion {
    [super postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Posted to Path: %@", path);
        BOOL success;
        NSDictionary *jsonResponse;
        
        if ([responseObject isKindOfClass:[NSData class]]) {
            jsonResponse = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil][@"json"];
        } else {
            jsonResponse = responseObject[@"json"];
        }
        
        NSDictionary *dataDict = [[NSDictionary alloc] init];
        
        if ([jsonResponse[@"errors"] count]) {
            NSLog(@"Error Posting to Reddit:\n%@", jsonResponse[@"errors"]);
            dataDict =@{ @"errors": jsonResponse[@"errors"] };
            success = NO;
        } else {
            NSLog(@"Success Posting to Reddit:\n%@", jsonResponse[@"data"]);
            dataDict = jsonResponse[@"data"];
            success = YES;
        }
        completion(dataDict, success);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error Posting to Path: %@\nWith Error:\n%@", path, error);
    }];
}

- (void) getPath:(NSString *)path parameters:(NSDictionary *)parameters completion:(void (^)(NSDictionary*, BOOL))completion {
    [super getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Got Path: %@", path);
        NSDictionary *jsonResponse;
        BOOL success;
        
        if ([responseObject isKindOfClass:[NSData class]]) {
            jsonResponse = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil][@"json"];
        } else {
            jsonResponse = responseObject[@"json"];
        }
        
        NSDictionary *dataDict = [[NSDictionary alloc] init];
        
        if ([jsonResponse[@"errors"] count]) {
            NSLog(@"Error Getting from Reddit:\n%@", jsonResponse[@"errors"]);
            dataDict =@{ @"errors": jsonResponse[@"errors"] };
            success = NO;
        } else {
            NSLog(@"Success Getting from Reddit:\n%@", jsonResponse[@"data"]);
            dataDict = jsonResponse[@"data"];
            success = YES;
        }
        
        completion(dataDict, success);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"\nError Getting Path: %@\nWith Error:\n%@", path, error);
    }];
}

- (void) uploadToImgur:(UIImage*)image title:(NSString*)title completion:(void (^)(NSDictionary*))completion {
    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@"https://api.imgur.com/3"]];
    [client setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"Client-ID %@", kImgurAPIKey]];
    [client setParameterEncoding:AFFormURLParameterEncoding];
    NSData *imageData = UIImagePNGRepresentation(image);
    NSDictionary *params = @{
                             @"image": imageData,
                             };
    NSMutableURLRequest *afRequest = [client multipartFormRequestWithMethod:@"POST" path:@"upload" parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData name:title fileName:[NSString stringWithFormat:@"%@.tiff", title] mimeType:@"image/tiff"];
    }];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:afRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        completion(JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"Failure Uploading to Imgur:\n%@", JSON);
    }];
    
    [operation start];
}

@end
