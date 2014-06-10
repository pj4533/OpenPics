//
//  OPFlickrBPLProvider.m
//  OpenPics
//
//  Created by PJ Gray on 6/9/14.
//  Copyright (c) 2014 Say Goodnight Software. All rights reserved.
//

#import "OPFlickrBPLProvider.h"

NSString * const OPProviderTypeFlickrBPL = @"com.saygoodnight.flickrbpl";

@implementation OPFlickrBPLProvider

- (id) initWithProviderType:(NSString*) providerType {
    self = [super initWithProviderType:providerType];
    if (self) {
        self.providerName = @"Boston Public Library Flickr";
        self.providerShortName = @"BPL Flickr";
        self.supportsInitialSearching = YES;
    }
    return self;
}

- (void) doInitialSearchWithSuccess:(void (^)(NSArray* items, BOOL canLoadMore))success
                            failure:(void (^)(NSError* error))failure {
    [self doInitialSearchWithUserId:@"24029425@N06" isCommons:NO success:success failure:failure];
}

- (void) getItemsWithQuery:(NSString*) queryString
            withPageNumber:(NSNumber*) pageNumber
                   success:(void (^)(NSArray* items, BOOL canLoadMore))success
                   failure:(void (^)(NSError* error))failure {
    [self getItemsWithQuery:queryString
             withPageNumber:pageNumber
                 withUserId:@"24029425@N06"
                  isCommons:NO
                    success:success
                    failure:failure];
}


@end
