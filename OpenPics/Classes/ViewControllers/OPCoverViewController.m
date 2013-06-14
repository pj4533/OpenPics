//
//  OPCoverViewController.m
//  OpenPics
//
//  Created by PJ Gray on 6/12/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import "OPCoverViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AFNetworking.h"

#define RANDOMNUM 140
#define EDGEOFFSET 60
#define ZOOMOFFSET 300
#define ZOOMLEVELOFFSET 150

#define MINXDIFFERENCE 70
#define MINYDIFFERENCE 70
#define MINZOOMDIFFERENCE 50

@interface OPCoverViewController () {
    UIImageView* _currentlyShowingImageView;
    NSMutableArray* _featuredImageUrls;
    NSInteger _currentIndex;
}

@end

@implementation OPCoverViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UISwipeGestureRecognizer* leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureTriggered:)];
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    UISwipeGestureRecognizer* rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureTriggered:)];
    rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:leftSwipe];
    [self.view addGestureRecognizer:rightSwipe];
    
    _currentIndex = 0;
    self.coverImage1.alpha = 0.0f;
    self.coverImage2.alpha = 0.0f;
    
    _featuredImageUrls = [@[
                           [NSURL URLWithString:@"http://www.gstatic.com/hostedimg/2a27fbddca0353a5_landing"],
                           [NSURL URLWithString:@"http://www.gstatic.com/hostedimg/2c75786f04412b07_landing"],
                           [NSURL URLWithString:@"http://www.gstatic.com/hostedimg/86083c20e33c548a_landing"],
                           [NSURL URLWithString:@"http://www.gstatic.com/hostedimg/3073bdd5f67ec8da_landing"]
                           ] mutableCopy];
    
    
    
    [self shuffleArray:_featuredImageUrls];
    
    NSURLRequest* urlRequest = [[NSURLRequest alloc] initWithURL:_featuredImageUrls[_currentIndex]];
    [self.coverImage1 setImageWithURLRequest:urlRequest placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        self.coverImage1.image = image;
        [self animateCoverImage:self.coverImage1];
    } failure:nil];
    
    
    _currentIndex++;
    if (_currentIndex == [_featuredImageUrls count])
        _currentIndex = 0;
    [self.coverImage2 setImageWithURL:_featuredImageUrls[_currentIndex]];
    
    self.slideLabel.layer.shadowColor = [self.slideLabel.textColor CGColor];
    self.slideLabel.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    self.slideLabel.layer.shadowRadius = 2.0;
    self.slideLabel.layer.shadowOpacity = 0.5;
    self.slideLabel.layer.masksToBounds = NO;
}

