//
//  OPItemCollectionViewController.m
//  OpenPics
//
//  Created by PJ Gray on 6/22/14.
//  Copyright (c) 2014 Say Goodnight Software. All rights reserved.
//

#import "OPItemCollectionViewController.h"
#import "OPImageCollectionViewController.h"
#import "UINavigationController+SGProgress.h"
#import "OPProviderController.h"
#import "OPProvider.h"
#import "SVProgressHUD.h"
#import "OPCollectionViewDataSource.h"
#import "OPSetCollectionViewController.h"

@interface OPItemCollectionViewController () <UICollectionViewDelegateFlowLayout> {
    CGSize _cellSize;
}

@end

@implementation OPItemCollectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

#pragma mark Data loading helpers

- (void) doInitialSearch {
    OPProvider* selectedProvider = [[OPProviderController shared] getSelectedProvider];
    
    if (selectedProvider.supportsInitialSearching) {
        [SVProgressHUD showWithStatus:@"Searching..." maskType:SVProgressHUDMaskTypeClear];
        
        OPCollectionViewDataSource* dataSource = (OPCollectionViewDataSource*) self.collectionView.dataSource;
        [dataSource doInitialSearchWithSuccess:^(NSArray *items, BOOL canLoadMore) {
            [SVProgressHUD dismiss];
            [self.collectionView scrollRectToVisible:CGRectMake(0.0, 0.0, 1, 1) animated:NO];
            [self.collectionView reloadData];
        } failure:^(NSError *error) {
            [SVProgressHUD showErrorWithStatus:@"Search failed."];
        }];
    }
}


- (void) getMoreItems {
    OPCollectionViewDataSource* dataSource = (OPCollectionViewDataSource*) self.collectionView.dataSource;
    
    [dataSource getMoreItemsWithSuccess:^(NSArray *indexPaths) {
        [SVProgressHUD dismiss];
        if (indexPaths) {
            [self.collectionView insertItemsAtIndexPaths:indexPaths];
        } else {
            [self.collectionView scrollRectToVisible:CGRectMake(0.0, 0.0, 1, 1) animated:NO];
            [self.collectionView reloadData];
        }
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"Search failed."];
    }];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"imageitem"]) {
        OPImageCollectionViewController* imageVC = (OPImageCollectionViewController*) segue.destinationViewController;
        imageVC.useLayoutToLayoutNavigationTransitions = YES;
    } else if ([segue.identifier isEqualToString:@"setitem"]) {
        OPContentCell* cell = (OPContentCell*) sender;
        OPSetCollectionViewController* viewController = (OPSetCollectionViewController*) segue.destinationViewController;
        viewController.setItem = cell.item;
        
    }
}

#pragma mark OPContentCellDelegate / datasource delegate

- (void) singleTappedCell {
    if ([self.navigationController.topViewController isKindOfClass:[OPImageCollectionViewController class]]) {
        OPImageCollectionViewController* imageVC = (OPImageCollectionViewController*) self.navigationController.topViewController;
        [imageVC toggleUIHidden];
    }
}

- (void) showProgressWithBytesRead:(NSUInteger) bytesRead
                withTotalBytesRead:(NSInteger) totalBytesRead
      withTotalBytesExpectedToRead:(NSInteger) totalBytesExpectedToRead {
    
    float percentage = (float) ((totalBytesRead/totalBytesExpectedToRead) * 100);
    [self.navigationController setSGProgressPercentage:percentage];
}

#pragma mark - UICollectionViewDelegate

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    OPContentCell* cell = (OPContentCell*) [collectionView cellForItemAtIndexPath:indexPath];
    [cell setupForSingleImageLayoutAnimated:YES];
}

- (void) collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    OPCollectionViewDataSource* dataSource = (OPCollectionViewDataSource*) self.collectionView.dataSource;
    [dataSource cancelRequestAtIndexPath:indexPath];
}

#pragma mark flow delegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return _cellSize;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    
    // iPhones in portrait
    if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact
        && self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassRegular) {
        CGFloat size = ((self.view.frame.size.width-20) / 3);
        _cellSize = CGSizeMake(size,size);
    } else if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular
               && self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact) {
        CGFloat size = ((self.view.frame.size.height-20) / 3);
        _cellSize = CGSizeMake(size,size);
    } else if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular
               && self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassRegular) {
        _cellSize = CGSizeMake(246.0f,246.0f);
    }
    
    [self.collectionView reloadItemsAtIndexPaths:self.collectionView.indexPathsForVisibleItems];
}



@end
