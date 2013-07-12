//
//  OPMainCollectionViewController.m
//  OpenPics
//
//  Created by PJ Gray on 6/11/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import "OPMainCollectionViewController.h"
#import "OPImageItem.h"
#import "OPGridCell.h"
#import "AFImageRequestOperation.h"
#import "AFNetworking.h"
#import "OPProvider.h"
#import "OPProviderController.h"
//#import "OPHeaderReusableView.h"
//#import "OPProviderListViewController.h"
//#import "OPMapViewController.h"
#import "SVProgressHUD.h"
#import "TMCache.h"
#import "UIImage+Preload.h"
#import "NSString+MD5.h"
#import "OPSingleImageCollectionViewController.h"

@interface OPMainCollectionViewController () {
    BOOL _canLoadMore;
    
    NSNumber* _currentPage;
    NSString* _currentQueryString;
    
    UIPopoverController* _popover;
    
    BOOL _isSearching;
    BOOL _firstAppearance;
    
    UISearchBar* _searchBar;
}
@end

@implementation OPMainCollectionViewController

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    self.items = [NSMutableArray array];
    self.currentProvider = [[OPProviderController shared] getFirstProvider];
    
    self.flowLayout = (SGSStaggeredFlowLayout*) self.collectionView.collectionViewLayout;
    self.flowLayout.minimumLineSpacing = 2.0f;
    self.flowLayout.minimumInteritemSpacing = 2.0f;
    self.flowLayout.sectionInset = UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f);
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.flowLayout.itemSize = CGSizeMake(75.0f, 75.0f);
    } else {
        self.flowLayout.itemSize = CGSizeMake(200.0f, 200.0f);
    }

    
    self.sourceBarButtonItem.title = [NSString stringWithFormat:@"Source: %@", self.currentProvider.providerName];
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    _searchBar.placeholder = @"Enter Search Terms...";
    _searchBar.delegate = self;
    self.navigationItem.titleView = _searchBar;
    
    
    _firstAppearance = YES;
    
    
//    self.collectionView.collectionViewLayout = self.flowLayout;
    
    //    [self.collectionView registerClass:[OPContentCell class] forCellWithReuseIdentifier:@"generic"];
    //    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    //        [self.collectionView registerNib:[UINib nibWithNibName:@"OPContentCell_iPhone" bundle:nil] forCellWithReuseIdentifier:@"generic"];
    //        [self.collectionView registerNib:[UINib nibWithNibName:@"OPHeaderReusableView_iPhone" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
    //    } else {
    //        [self.collectionView registerNib:[UINib nibWithNibName:@"OPContentCell" bundle:nil] forCellWithReuseIdentifier:@"generic"];
    //        [self.collectionView registerNib:[UINib nibWithNibName:@"OPHeaderReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
    //    }
}


- (void) viewDidAppear:(BOOL)animated {
    if (_firstAppearance) {
        _firstAppearance = NO;
        // if we are appearing for the first time and we don't have any items, the do an initial search on the current provider
        // this allows for the provider to give us a more passive experience by showing some images, rather than a blank
        // screen.
        //
        // if we DO have items, skip it, as this means that we were likely called from the map.
        //
        // i had this in viewDidLoad and got a weird error on app launch:
        //    Application windows are expected to have a root view controller at the end of application launch
        if (self.items.count) {
            [self loadInitialPageWithItems:self.items];
        } else {
            [self doInitialSearch];
        }
    }
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    NSLog(@"WILL ROTATE: %@", NSStringFromCGSize(self.collectionView.frame.size));
    
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    NSLog(@"DID ROTATE: %@", NSStringFromCGSize(self.collectionView.frame.size));
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    [self.collectionView.collectionViewLayout invalidateLayout];
    //    self.singleImageLayout.itemSize = CGSizeMake(self.collectionView.frame.size.width, self.collectionView.frame.size.height);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString:@"singleImageSegue"]){
        
        OPGridCell* cell = (OPGridCell*) sender;
        NSIndexPath*  indexPath = [self.collectionView indexPathForCell:cell];
        
        OPSingleImageCollectionViewController *singleImage = (OPSingleImageCollectionViewController *)[segue destinationViewController];
        singleImage.items = self.items;
        singleImage.indexPath = indexPath;

//        singleImage.useLayoutToLayoutNavigationTransitions = YES;
    } else if([[segue identifier] isEqualToString:@"sourceButtonSegue"]){
        OPProviderTableViewController *providerTable = (OPProviderTableViewController *)[segue destinationViewController];
        providerTable.modalPresentationStyle = UIModalPresentationFormSheet;
        providerTable.delegate = self;
        
    }
}
#pragma mark - Loading image helper functions

