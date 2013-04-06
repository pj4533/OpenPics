//
//  OPViewController.m
//  OpenPics
//
//  Created by PJ Gray on 4/6/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import "OPViewController.h"
#import "AFNYPLAPIClient.h"
#import "OPImageItem.h"
#import "AFImageRequestOperation.h"
#import "OPContentCell.h"
#import "OPSingleImageLayout.h"

@interface OPViewController () {
    OPSingleImageLayout *_singleImageLayout;
    NSMutableArray* _items;
    NSInteger _numberFetchedLast;
    NSMutableDictionary* _currentParameters;
}
@end

@implementation OPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _items = [NSMutableArray array];
    
    self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
    self.flowLayout.itemSize = CGSizeMake(300.0f, 300.0f);
    
    self.internalCollectionView.collectionViewLayout = self.flowLayout;
    
    _singleImageLayout = [[OPSingleImageLayout alloc] init];
    _singleImageLayout.itemSize = CGSizeMake(self.internalCollectionView.frame.size.width, self.internalCollectionView.frame.size.height);
    
    [self.internalCollectionView registerNib:[UINib nibWithNibName:@"OPContentCell" bundle:nil] forCellWithReuseIdentifier:@"generic"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Helpers

- (void) doSearchForString:(NSString*) searchString {
    _numberFetchedLast = 0;
    
    _items = [@[] mutableCopy];
    [self.internalCollectionView reloadData];
    
    _currentParameters = [@{
                          @"q":searchString,
                          @"per_page" : @"50",
                          @"page":[NSNumber numberWithInteger:1]
                          } mutableCopy];
    
    [self getItemsWithParameters:_currentParameters completion:^{
        
        
    }];
}

- (void) getItemsWithParameters:(NSDictionary*) parameters completion:(void (^)())completion {
    
    [[AFNYPLAPIClient sharedClient] getItemsWithParameters:parameters success:^(NSArray *items) {
        _numberFetchedLast = items.count;
        if ([parameters[@"page"] integerValue] == 1) {
            [self.internalCollectionView scrollRectToVisible:CGRectMake(0.0, 0.0, 1, 1) animated:NO];
            _items = [items mutableCopy];
            [self.internalCollectionView reloadData];
        } else {
            
            if (_numberFetchedLast < 50) {
                [self.internalCollectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:_items.count inSection:0]]];
            }
            
            NSInteger offset = [_items count];
            [_items addObjectsFromArray:items];
            
            // TODO:  use performBatch when bug is fixed in UICollectionViews with headers
            NSMutableArray* indexPaths = [NSMutableArray array];
            for (int i = offset; i < [_items count]; i++) {
                [indexPaths addObject:[NSIndexPath indexPathForItem:i inSection:0]];
            }
            [self.internalCollectionView insertItemsAtIndexPaths:indexPaths];
        }
        if (completion) {
            completion();
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (completion) {
            completion();
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
    
    if (_numberFetchedLast >= 50)
        return [_items count] + 1;
    
    return [_items count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"generic";
    OPContentCell *cell = (OPContentCell *)[cv dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    cell.internalScrollView.imageView.image = nil;
    
    if ( (indexPath.item == [_items count]) && (_numberFetchedLast >= 50)){
        NSNumber* currentPage = _currentParameters[@"page"];
        NSInteger currentPageInt = [currentPage integerValue];
        currentPage = [NSNumber numberWithInteger:currentPageInt+1];
        _currentParameters[@"page"] = currentPage;
        
        [self getItemsWithParameters:_currentParameters completion:^{
            
        }];
        
        cell.internalScrollView.userInteractionEnabled = NO;
        cell.internalScrollView.imageView.image = nil;
        return cell;
    }
    
    OPImageItem* item = _items[indexPath.item];
    
    cell.mainViewController = self;
    cell.item = item;
    cell.indexPath = indexPath;
    cell.internalScrollView.userInteractionEnabled = NO;
    
    __weak UIImageView* imageView = cell.internalScrollView.imageView;
    NSString* urlString = [NSString stringWithFormat:@"http://images.nypl.org/index.php?id=%@&t=w", item.imageID];
    NSURL* url = [NSURL URLWithString:urlString];
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:url];
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

#pragma mark - Actions

- (IBAction)searchTapped:(id)sender {
    [self.searchTextField resignFirstResponder];
    
    [self doSearchForString:self.searchTextField.text];
}

@end
