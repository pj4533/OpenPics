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

+ (instancetype)sharedClient {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

- (instancetype)init {
    self = [super initWithBaseURL:[NSURL URLWithString:@"http://www.reddit.com/api"]];
    if (!self) {
        return nil;
    }
    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"application/x-www-form-urlencoded"]];
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    return self;
}

- (void)loginToRedditWithUsername:(NSString*)username andPassword:(NSString*)password {
    NSDictionary *params = @{
                             @"user": username,
                             @"passwd": password,
                             @"api_type": @"json",
                             @"rem": @"True"
                             };
    [self postPath:@"login" parameters:params success:^(NSDictionary *response) {
        NSLog(@"%@", response);
        self.modHash = response[@"json"][@"data"][@"modhash"];
        self.cookie = response[@"json"][@"data"][@"cookie"];
    }];
}

- (void)submitImage:(UIImage*)image toSubreddit:(NSString*)subreddit title:(NSString*)title success:(void (^)(NSDictionary*))success {
    [self uploadToImgur:image title:title success:^(NSDictionary *response) {
        NSString *link = response[@"data"][@"link"];
        NSDictionary *params = @{
                                 @"api_type": @"json",
                                 @"kind": @"link",
                                 @"title": title,
                                 @"uh": self.modHash,
                                 @"url": link,
                                 @"sr": subreddit,
                                 @"save": @"true"
                                 };
        [self postPath:@"submit" parameters:params success:^(NSDictionary *success) {
            NSLog(@"success!");
        }];
    }];
}

- (void)postPath:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(NSDictionary*))success {
    [super postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"\nSuccess Posting to Path: %@", path);
        NSDictionary *jsonResponse;
        if ([responseObject isKindOfClass:[NSData class]]) {
            jsonResponse = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        } else {
            jsonResponse = responseObject;
        }
        success(jsonResponse);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"\nError Posting to Path: %@\nWith Error:\n%@", path, error);
    }];
}

- (void)getPath:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(NSDictionary*))success {
    [super getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"\nSuccess Getting Path: %@\nResponse Object:%@", path, (AFJSONRequestOperation*)operation);
        success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"\nError Getting Path: %@\nWith Error:\n%@", path, error);
    }];
}

- (void)uploadToImgur:(UIImage*)image title:(NSString*)title success:(void (^)(NSDictionary*))success{
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
        success(JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"Failure Uploading to Imgur:\n%@", JSON);
    }];

    [operation start];
}
@end
