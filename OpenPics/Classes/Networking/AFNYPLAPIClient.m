//
//  AFNYPLAPIClient.m
//
//  Created by PJ Gray on 3/16/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import "AFNYPLAPIClient.h"
#import "AFJSONRequestOperation.h"
#import "OPImageItem.h"
#import "OPProviderTokens.h"

static NSString * const kNYPLBaseURLString = @"http://api.repo.nypl.org/api/v1/";

@implementation AFNYPLAPIClient

+ (AFNYPLAPIClient *)sharedClient {
    static AFNYPLAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:kNYPLBaseURLString]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [self setDefaultHeader:@"Accept" value:@"application/json"];
    
#ifndef kOPPROVIDERTOKEN_NYPL
#error Make sure to setup your OPProviderTokens.h file!
#else
    [self setAuthorizationHeaderWithToken:kOPPROVIDERTOKEN_NYPL];
#endif
    
    return self;
}

- (void)getItemsWithParameters:(NSDictionary*) parameters
                       success:(void (^)(NSArray* items))success
                       failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
    NSLog(@"GET items/search.json %@", parameters);
    
    [self getPath:@"items/search.json" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* responseDict = responseObject[@"nyplAPI"][@"response"];
        NSArray* resultArray = responseDict[@"result"];
        NSMutableArray* retArray = [NSMutableArray array];
        for (NSDictionary* itemDict in resultArray) {
            OPImageItem* item = [[OPImageItem alloc] initWithDictionary:itemDict];
            [retArray addObject:item];
        }
        
        if (success) {
            success(retArray);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"url: %@", [operation.request.URL absoluteString]);
        NSLog(@"failure: %@", error);
        if (failure) {
            failure(operation,error);
        }
    }];
    
}

@end