- (BOOL) isCellVisibleAtIndexPath:(NSIndexPath*) indexPath {
    for (NSIndexPath* thisIndexPath in self.collectionView.indexPathsForVisibleItems) {
        if (indexPath.item == thisIndexPath.item) {
            return YES;
        }
    }
    
    return NO;
}

- (void) fadeInHourglassToImageView:(UIImageView*) imageView withCompletion:(void (^)(void))completion {
    imageView.alpha = 0.0f;
    
    // First, go to the main thread and set the imageview to hourglass, start with alpha at 0?
    dispatch_async(dispatch_get_main_queue(), ^{
        imageView.contentMode = UIViewContentModeCenter;
        imageView.image = [UIImage imageNamed:@"hourglass_white"];
        
        if (completion) {
            completion();
        }
        
        // fade in the hourglass
        [UIView animateWithDuration:0.5 animations:^{
            imageView.alpha = 1.0;
        }];
    });
}

- (void) getImageFromCacheWithItem:(OPImageItem*) item withCompletion:(void (^)(UIImage* cachedImage))completion {
    // If found in cache, load the image
    UIImage* cacheImage = [[TMCache sharedCache] objectForKey:item.imageUrl.absoluteString.MD5String];
    
    // Use the category to get the preloaded image (will check for associated object)
    cacheImage = cacheImage.preloadedImage;
    if (completion) {
        completion(cacheImage);
    }
}

- (void) getImageWithRequestForItem:(OPImageItem*) item
                        withSuccess:(void (^)(UIImage* image))success
                        withFailure:(void (^)(void))failure {
    // if not found in cache, create request to download image
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:item.imageUrl];
    AFImageRequestOperation* operation = [AFImageRequestOperation imageRequestOperationWithRequest:request imageProcessingBlock:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        
        // if this item url is equal to the request one - continue (avoids flashyness on fast scrolling)
        if ([item.imageUrl.absoluteString isEqualToString:request.URL.absoluteString]) {
            
            // dispatch to a background thread for preloading
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                // uses category - will check for assocaited object
                UIImage* preloadedImage = image.preloadedImage;
                
                // set the loaded object to the cache
                [[TMCache sharedCache] setObject:preloadedImage forKey:item.imageUrl.absoluteString.MD5String];
                
                if (success) {
                    success(preloadedImage);
                }
            });
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"error getting image");
        if (failure) {
            failure();
        }
    }];
    [operation start];
}

- (void) getImageForItem:(OPImageItem*) item
             withSuccess:(void (^)(UIImage* image))success
             withFailure:(void (^)(void))failure {
    // Then, dispatch async to another thread to check the cache for this image (might read from disk which is slow while scrolling
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        if ([[TMCache sharedCache] objectForKey:item.imageUrl.absoluteString.MD5String]) {
            [self getImageFromCacheWithItem:item withCompletion:success];
        } else {
            [self getImageWithRequestForItem:item withSuccess:success withFailure:failure];
        }
    });
}

// this loads an image to an imageview in a cell.  called from cellForIndexPath
- (void) loadImageFromItem:(OPImageItem*) item intoImageView:(UIImageView*) imageView atIndexPath:(NSIndexPath*) indexPath {
    [self fadeInHourglassToImageView:imageView withCompletion:^{
        [self getImageForItem:item withSuccess:^(UIImage *image) {
            // if this cell is currently visible, continue drawing - this is for when scrolling fast (avoids flashyness)
            if ([self isCellVisibleAtIndexPath:indexPath]) {
                
                // then dispatch back to the main thread to set the image
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    // fade out the hourglass image
                    [UIView animateWithDuration:0.25 animations:^{
                        imageView.alpha = 0.0;
                    } completion:^(BOOL finished) {
                        imageView.contentMode = UIViewContentModeScaleAspectFill;
                        imageView.image = image;
                        
                        // fade in image
                        [UIView animateWithDuration:0.5 animations:^{
                            imageView.alpha = 1.0;
                        }];
                        
                        // if we have no size information yet, save the information in item, and force a re-layout
                        if (!item.size.height) {
                            item.size = image.size;
                            [self.collectionView.collectionViewLayout invalidateLayout];
                        }
                    }];
                });
            }
        } withFailure:^{
            [UIView animateWithDuration:0.25 animations:^{
                imageView.alpha = 0.0;
            } completion:^(BOOL finished) {
                imageView.image = [UIImage imageNamed:@"image_cancel"];
                [UIView animateWithDuration:0.5 animations:^{
                    imageView.alpha = 1.0;
                }];
            }];
        }];
    }];
}

