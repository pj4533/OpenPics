//
//  OPRedditPostViewController.h
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


#import <UIKit/UIKit.h>
#import "OPSubredditViewController.h"
#import "OPImageItem.h"
#import "OPRedditAuthViewController.h"

@protocol OPRedditPostDelegate <NSObject>
- (void)didPostToRedditWithTitle:(NSString*)title toSubreddit:(NSString*)subreddit;
- (void)didCancel;
@end

@interface OPRedditPostViewController : UIViewController <OPSubredditDelegate, OPRedditAuthDelegate>

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
