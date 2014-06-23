//
//  OPFlickrCommonsProvider.m
//  OpenPics
//
//  Created by PJ Gray on 6/9/14.
//  Copyright (c) 2014 Say Goodnight Software. All rights reserved.
//

#import "OPFlickrCommonsProvider.h"
#import "OPImageItem.h"

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
//    [self getItemsWithQuery:@"" withPageNumber:@1 withUserId:nil isCommons:YES success:success failure:failure];
    
    
    [self getInstitutionsWithSuccess:success failure:failure];
}

- (void) doInitialSearchInSet:(OPImageItem*) setItem
                  withSuccess:(void (^)(NSArray* items, BOOL canLoadMore))success
                      failure:(void (^)(NSError* error))failure {
    NSString* setId = setItem.providerSpecific[@"id"];
    if (setId) {
        [self getItemsInSetWithId:setId withPageNumber:@1 success:success failure:failure];
    } else if (setItem.providerSpecific[@"nsid"]) {
        [self getImageSetsWithPageNumber:@1 withUserId:setItem.providerSpecific[@"nsid"] success:success failure:failure];
    }
}

- (void) getItemsInSet:(OPImageItem*) setItem
        withPageNumber:(NSNumber*) pageNumber
               success:(void (^)(NSArray* items, BOOL canLoadMore))success
               failure:(void (^)(NSError* error))failure {
    NSString* setId = setItem.providerSpecific[@"id"];
    if (setId) {
        [self getItemsInSetWithId:setId withPageNumber:pageNumber success:success failure:failure];
    } else if (setItem.providerSpecific[@"nsid"]) {
        [self getItemsInSetWithId:setItem.providerSpecific[@"nsid"] withPageNumber:pageNumber success:success failure:failure];
    }
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
