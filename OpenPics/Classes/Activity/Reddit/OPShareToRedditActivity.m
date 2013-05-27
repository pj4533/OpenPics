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
            [self showAlertViewWithTitle:@"Error" andMessage:[NSString stringWithFormat:@"%@", response[@"json"][@"errors"][0][1]]];
            [self activityDidFinish:NO];
            [SVProgressHUD showErrorWithStatus:@"Error."];
        } else {
            [self activityDidFinish:YES];
        }
    }];
}

- (void) showAlertViewWithTitle:(NSString*)title andMessage:(NSString*)message {
    FUIAlertView *alertView = [[FUIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
    alertView.titleLabel.textColor = [UIColor cloudsColor];
    alertView.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    alertView.messageLabel.textColor = [UIColor cloudsColor];
    alertView.messageLabel.font = [UIFont flatFontOfSize:14];
    alertView.backgroundOverlay.backgroundColor = [[UIColor cloudsColor] colorWithAlphaComponent:0.8];
    alertView.alertContainer.backgroundColor = [UIColor midnightBlueColor];
    alertView.defaultButtonColor = [UIColor cloudsColor];
    alertView.defaultButtonShadowColor = [UIColor asbestosColor];
    alertView.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
    alertView.defaultButtonTitleColor = [UIColor asbestosColor];
    [alertView show];
}

@end
