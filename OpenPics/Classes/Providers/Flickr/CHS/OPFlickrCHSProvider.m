//
//  OPFlickrCHSProvider.m
//  OpenPics
//
//  Created by PJ Gray on 6/22/14.
//  Copyright (c) 2014 Say Goodnight Software. All rights reserved.
//

#import "OPFlickrCHSProvider.h"
#import "OPImageItem.h"

NSString * const OPProviderTypeFlickrCHS = @"com.saygoodnight.flickrchs";

@implementation OPFlickrCHSProvider

- (id) initWithProviderType:(NSString*) providerType {
    self = [super initWithProviderType:providerType];
    if (self) {
        self.providerName = @"Cambridge Historical Society Flickr";
        self.providerShortName = @"CHS Flickr";
        self.supportsInitialSearching = YES;
    }
    return self;
}

- (void) doInitialSearchWithSuccess:(void (^)(NSArray* items, BOOL canLoadMore))success
                            failure:(void (^)(NSError* error))failure {
    
    [self getImageSetsWithPageNumber:@1 withUserId:@"38861678@N03" success:success failure:failure];
}

- (void) doInitialSearchInSet:(OPImageItem*) setItem
                  withSuccess:(void (^)(NSArray* items, BOOL canLoadMore))success
                      failure:(void (^)(NSError* error))failure {
    NSString* setId = setItem.providerSpecific[@"id"];
    [self getItemsInSetWithId:setId withPageNumber:@1 success:success failure:failure];
}

- (void) getItemsInSet:(OPImageItem*) setItem
        withPageNumber:(NSNumber*) pageNumber
               success:(void (^)(NSArray* items, BOOL canLoadMore))success
               failure:(void (^)(NSError* error))failure {
    NSString* setId = setItem.providerSpecific[@"id"];
    [self getItemsInSetWithId:setId withPageNumber:pageNumber success:success failure:failure];
}

- (void) getItemsWithQuery:(NSString*) queryString
            withPageNumber:(NSNumber*) pageNumber
                   success:(void (^)(NSArray* items, BOOL canLoadMore))success
                   failure:(void (^)(NSError* error))failure {
    if (!queryString || [queryString isEqualToString:@""]) {
        [self getImageSetsWithPageNumber:pageNumber withUserId:@"38861678@N03" success:success failure:failure];
    } else {
        [self getItemsWithQuery:queryString
                 withPageNumber:pageNumber
                     withUserId:@"38861678@N03"
                      isCommons:NO
                        success:success
                        failure:failure];
    }
}


@end
