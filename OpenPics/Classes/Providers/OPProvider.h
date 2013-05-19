//
//  OPProvider.h
//  OpenPics
//
//  Created by PJ Gray on 4/6/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OPImageItem;
@interface OPProvider : NSObject

@property (strong, nonatomic) NSString* providerType;
@property (strong, nonatomic) NSString* providerName;

// This means the provider gives location information for items
//    DEFAULT:  NO
@property BOOL supportsLocationSearching;

// This means the provider has an initial search, for a more passive experience of browsing
//    DEFAULT:  NO
@property BOOL supportsInitialSearching;

- (id) initWithProviderType:(NSString*) providerType;

- (void) doInitialSearchWithSuccess:(void (^)(NSArray* items, BOOL canLoadMore))success
                            failure:(void (^)(NSError* error))failure;

- (void) getItemsWithQuery:(NSString*) queryString
            withPageNumber:(NSNumber*) pageNumber
                   success:(void (^)(NSArray* items, BOOL canLoadMore))success
                   failure:(void (^)(NSError* error))failure;

- (void) getItemsWithRegion:(MKCoordinateRegion) region
                    success:(void (^)(NSArray* items))success
                    failure:(void (^)(NSError* error))failure;

- (void) upRezItem:(OPImageItem *) item withCompletion:(void (^)(NSURL *uprezImageUrl, OPImageItem* item))completion;

- (void) fullUpRezItem:(OPImageItem *) item withCompletion:(void (^)(NSURL *uprezImageUrl, OPImageItem* item))completion;


- (void) contentDMImageInfoWithURL:(NSURL*) url
                          withItem:(OPImageItem*) item
                      withHostName:(NSString*) hostName
                    withCollection:(NSString*) collectionString
                            withID:(NSString*) idString
                     withURLFormat:(NSString*) urlFormat
                    withCompletion:(void (^)(NSURL *uprezImageUrl, OPImageItem* item))completion;

@end
