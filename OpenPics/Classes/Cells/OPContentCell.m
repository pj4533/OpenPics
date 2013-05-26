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
#import "OPFavoritesProvider.h"
#import "OPProvider.h"
#import "OPProviderController.h"
#import "OPBackend.h"
#import "SVProgressHUD.h"
#import "OPShareToRedditActivity.h"

@interface OPContentCell () {
    UIPopoverController* _popover;
    AFImageRequestOperation* _upRezOperation;
    
    NSString* _completedString;
    
    BOOL _shouldForceReloadOnBack;
}

@end

@implementation OPContentCell

- (void) awakeFromNib {
    [super awakeFromNib];
    
    self.backBackgroundView.alpha = 0.0f;
    self.shareBackgroundView.alpha = 0.0f;
    self.favoriteBackgroundView.alpha = 0.0f;
    
    self.descriptionView.alpha = 0.0f;

    self.backBackgroundView.layer.cornerRadius = 7.0f;
    self.shareBackgroundView.layer.cornerRadius = 7.0f;
    self.favoriteBackgroundView.layer.cornerRadius = 7.0f;
    
    UITapGestureRecognizer* doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapped:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    [self.internalScrollView addGestureRecognizer:doubleTapGesture];
    
    UITapGestureRecognizer* singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [singleTapGesture requireGestureRecognizerToFail:doubleTapGesture];
    [self.internalScrollView addGestureRecognizer:singleTapGesture];
    
    UILongPressGestureRecognizer* longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self.internalScrollView addGestureRecognizer:longPressGesture];
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
    OPShareToRedditActivity* shareToReddit = [[OPShareToRedditActivity alloc] init];
    appActivities = @[shareToTumblr, shareToReddit];
#endif
    
    UIActivityViewController *shareSheet = [[UIActivityViewController alloc] initWithActivityItems:@[self.item]
                                                                             applicationActivities:appActivities];
    
    
