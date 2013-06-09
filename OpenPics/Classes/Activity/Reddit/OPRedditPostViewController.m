//
//  OPRedditPostViewController.m
//  OpenPics
//
//  Created by David Ohayon on 5/25/13.
// 
// Copyright (c) 2013 Say Goodnight Software
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


#import "OPRedditPostViewController.h"
#import "AFRedditAPIClient.h"
#import "OPRedditAuthViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "TTTURLRequestFormatter.h"

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
    [self.titleField becomeFirstResponder];
    
    if ([_redditClient isAuthenticated]) {
        [_redditClient getUsersSubscribedSubredditsWithCompletion:^(NSArray *subreddits, BOOL success) {
            self.subredditArray = subreddits;
        }];
    }
}

- (void) viewDidAppear:(BOOL)animated {
    if (![_redditClient isAuthenticated]) {
        OPRedditAuthViewController *authVC = [[OPRedditAuthViewController alloc] initWithNibName:@"OPRedditAuthViewController" bundle:nil];
        authVC.delegate = self;
        authVC.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:authVC animated:YES completion:nil];
        return;
    }
    [self.titleField becomeFirstResponder];
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

#pragma mark - OPRedditAuthDelegate

- (void) didAuthenticateWithReddit {
    [_redditClient getUsersSubscribedSubredditsWithCompletion:^(NSArray *subreddits, BOOL success) {
        self.subredditArray = subreddits;
    }];
}
@end
