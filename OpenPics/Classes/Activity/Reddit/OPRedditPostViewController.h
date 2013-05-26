//
//  OPRedditPostViewController.h
//  OpenPics
//
//  Created by David Ohayon on 5/25/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OPSubredditViewController.h"

@protocol OPRedditPostDelegate <NSObject>
- (void)didPostToRedditWithTitle:(NSString*)title toSubreddit:(NSString*)subreddit;
- (void)didCancel;
@end

@interface OPRedditPostViewController : UIViewController <OPSubredditDelegate>

@property (strong, nonatomic) NSDictionary *item;
@property (strong, nonatomic) id delegate;
@property (strong, nonatomic) NSArray *subredditArray;

@property (strong, nonatomic) IBOutlet UITextField *titleField;
@property (strong, nonatomic) IBOutlet UITextField *subredditField;
@property (strong, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (strong, nonatomic) IBOutlet UIView *postBackgroundView;
- (IBAction)cancelTapped:(id)sender;
- (IBAction)postTapped:(id)sender;
- (IBAction)switchSubredditTapped:(id)sender;

@end
