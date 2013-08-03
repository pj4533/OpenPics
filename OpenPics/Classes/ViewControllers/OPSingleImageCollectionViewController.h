//
//  OPSingleImageCollectionViewController.h
//  OpenPics
//
//  Created by PJ Gray on 6/11/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OPProvider;

@interface OPSingleImageCollectionViewController : UICollectionViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>


@property (strong, nonatomic) NSMutableArray* items;
@property (strong, nonatomic) NSIndexPath* indexPath;
@property (strong, nonatomic) OPProvider* currentProvider;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *favoritesButton;


@end
