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
#import "OPShareToTumblrActivity.h"
#import "OPProvider.h"

@interface OPContentCell () {
    UIPopoverController* _popover;
    AFImageRequestOperation* _upRezOperation;
}

@end

@implementation OPContentCell

- (void) awakeFromNib {
    [super awakeFromNib];
    
    self.backBackgroundView.alpha = 0.0f;
    self.shareBackgroundView.alpha = 0.0f;
    
    self.completedView.alpha = 0.0f;
    self.completedView.layer.masksToBounds = NO;
    self.completedView.layer.cornerRadius = 8.0f;
    
    self.descriptionView.alpha = 0.0f;

    self.backBackgroundView.layer.cornerRadius = 7.0f;
    self.shareBackgroundView.layer.cornerRadius = 7.0f;
    
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

#pragma mark - Actions

- (IBAction)shareTapped:(id)sender {
    
    NSArray* appActivities = @[];

#ifndef kOPACTIVITYTOKEN_TUMBLR
#warning *** WARNING: Make sure you have added your Tumblr token to OPActivityTokens.h
#else
    OPShareToTumblrActivity* shareToTumblr = [[OPShareToTumblrActivity alloc] init];
    appActivities = @[shareToTumblr];
#endif
    
    UIActivityViewController *shareSheet = [[UIActivityViewController alloc] initWithActivityItems:@[self]
                                                                             applicationActivities:appActivities];
    
    [shareSheet setCompletionHandler:^(NSString *activityType, BOOL completed) {
        if (completed) {
            NSString* completedString;
            if ([activityType isEqualToString:UIActivityTypePostToTwitter]) {
                completedString = @"Posted!";
            } else if ([activityType isEqualToString:UIActivityTypePostToFacebook]) {
                completedString = @"Posted!";
            } else if ([activityType isEqualToString:UIActivityTypeMail]) {
                completedString = @"Sent!";
            } else if ([activityType isEqualToString:UIActivityTypeSaveToCameraRoll]) {
                completedString = @"Saved!";
            } else if ([activityType isEqualToString:UIActivityTypeShareToTumblr]) {
                completedString = @"Posted!";
            }
            [self showCompletedViewWithText:completedString];
        }
    }];
    
    shareSheet.excludedActivityTypes = @[UIActivityTypeMail,UIActivityTypeCopyToPasteboard,UIActivityTypePostToWeibo,UIActivityTypeAssignToContact, UIActivityTypeMessage, UIActivityTypePrint];
    
    if (_popover) {
        [_popover dismissPopoverAnimated:YES];
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self.mainViewController presentViewController:shareSheet animated:YES completion:nil];
    } else {
        _popover = [[UIPopoverController alloc] initWithContentViewController:shareSheet];
        [_popover presentPopoverFromRect:self.shareBackgroundView.frame inView:self.contentView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

- (IBAction)backTapped:(id)sender {
    
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

- (void) setupLabels {
    self.titleLabel.text = self.item.title;
}

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
        self.backBackgroundView.alpha = 0.0f;
        self.shareBackgroundView.alpha = 0.0f;
        self.descriptionView.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (completion) {
            completion(finished);
        }
    }];
}

- (void) fadeInUIWithCompletion:(void (^)(BOOL finished))completion {
    [UIView animateWithDuration:0.7f animations:^{
        self.backBackgroundView.alpha = 1.0f;
        self.shareBackgroundView.alpha = 1.0f;
        self.descriptionView.alpha = 1.0;
    } completion:^(BOOL finished) {
        self.showingUI = YES;
        if (completion) {
            completion(finished);
        }
    }];
}

- (void) setupForSingleImageLayoutAnimated:(BOOL) animated {
    [self setupLabels];

    self.internalScrollView.userInteractionEnabled = YES;
//    [self.provider upRezItem:self.item withCompletion:^(NSURL *uprezImageUrl) {
//        NSLog(@"UPREZ TO: %@", uprezImageUrl.absoluteString);
//        [self upRezToImageWithUrl:uprezImageUrl];
//    }];
    
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

- (void) upRezToImageWithUrl:(NSURL*) url {
    
    if (_upRezOperation) {
        [_upRezOperation cancel];
        _upRezOperation = nil;
    }
    
    __weak UIImageView* imageView = self.internalScrollView.imageView;
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:url];
    
    _upRezOperation = [AFImageRequestOperation imageRequestOperationWithRequest:request imageProcessingBlock:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        imageView.image = image;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
    }];
    [_upRezOperation start];
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

#pragma mark - UIActivityDataSource

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {
    return self.internalScrollView.imageView.image;
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType {
    
    if (self.internalScrollView.zoomScale == 1.0)
        return self.internalScrollView.imageView.image;
    
    CGRect rect = CGRectMake(0, 0, self.internalScrollView.frame.size.width, self.internalScrollView.frame.size.height);
    CGSize pageSize = rect.size;
    UIGraphicsBeginImageContext(pageSize);
    
    CGContextRef resizedContext = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(resizedContext, -self.internalScrollView.contentOffset.x, -self.internalScrollView.contentOffset.y);
    [self.internalScrollView.layer renderInContext:resizedContext];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return image;
}


@end
