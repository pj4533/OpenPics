//
//  OPFlickrCommonsProvider.m
//  OpenPics
//
//  Created by PJ Gray on 6/9/14.
//  Copyright (c) 2014 Say Goodnight Software. All rights reserved.
//

#import "OPFlickrCommonsProvider.h"

NSString * const OPProviderTypeFlickrCommons = @"com.saygoodnight.flickrcommons";

@implementation OPFlickrCommonsProvider

- (id) initWithProviderType:(NSString*) providerType {
    self = [super initWithProviderType:providerType];
    if (self) {
        self.providerName = @"Flickr Commons Project";
        self.supportsInitialSearching = YES;
    }
    return self;
}

- (void) doInitialSearchWithSuccess:(void (^)(NSArray* items, BOOL canLoadMore))success
                            failure:(void (^)(NSError* error))failure {
    [self doInitialSearchWithUserId:nil isCommons:YES success:success failure:failure];
}

- (void) getItemsWithQuery:(NSString*) queryString
            withPageNumber:(NSNumber*) pageNumber
                   success:(void (^)(NSArray* items, BOOL canLoadMore))success
                   failure:(void (^)(NSError* error))failure {
    [self getItemsWithQuery:queryString
             withPageNumber:pageNumber
                 withUserId:nil
                  isCommons:YES
                    success:success
                    failure:failure];
}


@end
