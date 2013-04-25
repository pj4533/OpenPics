//
//  OPImageViewController.m
//  OpenPics
//
//  Created by PJ Gray on 4/24/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import "OPImageViewController.h"
#import "OPScrollView.h"
#import "OPImageItem.h"
#import "AFImageRequestOperation.h"
#import "OPProvider.h"

@interface OPImageViewController ()

@end

@implementation OPImageViewController

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
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:self.item.imageUrl];
    self.internalScrollView.imageView.contentMode = UIViewContentModeCenter;
    self.internalScrollView.imageView.alpha = 0.0f;
    self.internalScrollView.imageView.image = [UIImage imageNamed:@"hourglass_white"];
    
    AFImageRequestOperation* operation = [AFImageRequestOperation imageRequestOperationWithRequest:request imageProcessingBlock:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        if ([self.item.imageUrl isEqual:request.URL]) {
            [UIView animateWithDuration:0.25 animations:^{
                self.internalScrollView.imageView.alpha = 0.0;
            } completion:^(BOOL finished) {
                self.internalScrollView.imageView.contentMode = UIViewContentModeScaleAspectFit;
                self.internalScrollView.imageView.image = image;
                [UIView animateWithDuration:0.5 animations:^{
                    self.internalScrollView.imageView.alpha = 1.0;
                }];
            }];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"error getting image");
    }];
    [operation start];
    
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber* uprezMode = [currentDefaults objectForKey:@"uprezMode"];
    if (uprezMode && uprezMode.boolValue) {
        [self.provider fullUpRezItem:self.item withCompletion:^(NSURL *uprezImageUrl) {
            NSLog(@"FULL UPREZ TO: %@", uprezImageUrl.absoluteString);
            [self upRezToImageWithUrl:uprezImageUrl];
        }];
    } else {
        [self.provider upRezItem:self.item withCompletion:^(NSURL *uprezImageUrl) {
            NSLog(@"UPREZ TO: %@", uprezImageUrl.absoluteString);
            [self upRezToImageWithUrl:uprezImageUrl];
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)mapTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Utilities

- (void) upRezToImageWithUrl:(NSURL*) url {
    
    UIImageView* imageView = self.internalScrollView.imageView;
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:url];
    
    AFImageRequestOperation* operation = [AFImageRequestOperation imageRequestOperationWithRequest:request imageProcessingBlock:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        imageView.image = image;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
    }];
    [operation start];
}



@end
