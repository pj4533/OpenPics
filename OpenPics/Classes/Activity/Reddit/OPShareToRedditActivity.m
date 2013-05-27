//
//  OPShareToRedditActivity.m
//  OpenPics
//
//  Created by David Ohayon on 5/25/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

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
