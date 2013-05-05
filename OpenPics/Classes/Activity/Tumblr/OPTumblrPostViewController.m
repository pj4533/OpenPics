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

@interface OPTumblrPostViewController () {
    DWTagList* _tagList;
}

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
    
    self.thumbnailImageView.image = self.item[@"image"];
    self.captionTextView.text = self.captionText;
}

- (void) viewDidAppear:(BOOL)animated {
    [self setupSuggestedTags];
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

#pragma mark - Helpers

- (void) setupSuggestedTags {
    NSMutableOrderedSet* tags = [[NSMutableOrderedSet alloc] init];
    NSLinguisticTaggerOptions options = NSLinguisticTaggerOmitWhitespace | NSLinguisticTaggerOmitPunctuation | NSLinguisticTaggerJoinNames;
    NSLinguisticTagger *tagger = [[NSLinguisticTagger alloc] initWithTagSchemes: [NSLinguisticTagger availableTagSchemesForLanguage:@"en"] options:options];
    
    
    [tags addObject:@"vintage"];
    
    tagger.string = self.item[@"title"];
    [tagger enumerateTagsInRange:NSMakeRange(0, [tagger.string length]) scheme:NSLinguisticTagSchemeNameTypeOrLexicalClass options:options usingBlock:^(NSString *tag, NSRange tokenRange, NSRange sentenceRange, BOOL *stop) {
        NSString *token = [tagger.string substringWithRange:tokenRange];
        
        if (
            [tag isEqualToString:NSLinguisticTagOtherWord] ||
            [tag isEqualToString:NSLinguisticTagNoun] ||
            [tag isEqualToString:NSLinguisticTagOrganizationName] ||
            [tag isEqualToString:NSLinguisticTagPlaceName] ||
            [tag isEqualToString:NSLinguisticTagNumber] ||
            [tag isEqualToString:NSLinguisticTagPersonalName]
            ) {
            [tags addObject:token];
        }
    }];
    
    self.tags = tags;
    
    if (_tagList) {
        [_tagList removeFromSuperview];
    }
    
    // Initalise and set the frame of the tag list
    _tagList = [[DWTagList alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tagsViewBackground.frame.size.width, self.tagsViewBackground.frame.size.height)];
    
    // Add the items to the array
    [_tagList setTags:[self.tags array]];
    _tagList.tagDelegate = self;
    
    // Add the taglist to your UIView
    [self.tagsViewBackground addSubview:_tagList];    
}

#pragma mark - Actions

- (IBAction)cancelTapped:(id)sender {
    [self.delegate didCancel];
}

- (IBAction)postTapped:(id)sender {
    NSString* stateString = [self.stateControl titleForSegmentAtIndex:self.stateControl.selectedSegmentIndex];
    [self.delegate didPostTumblrWithTitle:self.captionTextView.text withTags:self.tagsTextField.text withState:stateString.lowercaseString intoBlogHostName:self.blogNameLabel.text];
}

- (IBAction)switchBlogTapped:(id)sender {
    OPTumblrBlogViewController* tumblrBlog = [[OPTumblrBlogViewController alloc] initWithNibName:@"OPTumblrBlogViewController" bundle:nil];
    tumblrBlog.modalPresentationStyle = UIModalPresentationFormSheet;
    tumblrBlog.blogs = self.blogsArray;
    tumblrBlog.delegate = self;
    [self presentViewController:tumblrBlog animated:YES completion:nil];
}

#pragma mark - OPTumblrBlogDelegate

- (void) didSelectBlogWithHostName:(NSString *)blogHostName {
    self.blogNameLabel.text = blogHostName;
}

#pragma mark - DWTagsListDelegate

- (void)selectedTag:(NSString*)tagName {
    self.tagsTextField.text = [self.tagsTextField.text stringByAppendingFormat:@"%@,", tagName];
}


@end
