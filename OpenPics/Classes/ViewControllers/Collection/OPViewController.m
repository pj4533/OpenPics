//
//  OPViewController.m
//  OpenPics
//
//  Created by PJ Gray on 4/6/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import "OPViewController.h"
#import "OPImageItem.h"
#import "AFImageRequestOperation.h"
#import "AFNetworking.h"
#import "OPContentCell.h"
#import "OPProvider.h"
#import "OPProviderController.h"
#import "OPHeaderReusableView.h"
#import "OPProviderListViewController.h"
#import "OPMapViewController.h"
#import "SVProgressHUD.h"
#import "TMCache.h"
#import "UIImage+Preload.h"

@interface OPViewController () {
    BOOL _canLoadMore;

    NSInteger _visibleItemAtStartOfRotate;
    
    NSNumber* _currentPage;
    NSString* _currentQueryString;

    UIPopoverController* _popover;
    
    BOOL _isSearching;
    
#warning TODO: memory fix
    // TODO:   save all the sizes here, but put the images in a NSCache, if not in there reload image
    NSMutableDictionary* _loadedImages;
}
@end

@implementation OPViewController

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _loadedImages = [NSMutableDictionary dictionary];
        
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
    
    // if we are in view did load and we don't have any items, the do an initial search on the current provider
    // this allows for the provider to give us a more passive experience by showing some images, rather than a blank
    // screen.
    //
    // if we DO have items, skip it, as this means that we were likely called from the map.
    if (self.items.count) {
        [self loadInitialPageWithItems:self.items];
    } else {
        [self doInitialSearch];
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


#pragma mark - Helpers

// This is the main guts of the image loading for now.  I may want to delay the loading of ALL the images on the
// current page, but I preload here to make this as fast as possible when scrolling and whatnot.
- (void) loadItems:(NSArray*) items forIndexPaths:(NSArray*) indexPaths withCompletion:(void (^)())completion {
    NSMutableArray* requestOperations = [NSMutableArray array];
    
    // First, iterate over the items to load
    for (NSInteger i=0; i<items.count; i++) {
        NSIndexPath* indexPath = indexPaths[i];
        OPImageItem* item = items[i];
        
        // if found in cache, then put it in the _loadedImages dictionary (this is where all currently displayed images go
        if ([[TMCache sharedCache] objectForKey:item.imageUrl.absoluteString]) {
            UIImage* image = [[TMCache sharedCache] objectForKey:item.imageUrl.absoluteString];
            _loadedImages[indexPath] = [image preloadedImage];
        } else {
            // if not found in cache, then create a image request to go download it, to be batch enqueued later
            //   the userinfo just communicates the indexpath of this image request for later processing
            NSURLRequest* request = [[NSURLRequest alloc] initWithURL:item.imageUrl];
            AFImageRequestOperation* operation = [AFImageRequestOperation imageRequestOperationWithRequest:request success:nil];
            operation.userInfo = @{@"indexpath": indexPath};
            [requestOperations addObject:operation];
        }
    }

    // Now we have either loaded the images from the cache or created image requests.  so create the throwaway client (url meaningless here)
    AFHTTPClient* client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://localhost"]];
    
    // enqueue all the image requests from above.  as per the AFNetworking FAQ, we ignore the success blocks on the individual
    // operations, and instead process them all in THIS completion block.
    [client enqueueBatchOfHTTPRequestOperations:requestOperations progressBlock:nil completionBlock:^(NSArray *operations) {
        
        // do this work on a background thread so we don't block the UI
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for (AFImageRequestOperation* thisOperation in operations) {
                NSIndexPath* indexPath = thisOperation.userInfo[@"indexpath"];
                UIImage* loadedImage = [UIImage imageNamed:@"image_cancel"];
                if (thisOperation.responseImage && !thisOperation.error) {
                    loadedImage = thisOperation.responseImage;
                    // preload the image for speed
                    UIImage* returnImage = [thisOperation.responseImage preloadedImage];
                    if (returnImage) {
                        // cache the preloaded image -- prob don't need all these error checking if's here.
                        [[TMCache sharedCache] setObject:returnImage forKey:thisOperation.request.URL.absoluteString];
                        loadedImage = returnImage;
                    }
                } else {
                    NSLog(@"IMAGE LOAD ERROR: %@ URL: %@", thisOperation.error.localizedDescription, thisOperation.request.URL.absoluteString);
                }
                // put the final image in the _loadedImages dictionary
                _loadedImages[indexPath] = loadedImage;
            }
            // finally dispatch async on main queue to call the completion of this whole deal.
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        });
    }];
}

- (void) forceReload {
    _canLoadMore = NO;
    _currentPage = [NSNumber numberWithInteger:1];
    _currentQueryString = @"";
    _loadedImages = [NSMutableDictionary dictionary];
    self.items = [@[] mutableCopy];
    [self.internalCollectionView reloadData];
    [self.flowLayout invalidateLayout];
    [self doInitialSearch];
}

