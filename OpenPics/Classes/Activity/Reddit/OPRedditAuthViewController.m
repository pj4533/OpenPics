//
//  OPRedditAuthViewController.m
//  OpenPics
//
//  Created by David Ohayon on 5/25/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import "OPRedditAuthViewController.h"
#import "AFRedditAPIClient.h"
#import "FUIButton.h"

@interface OPRedditAuthViewController ()

@end

@implementation OPRedditAuthViewController

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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginToReddit:(id)sender {
    AFRedditAPIClient *redditClient = [AFRedditAPIClient sharedClient];
    [redditClient loginToRedditWithUsername:self.usernameField.text password:self.passwordField.text success:^(NSDictionary *response) {
        NSLog(@"Logged In!");
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (IBAction)cancelTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
