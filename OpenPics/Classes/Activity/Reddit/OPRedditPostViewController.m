//
//  OPRedditPostViewController.m
//  OpenPics
//
//  Created by David Ohayon on 5/25/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import "OPRedditPostViewController.h"
#import "AFRedditAPIClient.h"
#import "OPRedditAuthViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface OPRedditPostViewController () {
    AFRedditAPIClient *_redditClient;
}
@end

@implementation OPRedditPostViewController

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
    _redditClient = [AFRedditAPIClient sharedClient];
	self.postBackgroundView.clipsToBounds = YES;
    self.postBackgroundView.layer.borderWidth = 1;
    self.postBackgroundView.layer.cornerRadius = 3;
    self.thumbnailImageView.image = self.item[@"image"];
}

- (void) viewDidAppear:(BOOL)animated {
    if (![_redditClient isAuthenticated]) {
        OPRedditAuthViewController *authVC = [[OPRedditAuthViewController alloc] initWithNibName:@"OPRedditAuthViewController" bundle:nil];
        authVC.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:authVC animated:YES completion:nil];
    }
    if (!self.subredditArray) {
        [_redditClient getUsersSubscribedSubredditsWithSuccess:^(NSArray *subreddits) {
            self.subredditArray = subreddits;
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)postTapped:(id)sender {
    [self.delegate didPostToRedditWithTitle:self.titleField.text toSubreddit:self.subredditField.text];
}

- (IBAction)switchSubredditTapped:(id)sender {
    OPSubredditViewController *subredditView = [[OPSubredditViewController alloc] initWithNibName:@"OPSubredditViewController" bundle:nil];
    subredditView.modalPresentationStyle = UIModalPresentationFormSheet;
    subredditView.subreddits = self.subredditArray;
    subredditView.delegate = self;
    [self presentViewController:subredditView animated:YES completion:nil];
}

#pragma mark - OPSubredditDelegate

- (void) didSelectSubreddit:(NSString*)subreddit {
    self.subredditField.text = subreddit;
}

@end
