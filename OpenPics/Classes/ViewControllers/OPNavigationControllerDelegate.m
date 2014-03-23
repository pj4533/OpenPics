//
//  OPNavigationControllerDelegate.m
//  OpenPics
//
//  Created by PJ Gray on 3/23/14.
//  Copyright (c) 2014 Say Goodnight Software. All rights reserved.
//

#import "OPNavigationControllerDelegate.h"
#import "OPImageCollectionViewController.h"
#import "OPRootCollectionViewController.h"

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

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    // Have to manually adjust the contentInsets here, cause it seems like this isn't done
    // automatically, when doing layout to layout transitions, regardless of what the
    // 'automaticallyAdjustsScrollViewInsets' is set to.  Possibly cause of the
    // sharing of the collectionView instance?
    if ([viewController isKindOfClass:[UICollectionViewController class]]) {
        UICollectionViewController* collectionViewController = (UICollectionViewController*) viewController;

        CGFloat topInset = 0.0f;
        if ([viewController isMemberOfClass:[OPImageCollectionViewController class]]) {
            viewController.automaticallyAdjustsScrollViewInsets = NO;
        } else if ([viewController isMemberOfClass:[OPRootCollectionViewController class]]) {
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
//        NSLog(@"layout: %@", NSStringFromClass([collectionViewController.collectionViewLayout class]));
    }
    
//    NSLog(@"didShowViewController: %@", NSStringFromClass([viewController class]));
}

@end
