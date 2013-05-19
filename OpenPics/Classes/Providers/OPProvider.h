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

- (void) doInitialSearchWithCompletion:(void (^)(NSArray* items, BOOL canLoadMore))completion;

- (void) getItemsWithQuery:(NSString*) queryString
            withPageNumber:(NSNumber*) pageNumber
                completion:(void (^)(NSArray* items, BOOL canLoadMore))completion;

- (void) getItemsWithRegion:(MKCoordinateRegion) region
                 completion:(void (^)(NSArray* items))completion;

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
