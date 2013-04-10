//
//  LPTumblrPostVC.m
//
//  Created by PJ Gray on 4/16/12.
//  Copyright (c) 2012 Say Goodnight Software. All rights reserved.
//

#import "OPTumblrPostViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AFTumblrAPIClient.h"
#import "OPShareToTumblrActivity.h"
#import "OPActivityTokens.h"

@interface OPTumblrPostViewController ()

@end

@implementation OPTumblrPostViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
#ifdef kOPACTIVITYTOKEN_TUMBLR
    AFTumblrAPIClient* tumblrClient = [[AFTumblrAPIClient alloc] initWithKey:kOPACTIVITYTOKEN_TUMBLR
                                                                      secret:kOPACTIVITYSECRET_TUMBLR
                                                           callbackUrlString:kTumblrCallbackURLString];
    
    if ([tumblrClient isAuthenticated])
        [tumblrClient getBlogNamesWithSuccess:^(NSArray *blogsArray) {
            self.blogsArray = blogsArray;
            
            NSURL* blogUrl = [NSURL URLWithString:[[self.blogsArray objectAtIndex:0] objectForKey:@"url"]];
            NSString* blogHostName = [blogUrl host];
            self.blogNameLabel.text = blogHostName;
        } withFailure:^{
            
        }];
    else {
        [tumblrClient authenticateWithCompletion:^{
            [tumblrClient getBlogNamesWithSuccess:^(NSArray *blogsArray) {
                self.blogsArray = blogsArray;

                NSURL* blogUrl = [NSURL URLWithString:[[self.blogsArray objectAtIndex:0] objectForKey:@"url"]];
                NSString* blogHostName = [blogUrl host];
                self.blogNameLabel.text = blogHostName;
            } withFailure:^{
                
            }];
        }];
    }
#endif
    
    self.postBackgroundView.layer.borderWidth = 1;
	self.postBackgroundView.layer.cornerRadius = 3;
	self.postBackgroundView.clipsToBounds = YES;

    self.thumbnailImageView.clipsToBounds = YES;
    
    [self.captionTextView becomeFirstResponder];
    
    self.tagsTextField.tag = 1;
    
    self.thumbnailImageView.image = self.image;
    self.captionTextView.text = self.captionText;
}

- (void) viewDidAppear:(BOOL)animated {
}

- (void)viewDidUnload
{
    [self setCaptionTextView:nil];
    [self setThumbnailImageView:nil];
    [self setTagsTextField:nil];
    [self setPostBackgroundView:nil];
    [self setBlogNameLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (IBAction)cancelTapped:(id)sender {
    [self.delegate didCancel];
}

- (IBAction)postTapped:(id)sender {
    NSString* stateString = [self.stateControl titleForSegmentAtIndex:self.stateControl.selectedSegmentIndex];
    [self.delegate didPostTumblrWithTitle:self.captionTextView.text withTags:self.tagsTextField.text withState:stateString.lowercaseString intoBlogHostName:self.blogNameLabel.text];
}

- (void) didSelectBlogWithHostName:(NSString *)blogHostName {
    self.blogNameLabel.text = blogHostName;
}

- (IBAction)switchBlogTapped:(id)sender {
    OPTumblrBlogViewController* tumblrBlog = [[OPTumblrBlogViewController alloc] initWithNibName:@"OPTumblrBlogViewController" bundle:nil];
    tumblrBlog.modalPresentationStyle = UIModalPresentationFormSheet;
    tumblrBlog.blogs = self.blogsArray;
    tumblrBlog.delegate = self;
    [self presentViewController:tumblrBlog animated:YES completion:nil];
}

@end
