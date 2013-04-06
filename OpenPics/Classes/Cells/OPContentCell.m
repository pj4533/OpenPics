//
//  OPContentCell.m
//
//  Created by PJ Gray on 2/10/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import "OPContentCell.h"
#import "AFNetworking.h"
#import "OPImageItem.h"
#import <QuartzCore/QuartzCore.h>

@interface OPContentCell () {
}

@end

@implementation OPContentCell

- (void) awakeFromNib {
    [super awakeFromNib];
    
    self.menusBackgroundView.alpha = 0.0f;
    
    self.completedView.alpha = 0.0f;
    self.completedView.layer.masksToBounds = NO;
    self.completedView.layer.cornerRadius = 8.0f;
    
    self.menusBackgroundView.layer.cornerRadius = 7.0f;
    
    UITapGestureRecognizer* doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapped:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    [self.internalScrollView addGestureRecognizer:doubleTapGesture];
    
    UITapGestureRecognizer* singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [singleTapGesture requireGestureRecognizerToFail:doubleTapGesture];
    [self.internalScrollView addGestureRecognizer:singleTapGesture];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


- (IBAction)menusTapped:(id)sender {
    
    if (self.internalScrollView.zoomScale != 1.0f) {
        [self.internalScrollView setZoomScale:1.0f animated:YES];
    }
    
    UICollectionView* collectionView = self.mainViewController.internalCollectionView;
    
    [self setupForGridLayout];
    
    collectionView.scrollEnabled = YES;

    [collectionView setCollectionViewLayout:(UICollectionViewLayout*)self.mainViewController.flowLayout animated:YES];
    [collectionView scrollToItemAtIndexPath:self.indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
}


#pragma mark - Utility Functions

- (void) showCompletedViewWithText:(NSString*) completedString {
    self.completedViewLabel.text = completedString;
    [UIView animateWithDuration:0.25 animations:^{
        self.completedView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.25 delay:1.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.completedView.alpha = 0.0f;
        } completion:nil];
    }];
}

- (void) fadeOutUIWithCompletion:(void (^)(BOOL finished))completion {
    self.showingUI = NO;

    [UIView animateWithDuration:0.7f animations:^{
        self.menusBackgroundView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        if (completion) {
            completion(finished);
        }
    }];
}

- (void) fadeInUIWithCompletion:(void (^)(BOOL finished))completion {
    [UIView animateWithDuration:0.7f animations:^{
        self.menusBackgroundView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        self.showingUI = YES;
        if (completion) {
            completion(finished);
        }
    }];
}

- (void) setupForSingleImageLayoutAnimated:(BOOL) animated {
    self.internalScrollView.userInteractionEnabled = YES;
    [self fadeInUIWithCompletion:nil];
    
    if (animated) {
    } else {
        self.internalScrollView.frame = CGRectMake(self.internalScrollView.frame.origin.x, self.internalScrollView.frame.origin.y, self.frame.size.width, self.frame.size.height);
        self.showingUI = YES;
    }
}

- (void) setupForGridLayout {
    
    self.internalScrollView.userInteractionEnabled = NO;

    self.internalScrollView.frame = CGRectMake(self.internalScrollView.frame.origin.x, self.internalScrollView.frame.origin.y, self.frame.size.width, self.frame.size.height);
    [self fadeOutUIWithCompletion:nil];
}

#pragma mark - gesture stuff

- (IBAction)tapped:(id)sender {
    if (self.showingUI) {
        [self fadeOutUIWithCompletion:nil];
    } else {
        [self fadeInUIWithCompletion:nil];
    }
}

- (IBAction)doubleTapped:(id)sender {
    
    UIGestureRecognizer* theTap = (UIGestureRecognizer*) sender;
    
    OPScrollView* thisScrollView = (OPScrollView*) theTap.view;
    
    if (thisScrollView.zoomScale == 1.0f) {
        CGPoint centerPoint = [theTap locationInView:thisScrollView];
        
        CGRect toZoom;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            toZoom = CGRectMake(centerPoint.x - 50.0f, centerPoint.y - 50.0f, 100.0f, 100.0f);
        else
            toZoom = CGRectMake(centerPoint.x - 50.0f, centerPoint.y - 50.0f, 200.0f, 200.0f);
        
        [thisScrollView zoomToRect:toZoom animated:YES];
    } else {
        [thisScrollView setZoomScale:1.0f animated:YES];
    }
    
}

@end
