//
//  AFNYPLAPIClient.m
//
//  Created by PJ Gray on 3/16/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import "AFNYPLAPIClient.h"
#import "AFJSONRequestOperation.h"

static NSString * const kNYPLBaseURLString = @"http://api.repo.nypl.org/api/v1/";

@implementation AFNYPLAPIClient

+ (AFNYPLAPIClient *)sharedClientWithToken:(NSString *)token {
    static AFNYPLAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:kNYPLBaseURLString] withToken:token];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url withToken:(NSString*) token {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [self setDefaultHeader:@"Accept" value:@"application/json"];
    [self setAuthorizationHeaderWithToken:token];

    return self;
}

@end
