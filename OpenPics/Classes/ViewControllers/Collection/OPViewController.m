//
//  OPViewController.m
//  OpenPics
//
//  Created by PJ Gray on 4/6/13.
// 
// Copyright (c) 2013 Say Goodnight Software
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


#import "OPViewController.h"
#import "OPImageItem.h"
#import "OPContentCell.h"
#import "OPProvider.h"
#import "OPProviderController.h"
#import "OPHeaderReusableView.h"
#import "OPProviderListViewController.h"
#import "SVProgressHUD.h"
#import "TMCache.h"
#import "UIImage+Preload.h"
#import "NSString+MD5.h"
#import "AFHTTPRequestOperation.h"

@interface OPViewController () {
    BOOL _canLoadMore;

    NSNumber* _currentPage;
    NSString* _currentQueryString;

    UIPopoverController* _popover;
    
    BOOL _isSearching;
        
    BOOL _firstAppearance;
}
@end

@implementation OPViewController

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.items = [NSMutableArray array];
        self.currentProvider = [[OPProviderController shared] getFirstProvider];

        self.flowLayout = [[SGSStaggeredFlowLayout alloc] init];
        self.flowLayout.minimumLineSpacing = 2.0f;
        self.flowLayout.minimumInteritemSpacing = 2.0f;
        self.flowLayout.sectionInset = UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f);
        self.singleImageLayout = [[OPSingleImageLayout alloc] init];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            self.flowLayout.itemSize = CGSizeMake(75.0f, 75.0f);
            self.flowLayout.headerReferenceSize = CGSizeMake(320.0f, 117.0f);
            self.singleImageLayout.headerReferenceSize = CGSizeMake(320.0f, 117.0f);
        } else {
            self.flowLayout.itemSize = CGSizeMake(200.0f, 200.0f);
            self.flowLayout.headerReferenceSize = CGSizeMake(1024.0f, 169.0f);
            self.singleImageLayout.headerReferenceSize = CGSizeMake(1024.0f, 169.0f);
        }    

        _firstAppearance = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];

    self.internalCollectionView.collectionViewLayout = self.flowLayout;

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self.internalCollectionView registerNib:[UINib nibWithNibName:@"OPContentCell_iPhone" bundle:nil] forCellWithReuseIdentifier:@"generic"];
        [self.internalCollectionView registerNib:[UINib nibWithNibName:@"OPHeaderReusableView_iPhone" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
    } else {
        [self.internalCollectionView registerNib:[UINib nibWithNibName:@"OPContentCell" bundle:nil] forCellWithReuseIdentifier:@"generic"];
        [self.internalCollectionView registerNib:[UINib nibWithNibName:@"OPHeaderReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
    }
}

- (void) viewDidAppear:(BOOL)animated {
    if (_firstAppearance) {
        _firstAppearance = NO;
        // if we are appearing for the first time and we don't have any items, the do an initial search on the current provider
        // this allows for the provider to give us a more passive experience by showing some images, rather than a blank
        // screen.
        //
#warning revisit this after removing map?
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
    NSLog(@"WILL ROTATE: %@", NSStringFromCGSize(self.internalCollectionView.frame.size));
    
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    NSLog(@"DID ROTATE: %@", NSStringFromCGSize(self.internalCollectionView.frame.size));
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    [self.internalCollectionView.collectionViewLayout invalidateLayout];
    self.singleImageLayout.itemSize = CGSizeMake(self.internalCollectionView.frame.size.width, self.internalCollectionView.frame.size.height);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Loading image helper functions

- (BOOL) isCellVisibleAtIndexPath:(NSIndexPath*) indexPath {
    for (NSIndexPath* thisIndexPath in self.internalCollectionView.indexPathsForVisibleItems) {
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
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFImageResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        UIImage* image = (UIImage*) responseObject;
        
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
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
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
                            [self.internalCollectionView.collectionViewLayout invalidateLayout];
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
    [self.internalCollectionView reloadData];
    [self.flowLayout invalidateLayout];
    
    [self doInitialSearch];
}

- (void) loadInitialPageWithItems:(NSArray*) items {
    [self.internalCollectionView scrollRectToVisible:CGRectMake(0.0, 0.0, 1, 1) animated:NO];

    [SVProgressHUD dismiss];
    self.items = [items mutableCopy];
    [self.internalCollectionView reloadData];
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
                [self.internalCollectionView insertItemsAtIndexPaths:indexPaths];
            }
            _canLoadMore = canLoadMore;
            
        }
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"Search failed."];
    }];
}

#pragma mark - Switching layout helper functions

