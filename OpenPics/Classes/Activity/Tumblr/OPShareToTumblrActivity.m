//
//  SGShareToTumblrActivity.m
//
//  Created by PJ Gray on 9/14/12.
//  Copyright (c) 2012 PJ Gray. All rights reserved.
//

#import "OPShareToTumblrActivity.h"
#import "AFTumblrAPIClient.h"
#import "OPActivityTokens.h"

NSString * const kTumblrCallbackURLString = @"openpics://success";

NSString * const UIActivityTypeShareToTumblr = @"com.saygoodnight.share_to_tumblr";

@interface OPShareToTumblrActivity () {
    OPTumblrPostViewController* _tumblrVC;
    NSDictionary* _item;
}

@end

@implementation OPShareToTumblrActivity

- (UIImage*) activityImage {
    return [UIImage imageNamed:@"tumblr.png"];
}

- (NSString*) activityTitle {
    return @"Share To Tumblr";
}

- (NSString*) activityType {
    return UIActivityTypeShareToTumblr;
}

- (BOOL) canPerformWithActivityItems:(NSArray *)activityItems {
    for (id thisItem in activityItems) {
        if ([thisItem isKindOfClass:[UIImage class]]) {
            return YES;
        }
    }
    
    return NO;
}

- (void) prepareWithActivityItems:(NSArray *)activityItems {

    for (id thisItem in activityItems) {
        if ([thisItem isKindOfClass:[UIImage class]]) {
            _item = @{@"image":thisItem};
            _tumblrVC = [[OPTumblrPostViewController alloc] initWithNibName:@"OPTumblrPostViewController" bundle:nil];
            _tumblrVC.modalPresentationStyle = UIModalPresentationFormSheet;
            _tumblrVC.captionTextView.text = @"";
            _tumblrVC.image = (UIImage*) thisItem;
            _tumblrVC.delegate = self;
        }
    }
}

- (UIViewController*) activityViewController {
    return _tumblrVC;
}

- (void) performActivity {
}

#pragma mark - LPTumblrPostDelegate

- (void) didCancel {
    [self activityDidFinish:NO];
}

- (void) didPostTumblrWithTitle:(NSString *)titleString withTags:(NSString*) tags intoBlogHostName:(NSString*) blogHostName {

#ifdef kOPACTIVITYTOKEN_TUMBLR
    AFTumblrAPIClient* tumblrClient = [[AFTumblrAPIClient alloc] initWithKey:kOPACTIVITYTOKEN_TUMBLR
                                                                      secret:kOPACTIVITYSECRET_TUMBLR
                                                           callbackUrlString:kTumblrCallbackURLString];
    [tumblrClient postPhotoWithData:UIImageJPEGRepresentation([_item objectForKey:@"image"], 0.8)
                           withTags:tags
                   withClickThruUrl:@""
                        withCaption:titleString
                   intoBlogHostName:blogHostName
                            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                [self activityDidFinish:YES];
                                NSLog(@"RESPONSE: %@", responseObject);                                
                            }
                            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                [self activityDidFinish:NO];
                                NSLog(@"ERROR: %@", error);
                            }];
#endif

}

@end
