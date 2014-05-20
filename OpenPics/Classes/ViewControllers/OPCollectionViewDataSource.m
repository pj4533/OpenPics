//
//  OPCollectionViewDataSource.m
//  OpenPics
//
//  Created by PJ Gray on 5/4/14.
//  Copyright (c) 2014 Say Goodnight Software. All rights reserved.
//

#import "OPCollectionViewDataSource.h"
#import "OPContentCell.h"
#import "OPProviderController.h"
#import "OPProvider.h"
#import "OPImageManager.h"
#import "OPImageCollectionViewController.h"
#import "OPNavigationControllerDelegate.h"
#import "SGSStaggeredFlowLayout.h"

@interface OPCollectionViewDataSource () <OPContentCellDelegate> {
    NSNumber* _currentPage;
    BOOL _canLoadMore;
    BOOL _isSearching;
    NSMutableArray* _items;
    OPImageManager* _imageManager;
}

@end

@implementation OPCollectionViewDataSource

- (instancetype) init {
    self = [super init];
    if (self) {
        _items = [NSMutableArray array];
        _isSearching = NO;
        _currentQueryString = @"";

        _imageManager = [[OPImageManager alloc] init];
        _imageManager.delegate = self;
    }
    return self;
}

- (void) clearData {
    _canLoadMore = NO;
    _currentPage = [NSNumber numberWithInteger:1];
    _items = [@[] mutableCopy];
}

- (void) doInitialSearchWithSuccess:(void (^)(NSArray* items, BOOL canLoadMore))success
                            failure:(void (^)(NSError* error))failure {
    OPProvider* selectedProvider = [[OPProviderController shared] getSelectedProvider];
    _currentPage = [NSNumber numberWithInteger:1];
    [selectedProvider doInitialSearchWithSuccess:^(NSArray *items, BOOL canLoadMore) {
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
    _isSearching = YES;
    OPProvider* selectedProvider = [[OPProviderController shared] getSelectedProvider];
    [selectedProvider getItemsWithQuery:self.currentQueryString withPageNumber:_currentPage success:^(NSArray *items, BOOL canLoadMore) {
        if ([_currentPage isEqual:@1]) {
            _canLoadMore = canLoadMore;
            _isSearching = NO;
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
                        _isSearching = NO;
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

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    return [_items count]+1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"generic";
    OPContentCell *cell = (OPContentCell *)[cv dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    // remove activity indicator if present
    for (UIView* subview in cell.contentView.subviews) {
        if (subview.tag == -1) {
            [subview removeFromSuperview];
        }
    }
    
    cell.internalScrollView.imageView.image = [UIImage imageNamed:@"transparent"];
    cell.provider = nil;
    cell.item = nil;
    cell.indexPath = nil;
    
    if (indexPath.item == _items.count) {
        if (_items.count) {
            if (_canLoadMore) {
                NSInteger currentPageInt = [_currentPage integerValue];
                _currentPage = [NSNumber numberWithInteger:currentPageInt+1];
                [self getMoreItemsWithSuccess:^(NSArray *indexPaths) {
                    [cv insertItemsAtIndexPaths:indexPaths];
                } failure:nil];
            }
            
            if (_isSearching) {
                UIActivityIndicatorView* activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
                activity.center = CGPointMake(100.0f, 100.0f);
                [activity startAnimating];
                activity.tag = -1;
                [cell.contentView addSubview:activity];
            }
        }
        
        cell.internalScrollView.userInteractionEnabled = NO;
        cell.internalScrollView.imageView.image = nil;
        return cell;
    }
    
    OPImageItem* item = _items[indexPath.item];
    
    // remove the IB constraints cause they don't seem to work right - but I don't want them autogenerated
    [cell removeConstraints:cell.constraints];
    
    // set the frame to the contentView frame
    cell.internalScrollView.frame = cell.contentView.frame;
    
    // create constraints from autosizing
    cell.internalScrollView.translatesAutoresizingMaskIntoConstraints = YES;
    [cell.internalScrollView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    
    
    cell.provider = [[OPProviderController shared] getSelectedProvider];
    cell.item = item;
    cell.indexPath = indexPath;
    cell.internalScrollView.userInteractionEnabled = NO;
    cell.delegate = self;
    
    if ((![cv.collectionViewLayout isKindOfClass:[SGSStaggeredFlowLayout class]]) && ![[OPNavigationControllerDelegate shared] transitioning]) {
        [_imageManager loadImageFromItem:item
                             toImageView:cell.internalScrollView.imageView
                             atIndexPath:indexPath
                        onCollectionView:cv
                         withContentMode:UIViewContentModeScaleAspectFit];
        [cell setupForSingleImageLayoutAnimated:NO];
    } else {
        [_imageManager loadImageFromItem:item
                             toImageView:cell.internalScrollView.imageView
                             atIndexPath:indexPath
                        onCollectionView:cv
                         withContentMode:UIViewContentModeScaleAspectFill];
    }
    
    return cell;
}

#pragma mark OPContentCellDelegate

- (void) singleTappedCell {
    if (self.delegate && [self.delegate respondsToSelector:@selector(singleTappedCell)]) {
        [self.delegate singleTappedCell];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewFlowLayout* flowLayout = (UICollectionViewFlowLayout*) collectionViewLayout;
    CGSize cellSize = flowLayout.itemSize;
    
    if ([collectionViewLayout isKindOfClass:[SGSStaggeredFlowLayout class]]) {
        CGSize imageSize = CGSizeZero;
        if (indexPath.item < _items.count) {
            OPImageItem* item = _items[indexPath.item];
            if (item.size.height) {
                imageSize = item.size;
            }
            
            if (imageSize.height) {
                CGFloat deviceCellSizeConstant = flowLayout.itemSize.height;
                CGFloat newWidth = (imageSize.width*deviceCellSizeConstant)/imageSize.height;
                CGFloat maxWidth = collectionView.frame.size.width - flowLayout.sectionInset.left - flowLayout.sectionInset.right;
                if (newWidth > maxWidth) {
                    newWidth = maxWidth;
                }
                cellSize = CGSizeMake(newWidth, deviceCellSizeConstant);
            }
        }
    }
    
    return cellSize;
    //    }
    //
    //    return self.singleImageLayout.itemSize;
}

@end
