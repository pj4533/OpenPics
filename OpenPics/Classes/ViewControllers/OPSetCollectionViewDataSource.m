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

- (void) getMoreItemsWithSuccess:(void (^)(NSArray* indexPaths))success
                         failure:(void (^)(NSError* error))failure {
    _canLoadMore = NO;
    OPProvider* selectedProvider = [[OPProviderController shared] getSelectedProvider];
    [selectedProvider getItemsInSet:self.setItem withPageNumber:_currentPage success:^(NSArray *items, BOOL canLoadMore) {
        if ([_currentPage isEqual:@1]) {
            _canLoadMore = canLoadMore;
            _items = items.mutableCopy;
            if (success) {
                success(nil);
            }
        } else {
            NSInteger offset = [_items count];
            
            // TODO: use performBatch when bug is fixed in UICollectionViews with headers
            NSMutableArray* indexPaths = [NSMutableArray array];
            for (int i = 0; i < items.count; i++) {
                [indexPaths addObject:[NSIndexPath indexPathForItem:i+offset inSection:0]];
            }
            [_items addObjectsFromArray:items];
            _canLoadMore = canLoadMore;
            if (success) {
                success(indexPaths);
            }
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

@end
