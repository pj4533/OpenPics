//
//  OPRedditAuthViewController.m
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


#import "OPRedditAuthViewController.h"
#import "AFRedditAPIClient.h"

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
    [self.usernameField becomeFirstResponder];
    self.passwordField.secureTextEntry = YES;

//    self.loginButton.buttonColor = [UIColor turquoiseColor];
//    self.loginButton.shadowColor = [UIColor greenSeaColor];
//    self.loginButton.shadowHeight = 3.0f;
//    self.loginButton.cornerRadius = 6.0f;
//    self.loginButton.titleLabel.font = [UIFont boldFlatFontOfSize:16];
//    [self.loginButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
//    [self.loginButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginToReddit:(id)sender {
    if (self.usernameField.text.length && self.passwordField.text.length) {
        AFRedditAPIClient *redditClient = [AFRedditAPIClient sharedClient];
        [redditClient loginToRedditWithUsername:self.usernameField.text password:self.passwordField.text completion:^(NSDictionary *response, BOOL success) {
            [self.delegate didAuthenticateWithReddit];
            if (success) {
                NSLog(@"Logged In!");
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }];
    }
}

- (IBAction)cancelTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