- (void) switchToGridWithIndexPath:(NSIndexPath*) indexPath {
    self.internalCollectionView.scrollEnabled = YES;
    
    [self.flowLayout invalidateLayout];
    [self.internalCollectionView setCollectionViewLayout:self.flowLayout animated:YES];
    OPContentCell* cell = (OPContentCell*) [self.internalCollectionView cellForItemAtIndexPath:indexPath];
    [cell setupForGridLayout];
    
    [self.internalCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
}

- (void) switchToSingleImageWithIndexPath:(NSIndexPath*) indexPath {
    self.singleImageLayout.itemSize = CGSizeMake(self.internalCollectionView.frame.size.width, self.internalCollectionView.frame.size.height);
    
    self.internalCollectionView.scrollEnabled = NO;
    [self.singleImageLayout invalidateLayout];
    [self.internalCollectionView setCollectionViewLayout:self.singleImageLayout animated:YES];
    OPContentCell* cell = (OPContentCell*) [self.internalCollectionView cellForItemAtIndexPath:indexPath];
    [cell setupForSingleImageLayoutAnimated:NO];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (collectionViewLayout == self.flowLayout) {
        CGSize cellSize = self.flowLayout.itemSize;
        
        CGSize imageSize = CGSizeZero;
        if (indexPath.item < self.items.count) {
            OPImageItem* item = self.items[indexPath.item];
            if (item.size.height) {
                imageSize = item.size;
            }
            
            if (imageSize.height) {
                CGFloat deviceCellSizeConstant = self.flowLayout.itemSize.height;
                CGFloat newWidth = (imageSize.width*deviceCellSizeConstant)/imageSize.height;
                CGFloat maxWidth = self.internalCollectionView.frame.size.width - self.flowLayout.sectionInset.left - self.flowLayout.sectionInset.right;
                if (newWidth > maxWidth) {
                    newWidth = maxWidth;
                }
                cellSize = CGSizeMake(newWidth, deviceCellSizeConstant);
            }
        }

        return cellSize;
    }
    
    return self.singleImageLayout.itemSize;
}

#pragma mark - UICollectionViewDelegate

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (!self.items.count) {
        return;
    }
    
    [self.view endEditing:YES];
    
    if (self.internalCollectionView.collectionViewLayout == self.singleImageLayout) {
        [self switchToGridWithIndexPath:indexPath];
    } else {
        [self switchToSingleImageWithIndexPath:indexPath];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    return [self.items count]+1;
}

- (UICollectionReusableView*) collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    OPHeaderReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"header" forIndexPath:indexPath];
    
    header.delegate = self;

    [header.providerButton setTitle:self.currentProvider.providerName forState:UIControlStateNormal];

    return header;
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
    
    cell.internalScrollView.imageView.image = nil;
    
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
    
    cell.mainViewController = self;
    cell.provider = self.currentProvider;
    cell.item = item;
    cell.indexPath = indexPath;
    cell.internalScrollView.userInteractionEnabled = NO;
    
    [self loadImageFromItem:item intoImageView:cell.internalScrollView.imageView atIndexPath:indexPath];
    
    return cell;
}

#pragma mark - OPHeaderDelegate

- (void) providerTappedFromRect:(CGRect) rect inView:(UIView *)view{
    if (_popover) {
        [_popover dismissPopoverAnimated:YES];
    }
    
    
    OPProviderListViewController* providerListViewController = [[OPProviderListViewController alloc] initWithNibName:@"OPProviderListViewController" bundle:nil];
    providerListViewController.delegate = self;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self presentViewController:providerListViewController animated:YES completion:nil];
    } else {
        _popover = [[UIPopoverController alloc] initWithContentViewController:providerListViewController];
        [_popover presentPopoverFromRect:[view convertRect:rect toView:self.view] inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

- (void) doSearchWithQuery:(NSString *)queryString {
    _canLoadMore = NO;
    _currentPage = [NSNumber numberWithInteger:1];
    _currentQueryString = queryString;
    self.items = [@[] mutableCopy];
    [self.internalCollectionView reloadData];
    [self.flowLayout invalidateLayout];

    [SVProgressHUD showWithStatus:@"Searching..." maskType:SVProgressHUDMaskTypeClear];
    [self getMoreItems];
}

#pragma mark - OPProviderListDelegate

- (void) tappedProvider:(OPProvider *)provider {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [_popover dismissPopoverAnimated:YES];
    }
    
    self.currentProvider = provider;
    _canLoadMore = NO;
    _isSearching = NO;
    _currentPage = [NSNumber numberWithInteger:1];
    _currentQueryString = @"";
    self.items = [@[] mutableCopy];
    [self.internalCollectionView reloadData];
    [self.flowLayout invalidateLayout];
    [self doInitialSearch];
}

#pragma mark - DERPIN

-(void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake ) {
        [self.view endEditing:YES];
        
        NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
        NSNumber* uprezMode = [currentDefaults objectForKey:@"uprezMode"];
        if (uprezMode && uprezMode.boolValue) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"BOOM!"
                                                            message:@"Exiting full uprez mode."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            [currentDefaults setObject:[NSNumber numberWithBool:NO] forKey:@"uprezMode"];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"BOOM!"
                                                            message:@"Entering full uprez mode."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            [currentDefaults setObject:[NSNumber numberWithBool:YES] forKey:@"uprezMode"];
        }
        [currentDefaults synchronize];
    }
}

@end
