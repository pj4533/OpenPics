//
//  OPRedditGenericProvider.m
//  OpenPics
//
//  Created by PJ Gray on 11/2/14.
//  Copyright (c) 2014 Say Goodnight Software. All rights reserved.
//

#import "OPRedditGenericProvider.h"

NSString * const OPProviderTypeRedditGeneric = @"com.saygoodnight.redditgeneric";

@interface OPRedditGenericProvider () {
    NSString* _subredditName;
}

@end

@implementation OPRedditGenericProvider

- (id) initWithProviderType:(NSString*) providerType subredditName:(NSString*)subredditName {
    self = [super initWithProviderType:providerType];
    if (self) {
        _subredditName = subredditName;
        self.providerName = [NSString stringWithFormat:@"/r/%@", _subredditName];
        self.supportsInitialSearching = YES;
    }
    return self;
}

- (void) doInitialSearchWithSuccess:(void (^)(NSArray* items, BOOL canLoadMore))success
                            failure:(void (^)(NSError* error))failure {
    [self doInitialSearchWithSubreddit:_subredditName success:success failure:failure];
}

- (void) getItemsWithQuery:(NSString*) queryString
            withPageNumber:(NSNumber*) pageNumber
                   success:(void (^)(NSArray* items, BOOL canLoadMore))success
                   failure:(void (^)(NSError* error))failure {
    [self getItemsWithQuery:queryString
             withPageNumber:pageNumber
              withSubreddit:_subredditName
                    success:success
                    failure:failure];
}

- (void) upRezItem:(OPItem *) item withCompletion:(void (^)(NSURL *uprezImageUrl, OPItem* item))completion {
}

@end
