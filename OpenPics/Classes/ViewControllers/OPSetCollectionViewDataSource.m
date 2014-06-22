//
//  OPSetCollectionViewDataSource.m
//  OpenPics
//
//  Created by PJ Gray on 6/22/14.
//  Copyright (c) 2014 Say Goodnight Software. All rights reserved.
//

#import "OPSetCollectionViewDataSource.h"
#import "OPProviderController.h"
#import "OPProvider.h"

@implementation OPSetCollectionViewDataSource

- (void) doInitialSearchWithSuccess:(void (^)(NSArray* items, BOOL canLoadMore))success
                            failure:(void (^)(NSError* error))failure {
    
    OPProvider* selectedProvider = [[OPProviderController shared] getSelectedProvider];
    _currentPage = [NSNumber numberWithInteger:1];
    
    [selectedProvider doInitialSearchInSet:self.setItem withSuccess:^(NSArray *items, BOOL canLoadMore) {
        _canLoadMore = canLoadMore;
        _items = items.mutableCopy;
        if (success) {
            success(items,canLoadMore);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

@end
