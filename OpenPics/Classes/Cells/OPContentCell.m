//
//  OPContentCell.m
//
//  Created by PJ Gray on 2/10/13.
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


#import "OPContentCell.h"
#import "AFNetworking.h"
#import "OPItem.h"
#import <QuartzCore/QuartzCore.h>
#import "OPFavoritesProvider.h"
#import "OPPopularProvider.h"
#import "OPProvider.h"
#import "OPProviderController.h"

@interface OPContentCell () {
    AFHTTPRequestOperation* _upRezOperation;
    
    BOOL _shouldForceReloadOnBack;
}

@end

@implementation OPContentCell

- (void) awakeFromNib {
    [super awakeFromNib];
    
    UITapGestureRecognizer* doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapped:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    [self.internalScrollView addGestureRecognizer:doubleTapGesture];
    
    UITapGestureRecognizer* singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [singleTapGesture requireGestureRecognizerToFail:doubleTapGesture];
    [self.internalScrollView addGestureRecognizer:singleTapGesture];
    
    UILongPressGestureRecognizer* longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self.internalScrollView addGestureRecognizer:longPressGesture];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - Utility Functions

- (void) setupForSingleImageLayoutAnimated:(BOOL) animated {
    
#warning hack
    for (UIImageView* imageView in self.internalScrollView.imageView.subviews) {
        imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    self.internalScrollView.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.internalScrollView.userInteractionEnabled = YES;

    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber* uprezMode = [currentDefaults objectForKey:@"uprezMode"];
    
    OPProvider* thisItemProvider = [[OPProviderController shared] getProviderWithType:self.item.providerType];
    if (uprezMode && uprezMode.boolValue) {
        // this is kind of weird cause in some cases the item is modified by the provider on uprezing
        // I should probably somehow change the main reference to the object so we don't have different
        // versions?
        [thisItemProvider fullUpRezItem:self.item withCompletion:^(NSURL *uprezImageUrl, OPItem* item) {
            NSLog(@"FULL UPREZ TO: %@", uprezImageUrl.absoluteString);
            self.item = item;
            [self upRezToImageWithUrl:uprezImageUrl];
        }];
    } else {
        [thisItemProvider upRezItem:self.item withCompletion:^(NSURL *uprezImageUrl, OPItem* item) {
            NSLog(@"UPREZ TO: %@", uprezImageUrl.absoluteString);
            self.item = item;
            [self upRezToImageWithUrl:uprezImageUrl];
        }];
    }
}

- (void) upRezToImageWithUrl:(NSURL*) url {
    if (_upRezOperation) {
        [_upRezOperation cancel];
        _upRezOperation = nil;
    }
    
    __weak __typeof(self)weakSelf = self;
    __weak UIImageView* imageView = self.internalScrollView.imageView;
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:url];
    _upRezOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    _upRezOperation.responseSerializer = [AFImageResponseSerializer serializer];
    [_upRezOperation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(showProgressWithBytesRead:withTotalBytesRead:withTotalBytesExpectedToRead:)]) {
            [weakSelf.delegate showProgressWithBytesRead:bytesRead
                                      withTotalBytesRead:totalBytesRead
                            withTotalBytesExpectedToRead:totalBytesExpectedToRead];
        }
    }];
    [_upRezOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        imageView.image = (UIImage*) responseObject;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"UPREZ FAILED: %@", error.localizedDescription);
    }];
    [_upRezOperation start];
}

#pragma mark - gesture stuff

- (IBAction)tapped:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(singleTappedCell)]) {
        [self.delegate singleTappedCell];
    }
}

- (IBAction)doubleTapped:(id)sender {
    UIGestureRecognizer* theTap = (UIGestureRecognizer*) sender;
    
    OPScrollView* thisScrollView = (OPScrollView*) theTap.view;
    
    if (thisScrollView.zoomScale == 1.0f) {
        CGPoint centerPoint = [theTap locationInView:thisScrollView];
        
        CGRect toZoom;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            toZoom = CGRectMake(centerPoint.x - 50.0f, centerPoint.y - 50.0f, 100.0f, 100.0f);
        else
            toZoom = CGRectMake(centerPoint.x - 50.0f, centerPoint.y - 50.0f, 200.0f, 200.0f);
        
        [thisScrollView zoomToRect:toZoom animated:YES];
    } else {
        [thisScrollView setZoomScale:1.0f animated:YES];
    }
    
}

-  (void)longPress:(UILongPressGestureRecognizer*)sender {
    if ( (sender.state == UIGestureRecognizerStateEnded) || (sender.state == UIGestureRecognizerStateBegan)){
        if (self.internalScrollView.imageView.contentMode == UIViewContentModeCenter) {
            self.internalScrollView.imageView.contentMode = UIViewContentModeScaleAspectFit;
        } else {
            self.internalScrollView.imageView.contentMode = UIViewContentModeCenter;
        }
    }
}

@end
