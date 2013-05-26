//
//  OPSubredditViewController.h
//  OpenPics
//
//  Created by David Ohayon on 5/26/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OPSubredditDelegate <NSObject>
- (void) didSelectSubreddit:(NSString*)subreddit;
@end

@interface OPSubredditViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *subredditTableView;
@property (strong, nonatomic) NSArray *subreddits;
@property (strong, nonatomic) id delegate;
- (IBAction)cancelTapped:(id)sender;

@end
