//
//  LPTumblrPostVC.h
//
//  Created by PJ Gray on 4/16/12.
//  Copyright (c) 2012 Say Goodnight Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OPTumblrBlogViewController.h"

@protocol LPTumblrPostDelegate <NSObject>
- (void) didPostTumblrWithTitle:(NSString*) titleString withTags:(NSString*) tags intoBlogHostName:(NSString*) blogHostName;
- (void) didCancel;
@end

@interface OPTumblrPostViewController : UIViewController <UITextFieldDelegate,OPTumblrBlogDelegate>

- (IBAction)cancelTapped:(id)sender;
- (IBAction)postTapped:(id)sender;
- (IBAction)switchBlogTapped:(id)sender;

@property (strong, nonatomic) IBOutlet UITextView *captionTextView;
@property (strong, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (strong, nonatomic) NSArray *blogsArray;
@property (strong, nonatomic) id delegate;
@property (strong, nonatomic) IBOutlet UITextField *tagsTextField;
@property (strong, nonatomic) IBOutlet UIView *postBackgroundView;
@property (strong, nonatomic) IBOutlet UILabel *blogNameLabel;

@property (strong, nonatomic) UIImage* image;
@property (strong, nonatomic) NSString* captionText;

@end
