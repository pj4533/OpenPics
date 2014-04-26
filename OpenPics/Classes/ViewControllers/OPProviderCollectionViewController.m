//
//  OPCollectionViewController.m
//  OpenPics
//
//  Created by PJ Gray on 3/22/14.
//  Copyright (c) 2014 Say Goodnight Software. All rights reserved.
//

#import "OPProviderCollectionViewController.h"
#import "OPImageCollectionViewController.h"
#import "SVProgressHUD.h"
#import "OPProvider.h"
#import "OPImageItem.h"
#import "SGSStaggeredFlowLayout.h"
#import "OPContentCell.h"

@interface OPProviderCollectionViewController () <UINavigationControllerDelegate,OPProviderListDelegate,UISearchBarDelegate> {
    UISearchBar* _searchBar;
    UIBarButtonItem* _sourceButton;
    UIToolbar* _toolbar;
}

@end

@implementation OPProviderCollectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 1024.0f, 44.0f)];
    _searchBar.delegate = self;
    _sourceButton = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"Source: %@", self.currentProvider.providerShortName]
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
    
    OPProviderListViewController* providerListViewController = [[OPProviderListViewController alloc] initWithNibName:@"OPProviderListViewController" bundle:nil];
    providerListViewController.delegate = self;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self presentViewController:providerListViewController animated:YES completion:nil];
    } else {
        _popover = [[UIPopoverController alloc] initWithContentViewController:providerListViewController];
        [_popover presentPopoverFromBarButtonItem:_sourceButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewFlowLayout* flowLayout = (UICollectionViewFlowLayout*) collectionViewLayout;
    CGSize cellSize = flowLayout.itemSize;
    
    if ([collectionViewLayout isKindOfClass:[SGSStaggeredFlowLayout class]]) {
        CGSize imageSize = CGSizeZero;
        if (indexPath.item < self.items.count) {
            OPImageItem* item = self.items[indexPath.item];
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    OPImageCollectionViewController* imageVC = (OPImageCollectionViewController*) segue.destinationViewController;
    imageVC.useLayoutToLayoutNavigationTransitions = YES;
    imageVC.items = self.items;
    imageVC.currentProvider = self.currentProvider;
}

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
    
    self.currentProvider = provider;
    _canLoadMore = NO;
    _isSearching = NO;
    _currentPage = [NSNumber numberWithInteger:1];
    _currentQueryString = @"";
    self.items = [@[] mutableCopy];
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
    self.items = [@[] mutableCopy];
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
