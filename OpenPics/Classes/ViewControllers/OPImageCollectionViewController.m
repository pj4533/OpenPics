//
//  OPImageCollectionViewController.m
//  OpenPics
//
//  Created by PJ Gray on 3/22/14.
//  Copyright (c) 2014 Say Goodnight Software. All rights reserved.
//

#import "OPImageCollectionViewController.h"
#import "OPContentCell.h"

@interface OPImageCollectionViewController () <OPContentCellDelegate> 

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


@end
