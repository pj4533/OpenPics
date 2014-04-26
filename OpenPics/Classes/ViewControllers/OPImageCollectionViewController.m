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

@interface OPImageCollectionViewController () <OPContentCellDelegate>  {
    NSString* _completedString;
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
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionTapped:)];

}

- (void)viewDidAppear:(BOOL)animated {
    // set all the delegates here
    for (OPContentCell* cell in self.collectionView.visibleCells) {
        cell.delegate = self;
    }
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

- (BOOL)prefersStatusBarHidden {
    return self.hidesUI;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    
    return UIStatusBarAnimationFade;
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

#pragma mark OPContentCellDelegate

- (void) singleTappedCell {
    self.hidesUI = !self.hidesUI;
    
//    CGRect barFrame = self.navigationController.navigationBar.frame;
    
    CGFloat alpha = (self.hidesUI) ? 0.0 : 1.0;
    
    [UIView animateWithDuration:0.33 animations:^(void) {
        
        [self setNeedsStatusBarAppearanceUpdate];
        
    }];
    
    [UIView animateWithDuration:0.33 animations:^(void) {
        
        [self.navigationController.navigationBar setAlpha:alpha];
        
    }];

    
//    [UIView animateWithDuration:0.33 animations:^{
//        [self setNeedsStatusBarAppearanceUpdate];
//        self.navigationController.navigationBar.alpha = alpha;
//    }];
//    
//    self.navigationController.navigationBar.frame = CGRectZero;
//    self.navigationController.navigationBar.frame = barFrame;
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
