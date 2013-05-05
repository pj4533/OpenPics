//
//  LPTumblrPostVC.h
//
//  Created by PJ Gray on 4/16/12.
//  Copyright (c) 2012 Say Goodnight Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OPTumblrBlogViewController.h"
#import "DWTagList.h"

@protocol LPTumblrPostDelegate <NSObject>
- (void) didPostTumblrWithTitle:(NSString*) titleString withTags:(NSString*) tags withState:(NSString*) state intoBlogHostName:(NSString*) blogHostName;
- (void) didCancel;
@end

@interface OPTumblrPostViewController : UIViewController <UITextFieldDelegate,OPTumblrBlogDelegate,DWTagListDelegate>

- (IBAction)cancelTapped:(id)sender;
- (IBAction)postTapped:(id)sender;
- (IBAction)switchBlogTapped:(id)sender;

@property (strong, nonatomic) IBOutlet UITextView *captionTextView;
@property (strong, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (strong, nonatomic) NSArray *blogsArray;
@property (strong, nonatomic) id delegate;

@property (strong, nonatomic) IBOutlet UIView *tagsViewBackground;
@property (strong, nonatomic) IBOutlet UITextField *tagsTextField;
@property (strong, nonatomic) NSMutableOrderedSet* tags;

@property (strong, nonatomic) IBOutlet UIView *postBackgroundView;
@property (strong, nonatomic) IBOutlet UILabel *blogNameLabel;
@property (strong, nonatomic) IBOutlet UISegmentedControl *stateControl;

@property (strong, nonatomic) NSDictionary* item;

@property (strong, nonatomic) NSString* captionText;

@end
