//
//  OPNavigationController.m
//  OpenPics
//
//  Created by PJ Gray on 6/16/14.
//  Copyright (c) 2014 Say Goodnight Software. All rights reserved.
//

#import "OPNavigationController.h"
#import "OPImageCollectionViewController.h"
@interface OPNavigationController ()

@end

@implementation OPNavigationController

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
    // Do any additional setup after loading the view.
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

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if ([self.topViewController isKindOfClass:[OPImageCollectionViewController class]]) {
        OPImageCollectionViewController* viewController = (OPImageCollectionViewController*) self.topViewController;
        [viewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    }
}
@end