- (void) loadInitialPageWithItems:(NSArray*) items {
    [self.internalCollectionView scrollRectToVisible:CGRectMake(0.0, 0.0, 1, 1) animated:NO];

    // TODO: use performBatch when bug is fixed in UICollectionViews with headers
    NSMutableArray* indexPaths = [NSMutableArray array];
    for (int i = 0; i < items.count; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForItem:i inSection:0]];
    }

    [self loadItems:items forIndexPaths:indexPaths withCompletion:^{
        [SVProgressHUD dismiss];
        self.items = [items mutableCopy];
        [self.internalCollectionView reloadData];
    }];
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
            [self loadInitialPageWithItems:items];
        } else {
            NSInteger offset = [self.items count];

            // TODO: use performBatch when bug is fixed in UICollectionViews with headers
            NSMutableArray* indexPaths = [NSMutableArray array];
            for (int i = 0; i < items.count; i++) {
                [indexPaths addObject:[NSIndexPath indexPathForItem:i+offset inSection:0]];
            }
            [self loadItems:items forIndexPaths:indexPaths withCompletion:^{
                [SVProgressHUD dismiss];
                _isSearching = NO;
                if ([providerSearched.providerType isEqualToString:self.currentProvider.providerType]) {
                    [self.items addObjectsFromArray:items];
                    [self.internalCollectionView insertItemsAtIndexPaths:indexPaths];
                }
                _canLoadMore = canLoadMore;
            }];
            
        }
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"Search failed."];
    }];
}

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
        if (indexPath.item < _loadedImages.count) {
            UIImage* thisImage = _loadedImages[indexPath];
            CGFloat deviceCellSizeConstant = self.flowLayout.itemSize.height;
            CGFloat newWidth = (thisImage.size.width*deviceCellSizeConstant)/thisImage.size.height;
            CGFloat maxWidth = self.internalCollectionView.frame.size.width - self.flowLayout.sectionInset.left - self.flowLayout.sectionInset.right;
            if (newWidth > maxWidth) {
                newWidth = maxWidth;
            }
            cellSize = CGSizeMake(newWidth, deviceCellSizeConstant);
        }

        return cellSize;
    }
    
    return self.singleImageLayout.itemSize;
}

#pragma mark - UICollectionViewDelegate

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
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

    if (self.currentProvider.supportsLocationSearching) {
        header.mapButton.hidden = NO;
    } else {
        header.mapButton.hidden = YES;
    }
    
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
        if (_canLoadMore) {
            NSInteger currentPageInt = [_currentPage integerValue];
            _currentPage = [NSNumber numberWithInteger:currentPageInt+1];
            [self getMoreItems];
        }

        if (_isSearching && self.items.count) {
            UIActivityIndicatorView* activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            activity.center = cell.contentView.center;
            [activity startAnimating];
            activity.tag = -1;
            [cell.contentView addSubview:activity];
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
    
    UIImageView* imageView = cell.internalScrollView.imageView;
    imageView.alpha = 0.0f;
    if (_loadedImages[indexPath] == [UIImage imageNamed:@"image_cancel"]) {
        imageView.contentMode = UIViewContentModeCenter;
    } else {
        imageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    imageView.image = _loadedImages[indexPath];
    [UIView animateWithDuration:0.5 animations:^{
        imageView.alpha = 1.0;
    }];
    
    return cell;
}

#pragma mark - OPHeaderDelegate

- (void) flipToMap {
    OPMapViewController* mapViewController;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        mapViewController = [[OPMapViewController alloc] initWithNibName:@"OPMapViewController_iPhone" bundle:nil];
    } else {
        mapViewController = [[OPMapViewController alloc] initWithNibName:@"OPMapViewController" bundle:nil];
    }
    
    mapViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    mapViewController.provider = self.currentProvider;
    [self presentViewController:mapViewController animated:YES completion:nil];
}

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
    _loadedImages = [NSMutableDictionary dictionary];
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
    _loadedImages = [NSMutableDictionary dictionary];
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
            FUIAlertView *alertView = [[FUIAlertView alloc] initWithTitle:@"BOOM!"
                                                                  message:@"Exiting full uprez mode."
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles:nil];
            alertView.titleLabel.textColor = [UIColor cloudsColor];
            alertView.titleLabel.font = [UIFont boldFlatFontOfSize:16];
            alertView.messageLabel.textColor = [UIColor cloudsColor];
            alertView.messageLabel.font = [UIFont flatFontOfSize:14];
            alertView.backgroundOverlay.backgroundColor = [UIColor clearColor];
            alertView.alertContainer.backgroundColor = [UIColor midnightBlueColor];
            alertView.defaultButtonColor = [UIColor cloudsColor];
            alertView.defaultButtonShadowColor = [UIColor asbestosColor];
            alertView.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
            alertView.defaultButtonTitleColor = [UIColor asbestosColor];
            [alertView show];
            [currentDefaults setObject:[NSNumber numberWithBool:NO] forKey:@"uprezMode"];
        } else {
            FUIAlertView *alertView = [[FUIAlertView alloc] initWithTitle:@"BOOM!"
                                                                  message:@"Entering full uprez mode."
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles:nil];
            alertView.titleLabel.textColor = [UIColor cloudsColor];
            alertView.titleLabel.font = [UIFont boldFlatFontOfSize:16];
            alertView.messageLabel.textColor = [UIColor cloudsColor];
            alertView.messageLabel.font = [UIFont flatFontOfSize:14];
            alertView.backgroundOverlay.backgroundColor = [UIColor clearColor];
            alertView.alertContainer.backgroundColor = [UIColor midnightBlueColor];
            alertView.defaultButtonColor = [UIColor cloudsColor];
            alertView.defaultButtonShadowColor = [UIColor asbestosColor];
            alertView.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
            alertView.defaultButtonTitleColor = [UIColor asbestosColor];
            [alertView show];
            [currentDefaults setObject:[NSNumber numberWithBool:YES] forKey:@"uprezMode"];
        }
        [currentDefaults synchronize];
    }
}

@end
