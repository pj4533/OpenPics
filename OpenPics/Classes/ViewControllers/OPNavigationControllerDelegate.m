//
//  OPNavigationControllerDelegate.m
//  OpenPics
//
//  Created by PJ Gray on 3/23/14.
//  Copyright (c) 2014 Say Goodnight Software. All rights reserved.
//

#import "OPNavigationControllerDelegate.h"
#import "OPImageCollectionViewController.h"
#import "OPProviderCollectionViewController.h"
#import "OPContentCell.h"

@implementation OPNavigationControllerDelegate

+ (OPNavigationControllerDelegate *)shared {
    static OPNavigationControllerDelegate *_shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [[OPNavigationControllerDelegate alloc] init];
    });
    
    return _shared;
}

#pragma mark - UINavigationControllerDelegate

// These functions enable functionality to be specific to the UICollectionViewController on display during a layout to layout transition
//
// It feels like it should pay attention to what is in the storyboard, but it doesn't.  For example, if I set paging off in the root, and transition to
// the image VC, it doesn't work, and vice-versa.   I have to make sure to set it properly here.   Same thing for layouts and insets.  I think it has something to do with the sharing of the collectionView, but I am not sure.
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    // Have to manually adjust the contentInsets here, cause it seems like this isn't done
    // automatically, when doing layout to layout transitions, regardless of what the
    // 'automaticallyAdjustsScrollViewInsets' is set to.  Possibly cause of the
    // sharing of the collectionView instance?
    if ([viewController isKindOfClass:[UICollectionViewController class]]) {
        UICollectionViewController* collectionViewController = (UICollectionViewController*) viewController;

        CGFloat topInset = 0.0f;
        if ([viewController isMemberOfClass:[OPImageCollectionViewController class]]) {
            collectionViewController.collectionView.pagingEnabled = YES;
            viewController.automaticallyAdjustsScrollViewInsets = NO;
        } else if ([viewController isMemberOfClass:[OPProviderCollectionViewController class]]) {
            collectionViewController.collectionView.pagingEnabled = NO;
            topInset = 64.0f;
            viewController.automaticallyAdjustsScrollViewInsets = YES;
        }

        [collectionViewController.collectionView setContentInset:UIEdgeInsetsMake(topInset, 0.0f, 0.0f, 0.0f)];
        [collectionViewController.collectionView setScrollIndicatorInsets: collectionViewController.collectionView.contentInset];
//        NSLog(@"layout: %@", NSStringFromClass([collectionViewController.collectionViewLayout class]));
    }
    
    
//    NSLog(@"willShowViewController: %@", NSStringFromClass([viewController class]));
}

- (void) navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    // when doing a layout to layout transition, you have to manually invalidate the layout on back
    if ([viewController isKindOfClass:[UICollectionViewController class]]) {
        UICollectionViewController* collectionViewController = (UICollectionViewController*) viewController;
        [collectionViewController.collectionViewLayout invalidateLayout];
        
        if ([viewController isMemberOfClass:[OPProviderCollectionViewController class]]) {
            for (OPContentCell* cell in collectionViewController.collectionView.visibleCells) {
                cell.internalScrollView.userInteractionEnabled = NO;
                if (cell.internalScrollView.zoomScale != 1.0f) {
                    [cell.internalScrollView setZoomScale:1.0f animated:NO];
                }
                cell.internalScrollView.imageView.contentMode = UIViewContentModeScaleAspectFill;

            }
        }

//        NSLog(@"layout: %@", NSStringFromClass([collectionViewController.collectionViewLayout class]));
    }
    
//    NSLog(@"didShowViewController: %@", NSStringFromClass([viewController class]));
}

@end