#pragma mark - Loading Data Helper Functions

- (void) forceReload {
    _canLoadMore = NO;
    _currentPage = [NSNumber numberWithInteger:1];
    _currentQueryString = @"";
    self.items = [@[] mutableCopy];
    [self.collectionView reloadData];
    [self.flowLayout invalidateLayout];
    [self doInitialSearch];
}

- (void) loadInitialPageWithItems:(NSArray*) items {
    [self.collectionView scrollRectToVisible:CGRectMake(0.0, 0.0, 1, 1) animated:NO];
    
    // TODO: use performBatch when bug is fixed in UICollectionViews with headers
    NSMutableArray* indexPaths = [NSMutableArray array];
    for (int i = 0; i < items.count; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForItem:i inSection:0]];
    }
    
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

#pragma mark - Switching layout helper functions

- (void) switchToGridWithIndexPath:(NSIndexPath*) indexPath {
    //    self.collectionView.scrollEnabled = YES;
    //
    //    [self.flowLayout invalidateLayout];
    //    [self.collectionView setCollectionViewLayout:self.flowLayout animated:YES];
    //    OPContentCell* cell = (OPContentCell*) [self.collectionView cellForItemAtIndexPath:indexPath];
    //    [cell setupForGridLayout];
    //
    //    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
    //}
    //
    //- (void) switchToSingleImageWithIndexPath:(NSIndexPath*) indexPath {
    //    self.singleImageLayout.itemSize = CGSizeMake(self.collectionView.frame.size.width, self.collectionView.frame.size.height);
    //
    //    self.collectionView.scrollEnabled = NO;
    //    [self.singleImageLayout invalidateLayout];
    //    [self.collectionView setCollectionViewLayout:self.singleImageLayout animated:YES];
    //    OPContentCell* cell = (OPContentCell*) [self.collectionView cellForItemAtIndexPath:indexPath];
    //    [cell setupForSingleImageLayoutAnimated:NO];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([collectionViewLayout isKindOfClass:[SGSStaggeredFlowLayout class]]) {
        SGSStaggeredFlowLayout* layout = (SGSStaggeredFlowLayout*) collectionViewLayout;
        CGSize cellSize = layout.itemSize;
        
        CGSize imageSize = CGSizeZero;
        if (indexPath.item < self.items.count) {
            OPImageItem* item = self.items[indexPath.item];
            if (item.size.height) {
                imageSize = item.size;
            }
            
            if (imageSize.height) {
                CGFloat deviceCellSizeConstant = layout.itemSize.height;
                CGFloat newWidth = (imageSize.width*deviceCellSizeConstant)/imageSize.height;
                CGFloat maxWidth = self.collectionView.frame.size.width - layout.sectionInset.left - layout.sectionInset.right;
                if (newWidth > maxWidth) {
                    newWidth = maxWidth;
                }
                cellSize = CGSizeMake(newWidth, deviceCellSizeConstant);
            }
        }
        
        return cellSize;
    }
    
    return CGSizeMake(200,00);//self.singleImageLayout.itemSize;
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
//    if (self.currentProvider.supportsLocationSearching) {
//        header.mapButton.hidden = NO;
//    } else {
//        header.mapButton.hidden = YES;
//    }
//
//    [header.providerButton setTitle:self.currentProvider.providerName forState:UIControlStateNormal];
//
//    return header;
//}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"generic";
    OPGridCell *cell = (OPGridCell*)[cv dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    
    // remove activity indicator if present
    for (UIView* subview in cell.contentView.subviews) {
        if (subview.tag == -1) {
            [subview removeFromSuperview];
        }
    }
    
    cell.imageView.image = nil;
    
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
        
        cell.imageView.image = nil;
        return cell;
    }
    
    
    //    // remove activity indicator if present
    //    for (UIView* subview in cell.contentView.subviews) {
    //        if (subview.tag == -1) {
    //            [subview removeFromSuperview];
    //        }
    //    }
    
    
    OPImageItem* item = self.items[indexPath.item];
    
    //    cell.mainViewController = self;
    //    cell.provider = self.currentProvider;
    //    cell.item = item;
    //    cell.indexPath = indexPath;
    //    cell.internalScrollView.userInteractionEnabled = NO;
    //    [self loadImageFromItem:item intoImageView:cell.internalScrollView.imageView atIndexPath:indexPath];
    
    [self loadImageFromItem:item intoImageView:cell.imageView atIndexPath:indexPath];
    
    return cell;
}

