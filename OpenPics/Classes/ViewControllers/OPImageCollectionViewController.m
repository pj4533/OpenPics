//
//  OPImageCollectionViewController.m
//  OpenPics
//
//  Created by PJ Gray on 3/22/14.
//  Copyright (c) 2014 Say Goodnight Software. All rights reserved.
//

#import "OPImageCollectionViewController.h"
#import "OPContentCell.h"
#import "TUSafariActivity.h"
#import "SVProgressHUD.h"
#import "OPBackend.h"

@interface OPImageCollectionViewController () <UIActivityItemSource>  {
    NSString* _completedString;
    UIToolbar* _toolbar;
    UIBarButtonItem* _favoriteButton;
    BOOL _hidesUI;
    UIPopoverController* _popover;
}

@end

@implementation OPImageCollectionViewController

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
    
    UICollectionViewFlowLayout* layout = (UICollectionViewFlowLayout*) self.collectionViewLayout;
    layout.itemSize = self.collectionView.bounds.size;

    CGRect frame, remain;
    CGRectDivide(self.view.bounds, &frame, &remain, 44, CGRectMaxYEdge);
    _toolbar = [[UIToolbar alloc] initWithFrame:frame];
    [_toolbar setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
    _favoriteButton = [[UIBarButtonItem alloc] initWithTitle:@"Add Favorite" style:UIBarButtonItemStylePlain target:self action:@selector(favoriteTapped:)];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        _toolbar.items = @[
                           [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionTapped:)],
                           [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           _favoriteButton
                           ];
    } else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionTapped:)];

        _toolbar.items = @[
                           [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           _favoriteButton
                           ];
    }

    [self.view addSubview:_toolbar];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.view bringSubviewToFront:_toolbar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    UICollectionViewFlowLayout* layout = (UICollectionViewFlowLayout*) self.collectionViewLayout;
    layout.itemSize = CGSizeMake(self.collectionView.bounds.size.height,self.collectionView.bounds.size.width);

    NSIndexPath *indexPath = [[self.collectionView indexPathsForVisibleItems] firstObject];
    CGPoint contentOffsetAfterRotation = CGPointMake(indexPath.item * [self.view bounds].size.height, 0);
    [self.collectionView setContentOffset:contentOffsetAfterRotation];
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    if (_hidesUI) {
        [self.navigationController.navigationBar setAlpha:0.0];
    }
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

- (void)toggleUIHidden {
    _hidesUI = !_hidesUI;
    
    //    CGRect barFrame = self.navigationController.navigationBar.frame;
    
    CGFloat alpha = (_hidesUI) ? 0.0 : 1.0;

    // TODO: This makes the cell
    [self setNeedsStatusBarAppearanceUpdate];
    self.collectionView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    self.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    self.collectionView.contentOffset = CGPointMake(self.collectionView.contentOffset.x, 0.0);
    
    [UIView animateWithDuration:0.33 animations:^(void) {
        
        [self.navigationController.navigationBar setAlpha:alpha];
        [_toolbar setAlpha:alpha];
    }];
}

- (BOOL)prefersStatusBarHidden {
    return _hidesUI;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    
    return UIStatusBarAnimationFade;
}


- (IBAction)favoriteTapped:(id)sender {
    if (self.collectionView.visibleCells.count != 1)
        return;
    
    OPContentCell* cell = (OPContentCell*) self.collectionView.visibleCells[0];

    if ([[OPBackend shared] didUserCreateItem:cell.item]) {
        [[OPBackend shared] removeItem:cell.item];
        _favoriteButton.title = @"Add Favorite";
        [SVProgressHUD showSuccessWithStatus:@"Removed Favorite."];
    } else {
        [[OPBackend shared] saveItem:cell.item];
        _favoriteButton.title = @"Remove Favorite";
        [SVProgressHUD showSuccessWithStatus:@"Favorited!"];
    }
}

- (IBAction)actionTapped:(id)sender {
    
    NSMutableArray* appActivities = [NSMutableArray array];
    
    TUSafariActivity *openInSafari = [[TUSafariActivity alloc] init];
    [appActivities addObject:openInSafari];

    if (self.collectionView.visibleCells.count != 1)
        return;
    
    OPContentCell* cell = (OPContentCell*) self.collectionView.visibleCells[0];

    UIActivityViewController *shareSheet;
    if (cell.item.providerSpecific && cell.item.providerUrl) {
        shareSheet = [[UIActivityViewController alloc] initWithActivityItems:@[self,cell.item.providerUrl]
                                                       applicationActivities:appActivities];
    } else {
        shareSheet = [[UIActivityViewController alloc] initWithActivityItems:@[self]
                                                       applicationActivities:appActivities];
    }
    
    
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
        [self presentViewController:shareSheet animated:YES completion:nil];
    } else {
        _popover = [[UIPopoverController alloc] initWithContentViewController:shareSheet];
        [_popover presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

#pragma mark - UIActivityDataSource

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {
    
    if (self.collectionView.visibleCells.count != 1)
        return nil;
    
    OPContentCell* cell = (OPContentCell*) self.collectionView.visibleCells[0];
    return cell.internalScrollView.imageView.image;
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType {
    if (self.collectionView.visibleCells.count != 1)
        return nil;
    
    OPContentCell* cell = (OPContentCell*) self.collectionView.visibleCells[0];

    if ([activityType isEqualToString:NSStringFromClass([TUSafariActivity class])]) {
        return cell.item.providerUrl;
    }
    
    if (cell.internalScrollView.zoomScale == 1.0) {
        NSDictionary* returnItem = @{
                                     @"image":cell.internalScrollView.imageView.image,
                                     @"title":cell.item.title,
                                     @"imageUrl":cell.item.imageUrl
                                     };
        return returnItem;
    }
    
    CGRect rect = CGRectMake(0, 0, cell.internalScrollView.frame.size.width, cell.internalScrollView.frame.size.height);
    CGSize pageSize = rect.size;
    UIGraphicsBeginImageContext(pageSize);
    
    CGContextRef resizedContext = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(resizedContext, -cell.internalScrollView.contentOffset.x, -cell.internalScrollView.contentOffset.y);
    [cell.internalScrollView.layer renderInContext:resizedContext];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSDictionary* returnItem = @{
                                 @"image":image,
                                 @"title":cell.item.title
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
