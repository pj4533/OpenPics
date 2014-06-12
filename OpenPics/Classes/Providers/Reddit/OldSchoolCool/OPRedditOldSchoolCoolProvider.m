//
//  OPRedditOldSchoolCoolProvider.m
//  OpenPics
//
//  Created by PJ Gray on 6/11/14.
//  Copyright (c) 2014 Say Goodnight Software. All rights reserved.
//

#import "OPRedditOldSchoolCoolProvider.h"

NSString * const OPProviderTypeRedditOldSchoolCool = @"com.saygoodnight.redditoldschoolcool";

@implementation OPRedditOldSchoolCoolProvider

- (id) initWithProviderType:(NSString*) providerType {
    self = [super initWithProviderType:providerType];
    if (self) {
        self.providerName = @"/r/OldSchoolCool";
        self.supportsInitialSearching = YES;
    }
    return self;
}

- (void) doInitialSearchWithSuccess:(void (^)(NSArray* items, BOOL canLoadMore))success
                            failure:(void (^)(NSError* error))failure {
    [self doInitialSearchWithSubreddit:@"oldschoolcool" success:success failure:failure];
}

- (void) getItemsWithQuery:(NSString*) queryString
            withPageNumber:(NSNumber*) pageNumber
                   success:(void (^)(NSArray* items, BOOL canLoadMore))success
                   failure:(void (^)(NSError* error))failure {
    [self getItemsWithQuery:queryString
             withPageNumber:pageNumber
              withSubreddit:@"oldschoolcool"
                    success:success
                    failure:failure];
}


@end
