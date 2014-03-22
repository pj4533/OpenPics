//
//  OPCollectionViewController.h
//  OpenPics
//
//  Created by PJ Gray on 3/22/14.
//  Copyright (c) 2014 Say Goodnight Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OPProvider;
@interface OPCollectionViewController : UICollectionViewController

@property (strong, nonatomic) NSMutableArray* items;
@property (strong, nonatomic) OPProvider* currentProvider;

@end
