//
//  OPRedditHistoryPornProvider.m
//  OpenPics
//
//  Created by PJ Gray on 6/11/14.
//  Copyright (c) 2014 Say Goodnight Software. All rights reserved.
//

#import "OPRedditHistoryPornProvider.h"

NSString * const OPProviderTypeRedditHistoryPorn = @"com.saygoodnight.reddithistoryporn";

@implementation OPRedditHistoryPornProvider

- (id) initWithProviderType:(NSString*) providerType {
    self = [super initWithProviderType:providerType];
    if (self) {
        self.providerName = @"/r/HistoryPorn";
        self.supportsInitialSearching = YES;
    }
    return self;
}

- (void) doInitialSearchWithSuccess:(void (^)(NSArray* items, BOOL canLoadMore))success
                            failure:(void (^)(NSError* error))failure {
    [self doInitialSearchWithSubreddit:@"historyporn" success:success failure:failure];
}

- (void) getItemsWithQuery:(NSString*) queryString
            withPageNumber:(NSNumber*) pageNumber
                   success:(void (^)(NSArray* items, BOOL canLoadMore))success
                   failure:(void (^)(NSError* error))failure {
    [self getItemsWithQuery:queryString
             withPageNumber:pageNumber
              withSubreddit:@"historyporn"
                    success:success
                    failure:failure];
}


@end
