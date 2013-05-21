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
#import "OPContentCell.h"
#import "OPProvider.h"
#import "OPProviderController.h"
#import "OPHeaderReusableView.h"
#import "OPProviderListViewController.h"
#import "OPMapViewController.h"
#import "SVProgressHUD.h"


@interface OPViewController () {
    BOOL _canLoadMore;

    NSInteger _visibleItemAtStartOfRotate;
    
    NSNumber* _currentPage;
    NSString* _currentQueryString;

    UIPopoverController* _popover;
}
@end

@implementation OPViewController

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.items = [NSMutableArray array];
        self.currentProvider = [[OPProviderController shared] getFirstProvider];

        self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
        self.flowLayout.sectionInset = UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f);
        self.singleImageLayout = [[OPSingleImageLayout alloc] init];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            self.flowLayout.itemSize = CGSizeMake(75.0f, 75.0f);
            self.flowLayout.headerReferenceSize = CGSizeMake(320.0f, 117.0f);
            self.singleImageLayout.headerReferenceSize = CGSizeMake(320.0f, 117.0f);
        } else {
            self.flowLayout.itemSize = CGSizeMake(300.0f, 300.0f);
            self.flowLayout.headerReferenceSize = CGSizeMake(1024.0f, 175.0f);
            self.singleImageLayout.headerReferenceSize = CGSizeMake(1024.0f, 175.0f);
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
    if (!self.items.count) {
        [self doInitialSearch];
    }
    
}

- (void) viewDidAppear:(BOOL)animated {
    if (self.items.count == 1) {
        [self switchToSingleImageWithIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
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

- (void) forceReload {
    _canLoadMore = NO;
    _currentPage = [NSNumber numberWithInteger:1];
    _currentQueryString = @"";
    self.items = [@[] mutableCopy];
    [self.internalCollectionView reloadData];
    [self doInitialSearch];
}

- (void) doInitialSearch {
    if (self.currentProvider.supportsInitialSearching) {
        _currentPage = [NSNumber numberWithInteger:1];
        [SVProgressHUD showWithStatus:@"Searching..."];
        [self.currentProvider doInitialSearchWithSuccess:^(NSArray *items, BOOL canLoadMore) {
            [SVProgressHUD dismiss];
            _canLoadMore = canLoadMore;
            [self.internalCollectionView scrollRectToVisible:CGRectMake(0.0, 0.0, 1, 1) animated:NO];
            self.items = [items mutableCopy];
            [self.internalCollectionView reloadData];
        } failure:^(NSError *error) {
            [SVProgressHUD showErrorWithStatus:@"Search failed."];
        }];
    }
}

- (void) getMoreItems {
    [SVProgressHUD showWithStatus:@"Searching..."];
    [self.currentProvider getItemsWithQuery:_currentQueryString withPageNumber:_currentPage success:^(NSArray *items, BOOL canLoadMore) {
        [SVProgressHUD dismiss];
        _canLoadMore = canLoadMore;
        if ([_currentPage isEqual:@1]) {
            [self.internalCollectionView scrollRectToVisible:CGRectMake(0.0, 0.0, 1, 1) animated:NO];
            self.items = [items mutableCopy];
            [self.internalCollectionView reloadData];
        } else {
            
            // this is getting rid of the extra cell that holds the 'Load More...' spinner
            if (!_canLoadMore) {
                [self.internalCollectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:self.items.count inSection:0]]];
            }
            
            NSInteger offset = [self.items count];
            [self.items addObjectsFromArray:items];
            
            // TODO: use performBatch when bug is fixed in UICollectionViews with headers
            NSMutableArray* indexPaths = [NSMutableArray array];
            for (int i = offset; i < [self.items count]; i++) {
                [indexPaths addObject:[NSIndexPath indexPathForItem:i inSection:0]];
            }
            [self.internalCollectionView insertItemsAtIndexPaths:indexPaths];
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
    
    if (_canLoadMore)
        return [self.items count] + 1;
    
    return [self.items count];
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
    
    cell.internalScrollView.imageView.image = nil;
    
    if ( (indexPath.item == [self.items count]) && _canLoadMore){
        NSInteger currentPageInt = [_currentPage integerValue];
        _currentPage = [NSNumber numberWithInteger:currentPageInt+1];

        [self getMoreItems];
        
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
    
    __weak UIImageView* imageView = cell.internalScrollView.imageView;
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:item.imageUrl];
    imageView.contentMode = UIViewContentModeCenter;
    imageView.alpha = 0.0f;
    imageView.image = [UIImage imageNamed:@"hourglass_white"];
    
    AFImageRequestOperation* operation = [AFImageRequestOperation imageRequestOperationWithRequest:request imageProcessingBlock:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        if ([cell.item.imageUrl isEqual:request.URL]) {
            [UIView animateWithDuration:0.25 animations:^{
                imageView.alpha = 0.0;
            } completion:^(BOOL finished) {
                imageView.contentMode = UIViewContentModeScaleAspectFit;
                imageView.image = image;
                [UIView animateWithDuration:0.5 animations:^{
                    imageView.alpha = 1.0;
                }];
            }];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"error getting image");
        [UIView animateWithDuration:0.25 animations:^{
            imageView.alpha = 0.0;
        } completion:^(BOOL finished) {
            imageView.image = [UIImage imageNamed:@"image_cancel"];
            [UIView animateWithDuration:0.5 animations:^{
                imageView.alpha = 1.0;
            }];
        }];
    }];
    [operation start];
    
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

- (void) providerTappedFromRect:(CGRect) rect {
    if (_popover) {
        [_popover dismissPopoverAnimated:YES];
    }
    
    OPProviderListViewController* providerListViewController = [[OPProviderListViewController alloc] initWithNibName:@"OPProviderListViewController" bundle:nil];
    providerListViewController.delegate = self;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self presentViewController:providerListViewController animated:YES completion:nil];
    } else {
        _popover = [[UIPopoverController alloc] initWithContentViewController:providerListViewController];
        [_popover presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

- (void) doSearchWithQuery:(NSString *)queryString {
    _canLoadMore = NO;
    _currentPage = [NSNumber numberWithInteger:1];
    _currentQueryString = queryString;
    self.items = [@[] mutableCopy];
    [self.internalCollectionView reloadData];
    
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
    _currentPage = [NSNumber numberWithInteger:1];
    _currentQueryString = @"";
    self.items = [@[] mutableCopy];
    [self.internalCollectionView reloadData];
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