#pragma mark - OPHeaderDelegate

- (void) flipToMap {
    //    OPMapViewController* mapViewController;
    //
    //    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    //        mapViewController = [[OPMapViewController alloc] initWithNibName:@"OPMapViewController_iPhone" bundle:nil];
    //    } else {
    //        mapViewController = [[OPMapViewController alloc] initWithNibName:@"OPMapViewController" bundle:nil];
    //    }
    //
    //    mapViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    //    mapViewController.provider = self.currentProvider;
    //    [self presentViewController:mapViewController animated:YES completion:nil];
}

//- (void) providerTappedFromRect:(CGRect) rect inView:(UIView *)view{
//    //    if (_popover) {
//    //        [_popover dismissPopoverAnimated:YES];
//    //    }
//    //
//    //
//    //    OPProviderListViewController* providerListViewController = [[OPProviderListViewController alloc] initWithNibName:@"OPProviderListViewController" bundle:nil];
//    //    providerListViewController.delegate = self;
//    //
//    //    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
//    //        [self presentViewController:providerListViewController animated:YES completion:nil];
//    //    } else {
//    //        _popover = [[UIPopoverController alloc] initWithContentViewController:providerListViewController];
//    //        [_popover presentPopoverFromRect:[view convertRect:rect toView:self.view] inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
//    //    }
//}

- (void) doSearchWithQuery:(NSString *)queryString {
    _canLoadMore = NO;
    _currentPage = [NSNumber numberWithInteger:1];
    _currentQueryString = queryString;
    self.items = [@[] mutableCopy];
    [self.collectionView reloadData];
    [self.flowLayout invalidateLayout];
    
    [SVProgressHUD showWithStatus:@"Searching..." maskType:SVProgressHUDMaskTypeClear];
    [self getMoreItems];
}

#pragma mark - OPProviderTableDelegate

- (void) tappedProvider:(OPProvider *)provider {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    self.currentProvider = provider;
    self.sourceBarButtonItem.title = [NSString stringWithFormat:@"Source: %@", self.currentProvider.providerName];

    _canLoadMore = NO;
    _isSearching = NO;
    _currentPage = [NSNumber numberWithInteger:1];
    _currentQueryString = @"";
    self.items = [@[] mutableCopy];
    [self.collectionView reloadData];
    [self.flowLayout invalidateLayout];
    [self doInitialSearch];
}

#pragma mark - DERPIN

-(void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake ) {
        [self.view endEditing:YES];
        
        NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
        NSNumber* uprezMode = [currentDefaults objectForKey:@"uprezMode"];
#warning FIX UPREZ MODE ALERTS
        if (uprezMode && uprezMode.boolValue) {
            
//            [FUIAlertView showOkayAlertViewWithTitle:@"BOOM!" message:@"Exiting full uprez mode." andDelegate:nil];
//            [currentDefaults setObject:[NSNumber numberWithBool:NO] forKey:@"uprezMode"];
        } else {
//            [FUIAlertView showOkayAlertViewWithTitle:@"BOOM!" message:@"Entering full uprez mode." andDelegate:nil];
//            [currentDefaults setObject:[NSNumber numberWithBool:YES] forKey:@"uprezMode"];
        }
        [currentDefaults synchronize];
    }
}


#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}


-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [self doSearchWithQuery:searchBar.text];
}

@end
