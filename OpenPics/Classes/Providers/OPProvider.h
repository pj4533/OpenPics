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

- (id) initWithProviderType:(NSString*) providerType;

- (void) getItemsWithQuery:(NSString*) queryString
            withPageNumber:(NSNumber*) pageNumber
                completion:(void (^)(NSArray* items, BOOL canLoadMore))completion;

- (void) upRezItem:(OPImageItem *) item withCompletion:(void (^)(NSURL *uprezImageUrl))completion;

- (void) fullUpRezItem:(OPImageItem *) item withCompletion:(void (^)(NSURL *uprezImageUrl))completion;

@end
