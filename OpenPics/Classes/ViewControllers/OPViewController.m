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
#import "OPSingleImageLayout.h"
#import "OPProvider.h"
#import "OPProviderController.h"
#import "OPHeaderReusableView.h"
#import "OPProviderListViewController.h"

@interface OPViewController () {
    OPSingleImageLayout *_singleImageLayout;

    NSMutableArray* _items;

    BOOL _canLoadMore;
    
    NSNumber* _currentPage;
    NSString* _currentQueryString;

    OPProvider* _currentProvider;
    
    UIPopoverController* _popover;
}
@end

@implementation OPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _currentProvider = [[OPProviderController shared] getFirstProvider];
    
    _items = [NSMutableArray array];
    
    self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.flowLayout.itemSize = CGSizeMake(100.0f, 100.0f);
        self.flowLayout.headerReferenceSize = CGSizeMake(320.0f, 97.0f);
    } else {
        self.flowLayout.itemSize = CGSizeMake(300.0f, 300.0f);
        self.flowLayout.headerReferenceSize = CGSizeMake(1024.0f, 155.0f);
    }

    self.internalCollectionView.collectionViewLayout = self.flowLayout;
    
    _singleImageLayout = [[OPSingleImageLayout alloc] init];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self.internalCollectionView registerNib:[UINib nibWithNibName:@"OPContentCell_iPhone" bundle:nil] forCellWithReuseIdentifier:@"generic"];
        [self.internalCollectionView registerNib:[UINib nibWithNibName:@"OPHeaderReusableView_iPhone" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
    } else {
        [self.internalCollectionView registerNib:[UINib nibWithNibName:@"OPContentCell" bundle:nil] forCellWithReuseIdentifier:@"generic"];
        [self.internalCollectionView registerNib:[UINib nibWithNibName:@"OPHeaderReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
    }
}

- (void) viewDidAppear:(BOOL)animated {
    _singleImageLayout.itemSize = CGSizeMake(self.internalCollectionView.frame.size.width, self.internalCollectionView.frame.size.height);
    NSLog(@"SIZE: %@", NSStringFromCGSize(_singleImageLayout.itemSize));
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Helpers

- (void) getMoreItems {
    [_currentProvider getItemsWithQuery:_currentQueryString withPageNumber:_currentPage completion:^(NSArray *items, BOOL canLoadMore) {
        _canLoadMore = canLoadMore;
        if ([_currentPage isEqual:@1]) {
            [self.internalCollectionView scrollRectToVisible:CGRectMake(0.0, 0.0, 1, 1) animated:NO];
            _items = [items mutableCopy];
            [self.internalCollectionView reloadData];
        } else {

            // this is getting rid of the extra cell that holds the 'Load More...' spinner
            if (!_canLoadMore) {
                [self.internalCollectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:_items.count inSection:0]]];
            }
            
            NSInteger offset = [_items count];
            [_items addObjectsFromArray:items];
            
            // TODO: use performBatch when bug is fixed in UICollectionViews with headers
            NSMutableArray* indexPaths = [NSMutableArray array];
            for (int i = offset; i < [_items count]; i++) {
                [indexPaths addObject:[NSIndexPath indexPathForItem:i inSection:0]];
            }
            [self.internalCollectionView insertItemsAtIndexPaths:indexPaths];
        }
    }];
}

#pragma mark - UICollectionViewDelegate

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.internalCollectionView.collectionViewLayout == _singleImageLayout) {
        self.internalCollectionView.scrollEnabled = YES;
        
        [self.flowLayout invalidateLayout];
        [self.internalCollectionView setCollectionViewLayout:self.flowLayout animated:YES];
        OPContentCell* cell = (OPContentCell*) [self.internalCollectionView cellForItemAtIndexPath:indexPath];
        [cell setupForGridLayout];
        
        [self.internalCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
    } else {
        self.internalCollectionView.scrollEnabled = NO;
        [_singleImageLayout invalidateLayout];
        [self.internalCollectionView setCollectionViewLayout:_singleImageLayout animated:YES];
        OPContentCell* cell = (OPContentCell*) [self.internalCollectionView cellForItemAtIndexPath:indexPath];
        [cell setupForSingleImageLayoutAnimated:NO];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    
    if (_canLoadMore)
        return [_items count] + 1;
    
    return [_items count];
}

- (UICollectionReusableView*) collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    OPHeaderReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"header" forIndexPath:indexPath];
    header.delegate = self;
    [header.providerButton setTitle:_currentProvider.providerName forState:UIControlStateNormal];

    return header;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"generic";
    OPContentCell *cell = (OPContentCell *)[cv dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    cell.internalScrollView.imageView.image = nil;
    
    if ( (indexPath.item == [_items count]) && _canLoadMore){
        NSInteger currentPageInt = [_currentPage integerValue];
        _currentPage = [NSNumber numberWithInteger:currentPageInt+1];

        [self getMoreItems];
        
        cell.internalScrollView.userInteractionEnabled = NO;
        cell.internalScrollView.imageView.image = nil;
        return cell;
    }
    
    OPImageItem* item = _items[indexPath.item];
    
    cell.mainViewController = self;
    cell.provider = _currentProvider;
    cell.item = item;
    cell.indexPath = indexPath;
    cell.internalScrollView.userInteractionEnabled = NO;
    
    __weak UIImageView* imageView = cell.internalScrollView.imageView;
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:item.imageUrl];
    imageView.contentMode = UIViewContentModeCenter;
    imageView.alpha = 0.0f;
    imageView.image = [UIImage imageNamed:@"hourglass_white"];
    
    AFImageRequestOperation* operation = [AFImageRequestOperation imageRequestOperationWithRequest:request
                                                                              imageProcessingBlock:nil
                                                                                           success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                                                               [UIView animateWithDuration:0.25 animations:^{
                                                                                                   imageView.alpha = 0.0;
                                                                                               } completion:^(BOOL finished) {
                                                                                                   imageView.contentMode = UIViewContentModeScaleAspectFit;
                                                                                                   imageView.image = image;
                                                                                                   [UIView animateWithDuration:0.5 animations:^{
                                                                                                       imageView.alpha = 1.0;
                                                                                                   }];
                                                                                               }];
                                                                                               
                                                                                               
                                                                                           } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                                                               NSLog(@"error getting image");
                                                                                           }];
    [operation start];
    
    [UIView animateWithDuration:0.5 animations:^{
        imageView.alpha = 1.0;
    }];
    
    return cell;
}

#pragma mark - OPHeaderDelegate

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
    _items = [@[] mutableCopy];
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
    
    _currentProvider = provider;
    _canLoadMore = NO;
    _currentPage = [NSNumber numberWithInteger:1];
    _currentQueryString = @"";
    _items = [@[] mutableCopy];
    [self.internalCollectionView reloadData];
}

@end
