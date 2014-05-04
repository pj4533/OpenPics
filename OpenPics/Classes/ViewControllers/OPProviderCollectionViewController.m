//
//  OPCollectionViewController.m
//  OpenPics
//
//  Created by PJ Gray on 3/22/14.
//  Copyright (c) 2014 Say Goodnight Software. All rights reserved.
//

#import "OPProviderCollectionViewController.h"
#import "OPProviderListViewController.h"
#import "OPImageCollectionViewController.h"
#import "OPImageManager.h"
#import "SVProgressHUD.h"
#import "OPNavigationControllerDelegate.h"
#import "OPProvider.h"
#import "OPProviderController.h"
#import "OPImageItem.h"
#import "OPContentCell.h"

@interface OPProviderCollectionViewController () <UINavigationControllerDelegate,OPProviderListDelegate,UISearchBarDelegate,OPContentCellDelegate> {
    UISearchBar* _searchBar;
    UIBarButtonItem* _sourceButton;
    UIToolbar* _toolbar;
    OPImageManager* _imageManager;
    BOOL _canLoadMore;
    NSNumber* _currentPage;
    BOOL _isSearching;
    NSString* _currentQueryString;
    UIPopoverController* _popover;
    NSMutableArray* _items;
    OPProvider* _currentProvider;
}

@end

@implementation OPProviderCollectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.delegate = [OPNavigationControllerDelegate shared];
    
    _items = [NSMutableArray array];
    _currentProvider = [[OPProviderController shared] getFirstProvider];
    
    _imageManager = [[OPImageManager alloc] init];
    _imageManager.delegate = self;

    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 1024.0f, 44.0f)];
    _searchBar.delegate = self;
    _sourceButton = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"Source: %@", _currentProvider.providerShortName]
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(sourceTapped)],

    self.navigationItem.titleView = _searchBar;
    
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        CGRect frame, remain;
        CGRectDivide(self.view.bounds, &frame, &remain, 44, CGRectMaxYEdge);
        _toolbar = [[UIToolbar alloc] initWithFrame:frame];
        [_toolbar setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
        _toolbar.items = @[
                          [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                          _sourceButton,
                          [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]
                          ];
        [self.view addSubview:_toolbar];
    } else {
        self.navigationItem.rightBarButtonItem = _sourceButton;
    }
    
    
    
    [self doInitialSearch];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [self.view bringSubviewToFront:_toolbar];
}

#pragma mark - actions

- (void) sourceTapped {
    if (_popover) {
        [_popover dismissPopoverAnimated:YES];
    }
    
    UIStoryboard *storyboard = self.storyboard;
    OPProviderListViewController* providerListViewController =
    [storyboard instantiateViewControllerWithIdentifier:@"OPProviderListViewController"];
    providerListViewController.delegate = self;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self presentViewController:providerListViewController animated:YES completion:nil];
    } else {
        _popover = [[UIPopoverController alloc] initWithContentViewController:providerListViewController];
        [_popover presentPopoverFromBarButtonItem:_sourceButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    OPImageCollectionViewController* imageVC = (OPImageCollectionViewController*) segue.destinationViewController;
    imageVC.useLayoutToLayoutNavigationTransitions = YES;
}

#pragma mark OPContentCellDelegate

- (void) singleTappedCell {
    if ([self.navigationController.topViewController isKindOfClass:[OPImageCollectionViewController class]]) {
        OPImageCollectionViewController* imageVC = (OPImageCollectionViewController*) self.navigationController.topViewController;
        [imageVC toggleUIHidden];
    }
}

#pragma mark - Loading Data Helper Functions

- (void) doInitialSearch {
    if (_currentProvider.supportsInitialSearching) {
        _currentPage = [NSNumber numberWithInteger:1];
        [SVProgressHUD showWithStatus:@"Searching..." maskType:SVProgressHUDMaskTypeClear];
        [_currentProvider doInitialSearchWithSuccess:^(NSArray *items, BOOL canLoadMore) {
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
    _items = [items mutableCopy];
    [self.collectionView reloadData];
}

- (void) getMoreItems {
    _canLoadMore = NO;
    _isSearching = YES;
    OPProvider* providerSearched = _currentProvider;
    [_currentProvider getItemsWithQuery:_currentQueryString withPageNumber:_currentPage success:^(NSArray *items, BOOL canLoadMore) {
        if ([_currentPage isEqual:@1]) {
            _canLoadMore = canLoadMore;
            _isSearching = NO;
            [self loadInitialPageWithItems:items];
        } else {
            NSInteger offset = [_items count];
            
            // TODO: use performBatch when bug is fixed in UICollectionViews with headers
            NSMutableArray* indexPaths = [NSMutableArray array];
            for (int i = 0; i < items.count; i++) {
                [indexPaths addObject:[NSIndexPath indexPathForItem:i+offset inSection:0]];
            }
            
            [SVProgressHUD dismiss];
            _isSearching = NO;
            if ([providerSearched.providerType isEqualToString:_currentProvider.providerType]) {
                [_items addObjectsFromArray:items];
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
    
    OPImageItem* item = _items[indexPath.item];
    
    // remove the IB constraints cause they don't seem to work right - but I don't want them autogenerated
    [cell removeConstraints:cell.constraints];
    
    // set the frame to the contentView frame
    cell.internalScrollView.frame = cell.contentView.frame;
    
    // create constraints from autosizing
    cell.internalScrollView.translatesAutoresizingMaskIntoConstraints = YES;
    [cell.internalScrollView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    
    
    cell.provider = _currentProvider;
    cell.item = item;
    cell.indexPath = indexPath;
    cell.internalScrollView.userInteractionEnabled = NO;
    cell.delegate = self;
    
    if (cell.frame.size.width > 200) {
        [_imageManager loadImageFromItem:item toImageView:cell.internalScrollView.imageView atIndexPath:indexPath withContentMode:UIViewContentModeScaleAspectFit];
        [cell setupForSingleImageLayoutAnimated:NO];
    } else {
        [_imageManager loadImageFromItem:item toImageView:cell.internalScrollView.imageView atIndexPath:indexPath withContentMode:UIViewContentModeScaleAspectFill];
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    OPContentCell* cell = (OPContentCell*) [collectionView cellForItemAtIndexPath:indexPath];
    [cell setupForSingleImageLayoutAnimated:YES];
}

#pragma mark - OPProviderListDelegate

- (void)tappedProvider:(OPProvider *)provider {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [_popover dismissPopoverAnimated:YES];
    }
    
    _sourceButton.title = [NSString stringWithFormat:@"Source: %@", provider.providerShortName];
    
    _currentProvider = provider;
    _canLoadMore = NO;
    _isSearching = NO;
    _currentPage = [NSNumber numberWithInteger:1];
    _currentQueryString = @"";
    _items = [@[] mutableCopy];
    [self.collectionView reloadData];
    [self doInitialSearch];
    
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
}

#pragma mark Notifications

- (void) keyboardDidHide:(id) note {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    _canLoadMore = NO;
    _currentPage = [NSNumber numberWithInteger:1];
    _currentQueryString = _searchBar.text;
    _items = [@[] mutableCopy];
    [self.collectionView reloadData];
    
    //    [self.flowLayout invalidateLayout];
    
    [SVProgressHUD showWithStatus:@"Searching..." maskType:SVProgressHUDMaskTypeClear];
    [self getMoreItems];
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
