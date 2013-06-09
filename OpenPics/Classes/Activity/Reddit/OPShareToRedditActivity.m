//
//  OPShareToRedditActivity.m
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


#import "OPShareToRedditActivity.h"
#import "AFRedditAPIClient.h"
#import "SVProgressHUD.h"
#import "OPImageItem.h"
#import "FUIAlertView+ShowAlert.h"
#import "FUIAlertView.h"

NSString * const UIActivityTypeShareToReddit = @"com.ohwutup.share_to_reddit";

@interface OPShareToRedditActivity () {
    OPRedditPostViewController *_redditVC;
    NSDictionary *_item;
}
@end

@implementation OPShareToRedditActivity

- (UIImage*) activityImage {
    return [UIImage imageNamed:@"reddit-alien.png"];
}

- (NSString*) activityTitle {
    return @"Share To Reddit";
}

- (NSString*) activityType {
    return UIActivityTypeShareToReddit;
}

- (BOOL) canPerformWithActivityItems:(NSArray *)activityItems {
    for (id thisItem in activityItems) {
        if ([thisItem isKindOfClass:[OPImageItem class]]) {
            NSLog(@"KIND: OPIMAGEITEM");
            return YES;
        } else if ([thisItem isKindOfClass:[UIImage class]]) {
            NSLog(@"KIND: IMAGE");
            return YES;
        } else if ([thisItem isKindOfClass:[NSDictionary class]])
            NSLog(@"KIND: DICT");
        return YES;
    }
    
    return NO;
}

- (void) prepareWithActivityItems:(NSArray *)activityItems {
    for (id thisItem in activityItems) {
        if ([thisItem isKindOfClass:[NSDictionary class]] || [thisItem isKindOfClass:[OPImageItem class]]) {
            _item = thisItem;
            _redditVC = [[OPRedditPostViewController alloc] initWithNibName:@"OPRedditPostViewController" bundle:nil];
            _redditVC.modalPresentationStyle = UIModalPresentationFormSheet;
            _redditVC.item = thisItem;
            _redditVC.delegate = self;
        }
    }
}

- (UIViewController*) activityViewController {
    return _redditVC;
}

#pragma mark - OPRedditPostDelegate

- (void) didCancel {
    [self activityDidFinish:NO];
}

- (void)didPostToRedditWithTitle:(NSString *)title toSubreddit:(NSString *)subreddit {
    AFRedditAPIClient *redditClient = [AFRedditAPIClient sharedClient];
    [SVProgressHUD showWithStatus:@"Posting..."];
    [redditClient postItem:_item toSubreddit:subreddit withTitle:title completion:^(NSDictionary *response, BOOL success) {
        if (!success) {
            [FUIAlertView showOkayAlertViewWithTitle:@"Error" message:[NSString stringWithFormat:@"%@", response[@"errors"][0][1]] andDelegate:self];
            [self activityDidFinish:NO];
            [SVProgressHUD showErrorWithStatus:@"Error."];
        } else {
            [self activityDidFinish:YES];
        }
    }];
}

@end