//    SHOW ONLY AFTER VC GOES AWAY
    [shareSheet setCompletionHandler:^(NSString *activityType, BOOL completed) {
        if (completed) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(keyboardDidHide:)
                                                         name:UIKeyboardDidHideNotification
                                                       object:nil];

            if ([activityType isEqualToString:UIActivityTypePostToTwitter]) {
                _completedString = @"Posted!";
            } else if ([activityType isEqualToString:UIActivityTypePostToFacebook]) {
                _completedString = @"Posted!";
            } else if ([activityType isEqualToString:UIActivityTypeMail]) {
                _completedString = @"Sent!";
            } else if ([activityType isEqualToString:UIActivityTypeSaveToCameraRoll]) {
                _completedString = @"Saved!";
            } else if ([activityType isEqualToString:UIActivityTypeShareToTumblr]) {
                _completedString = @"Posted!";
            } else if ([activityType isEqualToString:UIActivityTypeShareToReddit]) {
                _completedString = @"Posted!";
            }
        } else {
            _completedString = nil;
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

- (IBAction)favoriteTapped:(id)sender {
    if ([[OPBackend shared] didUserCreateItem:self.item]) {
        [[OPBackend shared] removeItem:self.item];
        [self setButtonToFavorite];
        [SVProgressHUD showSuccessWithStatus:@"Removed Favorite."];
        if ([self.provider.providerType isEqualToString:OPProviderTypeFavorites]) {
            _shouldForceReloadOnBack = YES;
        }
    } else {
        [[OPBackend shared] saveItem:self.item];
        [self setButtonToRemoveFavorite];
        [SVProgressHUD showSuccessWithStatus:@"Favorited!"];
        if ([self.provider.providerType isEqualToString:OPProviderTypeFavorites]) {
            _shouldForceReloadOnBack = NO;
        }
    }
    
}

- (IBAction)backTapped:(id)sender {

    if (self.internalScrollView.zoomScale != 1.0f) {
        [self.internalScrollView setZoomScale:1.0f animated:YES];
    }
    
    UICollectionView* collectionView = self.mainViewController.internalCollectionView;
        
    [self setupForGridLayout];
    
    collectionView.scrollEnabled = YES;

    [self.mainViewController.flowLayout invalidateLayout];
    
    [collectionView setCollectionViewLayout:(UICollectionViewLayout*)self.mainViewController.flowLayout animated:YES];
    [collectionView scrollToItemAtIndexPath:self.indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
    
    if (_shouldForceReloadOnBack) {
        [self.mainViewController forceReload];
    }
}


#pragma mark - Utility Functions

- (void)setButtonToFavorite {
    self.favoriteButtonImageView.image = [UIImage imageNamed:@"heart_plus"];
    self.favoriteButtonLabel.text = @"Favorite";
}

- (void)setButtonToRemoveFavorite {
    self.favoriteButtonImageView.image = [UIImage imageNamed:@"heart_minus"];
    self.favoriteButtonLabel.text = @"Remove";
}

- (void) setupLabels {
    self.titleLabel.text = self.item.title;
}

- (void) fadeOutUIWithCompletion:(void (^)(BOOL finished))completion {
    self.showingUI = NO;

    [UIView animateWithDuration:0.7f animations:^{
        [UIApplication sharedApplication].statusBarHidden = YES;
        self.backBackgroundView.alpha = 0.0f;
        self.shareBackgroundView.alpha = 0.0f;
        self.favoriteBackgroundView.alpha = 0.0f;
        self.descriptionView.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (completion) {
            completion(finished);
        }
    }];
}

- (void) fadeInUIWithCompletion:(void (^)(BOOL finished))completion {
    [UIView animateWithDuration:0.7f animations:^{
        [UIApplication sharedApplication].statusBarHidden = NO;
        self.backBackgroundView.alpha = 1.0f;
        self.shareBackgroundView.alpha = 1.0f;
        self.favoriteBackgroundView.alpha = 1.0f;
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
    
    self.internalScrollView.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    _shouldForceReloadOnBack = NO;
    
    self.internalScrollView.userInteractionEnabled = YES;

    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber* uprezMode = [currentDefaults objectForKey:@"uprezMode"];
    
    OPProvider* thisItemProvider = [[OPProviderController shared] getProviderWithType:self.item.providerType];
    if (uprezMode && uprezMode.boolValue) {
        // this is kind of weird cause in some cases the item is modified by the provider on uprezing
        // I should probably somehow change the main reference to the object so we don't have different
        // versions?
        [thisItemProvider fullUpRezItem:self.item withCompletion:^(NSURL *uprezImageUrl, OPImageItem* item) {
            NSLog(@"FULL UPREZ TO: %@", uprezImageUrl.absoluteString);
            self.item = item;
            self.titleLabel.text = item.title;
            [self upRezToImageWithUrl:uprezImageUrl];
        }];
    } else {
        [thisItemProvider upRezItem:self.item withCompletion:^(NSURL *uprezImageUrl, OPImageItem* item) {
            NSLog(@"UPREZ TO: %@", uprezImageUrl.absoluteString);
            self.item = item;
            self.titleLabel.text = item.title;
            [self upRezToImageWithUrl:uprezImageUrl];
        }];
    }

    if ([[OPBackend shared] didUserCreateItem:self.item]) {
        [self setButtonToRemoveFavorite];
    } else {
        [self setButtonToFavorite];
    }
    
    [self fadeInUIWithCompletion:nil];
    
    if (animated) {
    } else {
        self.showingUI = YES;
    }
}

- (void) setupForGridLayout {
    self.internalScrollView.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.internalScrollView.userInteractionEnabled = NO;
    [self fadeOutUIWithCompletion:nil];
    [UIApplication sharedApplication].statusBarHidden = NO;
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

-  (void)longPress:(UILongPressGestureRecognizer*)sender {
    if ( (sender.state == UIGestureRecognizerStateEnded) || (sender.state == UIGestureRecognizerStateBegan)){
        if (self.internalScrollView.imageView.contentMode == UIViewContentModeCenter) {
            self.internalScrollView.imageView.contentMode = UIViewContentModeScaleAspectFit;
        } else {
            self.internalScrollView.imageView.contentMode = UIViewContentModeCenter;
        }
    }
}

#pragma mark - UIActivityDataSource

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {
    return self.internalScrollView.imageView.image;
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType {
    
    if (self.internalScrollView.zoomScale == 1.0) {
        NSDictionary* returnItem = @{
                                     @"image":self.internalScrollView.imageView.image,
                                     @"title":self.item.title
                                     };
        return returnItem;
    }
    
    CGRect rect = CGRectMake(0, 0, self.internalScrollView.frame.size.width, self.internalScrollView.frame.size.height);
    CGSize pageSize = rect.size;
    UIGraphicsBeginImageContext(pageSize);
    
    CGContextRef resizedContext = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(resizedContext, -self.internalScrollView.contentOffset.x, -self.internalScrollView.contentOffset.y);
    [self.internalScrollView.layer renderInContext:resizedContext];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSDictionary* returnItem = @{
                                 @"image":image,
                                 @"title":self.item.title
                                 };
    return returnItem;
}

#pragma mark Notifications

- (void) keyboardDidHide:(id) note {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (_completedString) {
        [SVProgressHUD showSuccessWithStatus:_completedString];
    } else {
        [SVProgressHUD showErrorWithStatus:@"Failed"];
    }
}

@end
