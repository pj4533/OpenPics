//
//  OPRedditTheWayWeWereProvider.m
//  OpenPics
//
//  Created by PJ Gray on 6/25/14.
//  Copyright (c) 2014 Say Goodnight Software. All rights reserved.
//

#import "OPRedditTheWayWeWereProvider.h"

NSString * const OPProviderTypeRedditTheWayWeWere = @"com.saygoodnight.redditthewaywewere";

@implementation OPRedditTheWayWeWereProvider

- (id) initWithProviderType:(NSString*) providerType {
    self = [super initWithProviderType:providerType];
    if (self) {
        self.providerName = @"/r/TheWayWeWere";
        self.supportsInitialSearching = YES;
    }
    return self;
}

- (void) doInitialSearchWithSuccess:(void (^)(NSArray* items, BOOL canLoadMore))success
                            failure:(void (^)(NSError* error))failure {
    [self doInitialSearchWithSubreddit:@"thewaywewere" success:success failure:failure];
}

- (void) getItemsWithQuery:(NSString*) queryString
            withPageNumber:(NSNumber*) pageNumber
                   success:(void (^)(NSArray* items, BOOL canLoadMore))success
                   failure:(void (^)(NSError* error))failure {
    [self getItemsWithQuery:queryString
             withPageNumber:pageNumber
              withSubreddit:@"thewaywewere"
                    success:success
                    failure:failure];
}


@end
