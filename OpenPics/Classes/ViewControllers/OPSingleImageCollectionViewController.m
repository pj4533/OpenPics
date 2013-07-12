//
//  OPSingleImageCollectionViewController.m
//  OpenPics
//
//  Created by PJ Gray on 6/11/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import "OPSingleImageCollectionViewController.h"
#import "OPImageItem.h"
#import "AFImageRequestOperation.h"
#import "AFNetworking.h"
#import "OPContentCell.h"
#import "OPProvider.h"
#import "OPProviderController.h"
//#import "OPHeaderReusableView.h"
//#import "OPProviderListViewController.h"
//#import "OPMapViewController.h"
#import "SVProgressHUD.h"
#import "TMCache.h"
#import "UIImage+Preload.h"
#import "NSString+MD5.h"
#import "UIImage+ImageEffects.h"

@interface OPSingleImageCollectionViewController () {
    BOOL _canLoadMore;
    
    NSNumber* _currentPage;
    NSString* _currentQueryString;
    
    UIPopoverController* _popover;
    
    BOOL _isSearching;
    
    BOOL _firstAppearance;
}
@end

@implementation OPSingleImageCollectionViewController

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.currentProvider = [[OPProviderController shared] getFirstProvider];
    
}

- (void)viewWillAppear:(BOOL)animated {
    UICollectionViewFlowLayout* flowLayout = (UICollectionViewFlowLayout*) self.collectionView.collectionViewLayout;
    flowLayout.itemSize = CGSizeMake(self.collectionView.frame.size.width, self.collectionView.frame.size.height);
}

#pragma mark - possibly move this code to subclass that main & single VC's are derived from?

- (void) viewDidAppear:(BOOL)animated {
#warning THIS GOES AWAY ONCE LAYOUT TO LAYOUT IS FIXED
    [self.collectionView scrollToItemAtIndexPath:self.indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
                        imageView.contentMode = UIViewContentModeScaleAspectFit;
                        imageView.image = image;
                        
                        // fade in image
                        [UIView animateWithDuration:0.5 animations:^{
                            imageView.alpha = 1.0;
                        }];
                        
//                        // if we have no size information yet, save the information in item, and force a re-layout
//                        if (!item.size.height) {
//                            item.size = image.size;
//                            [self.collectionView.collectionViewLayout invalidateLayout];
//                        }
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

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    return [self.items count];//+1;
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
    //    OPContentCell *cell = (OPContentCell *)[cv dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    //
    //    // remove activity indicator if present
    //    for (UIView* subview in cell.contentView.subviews) {
    //        if (subview.tag == -1) {
    //            [subview removeFromSuperview];
    //        }
    //    }
    //
    //    cell.internalScrollView.imageView.image = nil;
    //
    //    if (indexPath.item == self.items.count) {
    //        if (self.items.count) {
    //            if (_canLoadMore) {
    //                NSInteger currentPageInt = [_currentPage integerValue];
    //                _currentPage = [NSNumber numberWithInteger:currentPageInt+1];
    //                [self getMoreItems];
    //            }
    //
    //            if (_isSearching) {
    //                UIActivityIndicatorView* activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    //                activity.center = CGPointMake(100.0f, 100.0f);
    //                [activity startAnimating];
    //                activity.tag = -1;
    //                [cell.contentView addSubview:activity];
    //            }
    //        }
    //
    //        cell.internalScrollView.userInteractionEnabled = NO;
    //        cell.internalScrollView.imageView.image = nil;
    //        return cell;
    //    }
    
    OPContentCell *cell = (OPContentCell*)[cv dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.singleImageCollectionViewController = self;
    
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
    
    [self loadImageFromItem:item intoImageView:cell.internalScrollView.imageView atIndexPath:indexPath];
    cell.titleLabel.text = item.title;
    
    return cell;
}

@end
