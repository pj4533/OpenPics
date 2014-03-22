//
//  OPCollectionViewController.m
//  OpenPics
//
//  Created by PJ Gray on 3/22/14.
//  Copyright (c) 2014 Say Goodnight Software. All rights reserved.
//

#import "OPRootCollectionViewController.h"
#import "OPImageCollectionViewController.h"
#import "SVProgressHUD.h"
#import "OPProvider.h"

@interface OPRootCollectionViewController () {
    BOOL _canLoadMore;
    
    NSNumber* _currentPage;
}

@end

@implementation OPRootCollectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self doInitialSearch];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    OPImageCollectionViewController* imageVC = (OPImageCollectionViewController*) segue.destinationViewController;
    imageVC.useLayoutToLayoutNavigationTransitions = YES;
    imageVC.items = self.items;
    imageVC.currentProvider = self.currentProvider;
}

#pragma mark - Loading Data Helper Functions

//- (void) forceReload {
//    _canLoadMore = NO;
//    _currentPage = [NSNumber numberWithInteger:1];
//    _currentQueryString = @"";
//    self.items = [@[] mutableCopy];
//    [self.internalCollectionView reloadData];
//    [self.flowLayout invalidateLayout];
//    
//    [self doInitialSearch];
//}
//
- (void) loadInitialPageWithItems:(NSArray*) items {
    [self.collectionView scrollRectToVisible:CGRectMake(0.0, 0.0, 1, 1) animated:NO];
    
    [SVProgressHUD dismiss];
    self.items = [items mutableCopy];
    [self.collectionView reloadData];
}

- (void) doInitialSearch {
    if (self.currentProvider.supportsInitialSearching) {
        _currentPage = [NSNumber numberWithInteger:1];
        [SVProgressHUD showWithStatus:@"Searching..." maskType:SVProgressHUDMaskTypeClear];
        [self.currentProvider doInitialSearchWithSuccess:^(NSArray *items, BOOL canLoadMore) {
            _canLoadMore = canLoadMore;
            [self loadInitialPageWithItems:items];
        } failure:^(NSError *error) {
            [SVProgressHUD showErrorWithStatus:@"Search failed."];
        }];
    }
}

//- (void) getMoreItems {
//    _canLoadMore = NO;
//    _isSearching = YES;
//    OPProvider* providerSearched = self.currentProvider;
//    [self.currentProvider getItemsWithQuery:_currentQueryString withPageNumber:_currentPage success:^(NSArray *items, BOOL canLoadMore) {
//        if ([_currentPage isEqual:@1]) {
//            _canLoadMore = canLoadMore;
//            _isSearching = NO;
//            [self loadInitialPageWithItems:items];
//        } else {
//            NSInteger offset = [self.items count];
//            
//            // TODO: use performBatch when bug is fixed in UICollectionViews with headers
//            NSMutableArray* indexPaths = [NSMutableArray array];
//            for (int i = 0; i < items.count; i++) {
//                [indexPaths addObject:[NSIndexPath indexPathForItem:i+offset inSection:0]];
//            }
//            
//            [SVProgressHUD dismiss];
//            _isSearching = NO;
//            if ([providerSearched.providerType isEqualToString:self.currentProvider.providerType]) {
//                [self.items addObjectsFromArray:items];
//                [self.internalCollectionView insertItemsAtIndexPaths:indexPaths];
//            }
//            _canLoadMore = canLoadMore;
//            
//        }
//    } failure:^(NSError *error) {
//        [SVProgressHUD showErrorWithStatus:@"Search failed."];
//    }];
//}

//#pragma mark - UICollectionViewDelegateFlowLayout
//
//- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    
//    if (collectionViewLayout == self.flowLayout) {
//        CGSize cellSize = self.flowLayout.itemSize;
//        
//        CGSize imageSize = CGSizeZero;
//        if (indexPath.item < self.items.count) {
//            OPImageItem* item = self.items[indexPath.item];
//            if (item.size.height) {
//                imageSize = item.size;
//            }
//            
//            if (imageSize.height) {
//                CGFloat deviceCellSizeConstant = self.flowLayout.itemSize.height;
//                CGFloat newWidth = (imageSize.width*deviceCellSizeConstant)/imageSize.height;
//                CGFloat maxWidth = self.internalCollectionView.frame.size.width - self.flowLayout.sectionInset.left - self.flowLayout.sectionInset.right;
//                if (newWidth > maxWidth) {
//                    newWidth = maxWidth;
//                }
//                cellSize = CGSizeMake(newWidth, deviceCellSizeConstant);
//            }
//        }
//        
//        return cellSize;
//    }
//    
//    return self.singleImageLayout.itemSize;
//}
//
//#pragma mark - UICollectionViewDelegate
//
//- (void) collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
//    if ([collectionView.indexPathsForVisibleItems indexOfObject:indexPath] == NSNotFound) {
//        [_imageManager cancelImageOperationAtIndexPath:indexPath];
//    }
//}
//
//- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    
//    if (!self.items.count) {
//        return;
//    }
//    
//    [self.view endEditing:YES];
//    
//    if (self.internalCollectionView.collectionViewLayout == self.singleImageLayout) {
//        [self switchToGridWithIndexPath:indexPath];
//    } else {
//        [self switchToSingleImageWithIndexPath:indexPath];
//    }
//}


@end