- (void) viewDidAppear:(BOOL)animated {
    UIInterpolatingMotionEffect* motionEffectCenterX = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    
    motionEffectCenterX.minimumRelativeValue = @(-160.0);
    motionEffectCenterX.maximumRelativeValue = @(160.0);

    UIInterpolatingMotionEffect* motionEffectCenterY = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    
    motionEffectCenterY.minimumRelativeValue = @(-284.0);
    motionEffectCenterY.maximumRelativeValue = @(284.0);

    [self.imageContainerView addMotionEffect:motionEffectCenterX];
    [self.imageContainerView addMotionEffect:motionEffectCenterY];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) animateCoverImage:(UIImageView*) imageView {
    NSInteger randomOffsetX_start = -( EDGEOFFSET+(arc4random() % (RANDOMNUM)));
    NSInteger randomOffsetY_start = -( EDGEOFFSET+(arc4random() % (RANDOMNUM)));
    
    NSInteger randomOffsetX_finish;
    NSInteger randomOffsetY_finish;
    
    do {
        randomOffsetX_finish = -( EDGEOFFSET+(arc4random() % (RANDOMNUM)));
        //        NSLog(@"xdiff: %d  min: %d randomnum: %d", abs(randomOffsetX_finish - randomOffsetX_start), MINXDIFFERENCE, RANDOMNUM);
    } while (abs(randomOffsetX_finish - randomOffsetX_start) < MINXDIFFERENCE);
    do {
        randomOffsetY_finish = -( EDGEOFFSET+(arc4random() % (RANDOMNUM)));
        //        NSLog(@"ydiff: %d  min: %d randomnum: %d", abs(randomOffsetY_finish - randomOffsetY_start), MINXDIFFERENCE, RANDOMNUM);
    } while (abs(randomOffsetY_finish - randomOffsetY_start) < MINYDIFFERENCE);
    
    //    NSLog(@"xmindiff: %d    ymindiff: %d", abs(randomOffsetX_finish - randomOffsetX_start),  abs(randomOffsetY_finish - randomOffsetY_start));
    
    
    NSInteger randomZoomOffset;
    
    if (arc4random() % 2) {
        randomZoomOffset = (ZOOMLEVELOFFSET/2) + (arc4random() % (ZOOMLEVELOFFSET/2));
        
    } else {
        randomZoomOffset = -((ZOOMLEVELOFFSET/2) + (arc4random() % (ZOOMLEVELOFFSET/2)));
        
    }
    
    imageView.alpha = 0.0f;
    //    NSLog(@"randomZoomOffset: %d", randomZoomOffset);
    _currentlyShowingImageView = imageView;
    
    if (UIDeviceOrientationIsLandscape(self.interfaceOrientation)) {
        imageView.frame = CGRectMake(randomOffsetX_start, randomOffsetY_start,[UIScreen mainScreen].bounds.size.height+ZOOMOFFSET, [UIScreen mainScreen].bounds.size.width+ZOOMOFFSET);
    } else {
        imageView.frame = CGRectMake(randomOffsetX_start, randomOffsetY_start,[UIScreen mainScreen].bounds.size.width+ZOOMOFFSET, [UIScreen mainScreen].bounds.size.height+ZOOMOFFSET);
    }
    
    
    [UIView animateWithDuration:2.0f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        imageView.alpha = 1.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:2.0f delay:14.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            imageView.alpha = 0.0;
        } completion:^(BOOL finished) {
            _currentIndex++;
            if (_currentIndex == [_featuredImageUrls count])
                _currentIndex = 0;
            if ((_currentlyShowingImageView == nil) || (_currentlyShowingImageView == self.coverImage2)) {
                [self.coverImage1 setImageWithURL:_featuredImageUrls[_currentIndex]];
            } else {
                [self.coverImage2 setImageWithURL:_featuredImageUrls[_currentIndex]];
            }
        }];
    }];
    
    [UIView animateWithDuration:15 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        imageView.frame = CGRectMake(randomOffsetX_finish, randomOffsetY_finish, imageView.frame.size.width-randomZoomOffset, imageView.frame.size.height-randomZoomOffset);
    } completion:^(BOOL finished) {
        if (finished) {
            if ((_currentlyShowingImageView == nil) || (_currentlyShowingImageView == self.coverImage2)) {
                [self animateCoverImage:self.coverImage1];
            } else {
                [self animateCoverImage:self.coverImage2];
            }
        }
    }];
    
}

static NSUInteger random_below(NSUInteger n) {
    NSUInteger m = 1;
    
    // Compute smallest power of two greater than n.
    // There's probably a faster solution than this loop, but bit-twiddling
    // isn't my specialty.
    do {
        m <<= 1;
    } while(m < n);
    
    NSUInteger ret;
    
    do {
        ret = arc4random() % m;
    } while(ret >= n);
    
    return ret;
}

- (void) shuffleArray:(NSMutableArray*) thisArray {
    // http://en.wikipedia.org/wiki/Knuth_shuffle
    
    for(NSUInteger i = [thisArray count]; i > 1; i--) {
        NSUInteger j = random_below(i);
        [thisArray exchangeObjectAtIndex:i-1 withObjectAtIndex:j];
    }
}

- (void)swipeGestureTriggered:(UISwipeGestureRecognizer *)swipeGesture {
    [self performSegueWithIdentifier:@"crossDissolve" sender:self];
}


@end
