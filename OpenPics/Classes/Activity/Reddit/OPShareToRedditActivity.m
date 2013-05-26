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
        if ([thisItem isKindOfClass:[UIImage class]]) {
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
        if ([thisItem isKindOfClass:[NSDictionary class]]) {
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
    [redditClient postImage:_item[@"image"] toSubreddit:subreddit withTitle:title success:^(NSDictionary *response) {
        [self activityDidFinish:YES];
        NSLog(@"Succes Posting to Reddit");
    }];
}

@end
