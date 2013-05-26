//
//  OPRedditAuthViewController.h
//  OpenPics
//
//  Created by David Ohayon on 5/25/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OPRedditAuthDelegate <NSObject>

- (void) didAuthenticateWithReddit;

@end

@interface OPRedditAuthViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) id delegate;

- (IBAction)loginToReddit:(id)sender;
- (IBAction)cancelTapped:(id)sender;
@end
