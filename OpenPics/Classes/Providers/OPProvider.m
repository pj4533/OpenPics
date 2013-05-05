//
//  OPProvider.m
//  OpenPics
//
//  Created by PJ Gray on 4/6/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import "OPProvider.h"

@implementation OPProvider

- (id) initWithProviderType:(NSString*) providerType {
    self = [super init];
    if (self) {
        self.providerType = providerType;
        self.supportsLocationSearching = NO;
    }
    return self;
}

- (void) getItemsWithQuery:(NSString*) queryString
            withPageNumber:(NSNumber*) pageNumber
                completion:(void (^)(NSArray* items, BOOL canLoadMore))completion {
    
}

- (void) getItemsWithRegion:(MKCoordinateRegion) region
                 completion:(void (^)(NSArray* items))completion {
    
}

- (void) upRezItem:(OPImageItem *) item withCompletion:(void (^)(NSURL *uprezImageUrl))completion {

}

- (void) fullUpRezItem:(OPImageItem *) item withCompletion:(void (^)(NSURL *uprezImageUrl))completion {
    [self upRezItem:item withCompletion:completion];
}

@end
