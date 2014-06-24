//
//  OPCollectionViewDataSource.h
//  OpenPics
//
//  Created by PJ Gray on 5/4/14.
//  Copyright (c) 2014 Say Goodnight Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OPContentCell.h"

@interface OPCollectionViewDataSource : NSObject <UICollectionViewDataSource> {
    NSNumber* _currentPage;
    BOOL _canLoadMore;
    NSMutableArray* _items;
}

@property (weak, nonatomic) NSString* currentQueryString;
@property (weak, nonatomic) id<OPContentCellDelegate> delegate;

- (void) doInitialSearchWithSuccess:(void (^)(NSArray* items, BOOL canLoadMore))success
                            failure:(void (^)(NSError* error))failure;

- (void) getMoreItemsWithSuccess:(void (^)(NSArray* indexPaths))success
                         failure:(void (^)(NSError* error))failure;

- (OPImageItem*)itemAtIndexPath:(NSIndexPath*)indexPath;

- (void) clearData;

- (void) cancelRequestAtIndexPath:(NSIndexPath*)indexPath;

//- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;

@end
