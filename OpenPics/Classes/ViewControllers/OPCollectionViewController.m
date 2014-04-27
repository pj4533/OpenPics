//
//  OPCollectionViewController.m
//  OpenPics
//
//  Created by PJ Gray on 3/22/14.
//  Copyright (c) 2014 Say Goodnight Software. All rights reserved.
//

#import "OPCollectionViewController.h"
#import "OPProvider.h"
#import "OPProviderController.h"
#import "OPContentCell.h"
#import "OPImageManager.h"
#import "SVProgressHUD.h"
#import "OPNavigationControllerDelegate.h"

@interface OPCollectionViewController () <UINavigationControllerDelegate> {
//    NSString* _currentQueryString;
//    
//    UIPopoverController* _popover;
//    
//    BOOL _isSearching;
//    
//    BOOL _firstAppearance;
    
    OPImageManager* _imageManager;
}

@end

@implementation OPCollectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.delegate = [OPNavigationControllerDelegate shared];
    
    self.items = [NSMutableArray array];
    self.currentProvider = [[OPProviderController shared] getFirstProvider];
    
//    self.flowLayout = [[SGSStaggeredFlowLayout alloc] init];
//    self.flowLayout.minimumLineSpacing = 2.0f;
//    self.flowLayout.minimumInteritemSpacing = 2.0f;
//    self.flowLayout.sectionInset = UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f);
//    self.singleImageLayout = [[OPSingleImageLayout alloc] init];
//    
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
//        self.flowLayout.itemSize = CGSizeMake(75.0f, 75.0f);
//        self.flowLayout.headerReferenceSize = CGSizeMake(320.0f, 86.0f);
//        self.singleImageLayout.headerReferenceSize = CGSizeMake(320.0f, 86.0f);
//    } else {
//        self.flowLayout.itemSize = CGSizeMake(200.0f, 200.0f);
//        self.flowLayout.headerReferenceSize = CGSizeMake(1024.0f, 149.0f);
//        self.singleImageLayout.headerReferenceSize = CGSizeMake(1024.0f, 149.0f);
//    }
//    
//    _firstAppearance = YES;
    _imageManager = [[OPImageManager alloc] init];
    _imageManager.delegate = self;
    
//    self.internalCollectionView.collectionViewLayout = self.flowLayout;
//    
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
//        [self.internalCollectionView registerNib:[UINib nibWithNibName:@"OPContentCell_iPhone" bundle:nil] forCellWithReuseIdentifier:@"generic"];
//        [self.internalCollectionView registerNib:[UINib nibWithNibName:@"OPHeaderReusableView_iPhone" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
//    } else {
//        [self.internalCollectionView registerNib:[UINib nibWithNibName:@"OPContentCell" bundle:nil] forCellWithReuseIdentifier:@"generic"];
//        [self.internalCollectionView registerNib:[UINib nibWithNibName:@"OPHeaderReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
//    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Loading Data Helper Functions

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

- (void) loadInitialPageWithItems:(NSArray*) items {
    [self.collectionView scrollRectToVisible:CGRectMake(0.0, 0.0, 1, 1) animated:NO];
    
    [SVProgressHUD dismiss];
    self.items = [items mutableCopy];
    [self.collectionView reloadData];
}

- (void) getMoreItems {
    _canLoadMore = NO;
    _isSearching = YES;
    OPProvider* providerSearched = self.currentProvider;
    [self.currentProvider getItemsWithQuery:_currentQueryString withPageNumber:_currentPage success:^(NSArray *items, BOOL canLoadMore) {
        if ([_currentPage isEqual:@1]) {
            _canLoadMore = canLoadMore;
            _isSearching = NO;
            [self loadInitialPageWithItems:items];
        } else {
            NSInteger offset = [self.items count];
            
            // TODO: use performBatch when bug is fixed in UICollectionViews with headers
            NSMutableArray* indexPaths = [NSMutableArray array];
            for (int i = 0; i < items.count; i++) {
                [indexPaths addObject:[NSIndexPath indexPathForItem:i+offset inSection:0]];
            }
            
            [SVProgressHUD dismiss];
            _isSearching = NO;
            if ([providerSearched.providerType isEqualToString:self.currentProvider.providerType]) {
                [self.items addObjectsFromArray:items];
                [self.collectionView insertItemsAtIndexPaths:indexPaths];
            }
            _canLoadMore = canLoadMore;
            
        }
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"Search failed."];
    }];
}

#pragma mark - OPImageManagerDelegate

- (BOOL) isVisibileIndexPath:(NSIndexPath*) indexPath {
    for (NSIndexPath* thisIndexPath in self.collectionView.indexPathsForVisibleItems) {
        if (indexPath.item == thisIndexPath.item) {
            return YES;
        }
    }
    
    return NO;
}

- (void) invalidateLayout {
    [self.collectionView.collectionViewLayout invalidateLayout];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    return [self.items count]+1;
}

//- (UICollectionReusableView*) collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
//    
//    OPHeaderReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"header" forIndexPath:indexPath];
//    
//    header.delegate = self;
//    
//    [header.providerButton setTitle:self.currentProvider.providerName forState:UIControlStateNormal];
//    
//    return header;
//}

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
    
    if (indexPath.item == self.items.count) {
        if (self.items.count) {
            if (_canLoadMore) {
                NSInteger currentPageInt = [_currentPage integerValue];
                _currentPage = [NSNumber numberWithInteger:currentPageInt+1];
                [self getMoreItems];
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
    
    OPImageItem* item = self.items[indexPath.item];
    
    //    cell.mainViewController = self;
    cell.provider = self.currentProvider;
    cell.item = item;
    cell.indexPath = indexPath;
    cell.internalScrollView.userInteractionEnabled = NO;
    cell.delegate = self;

    if ([cv.collectionViewLayout class] == [UICollectionViewFlowLayout class]) {
        [_imageManager loadImageFromItem:item toImageView:cell.internalScrollView.imageView atIndexPath:indexPath withContentMode:UIViewContentModeScaleAspectFit];
        [cell setupForSingleImageLayoutAnimated:NO];
    } else {
        [_imageManager loadImageFromItem:item toImageView:cell.internalScrollView.imageView atIndexPath:indexPath withContentMode:UIViewContentModeScaleAspectFill];
    }
    
    return cell;
}

@end
