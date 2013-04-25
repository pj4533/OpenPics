//
//  OPImageViewController.h
//  OpenPics
//
//  Created by PJ Gray on 4/24/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OPImageItem;
@class OPScrollView;
@class OPProvider;
@interface OPImageViewController : UIViewController

@property (strong, nonatomic) IBOutlet OPScrollView *internalScrollView;
@property (strong, nonatomic) OPImageItem *item;
@property (strong, nonatomic) OPProvider *provider;

- (IBAction)mapTapped:(id)sender;

@end
