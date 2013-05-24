//
//  OPViewController.h
//  OpenPics
//
//  Created by PJ Gray on 4/6/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OPHeaderReusableView.h"
#import "OPProviderListViewController.h"
#import "OPSingleImageLayout.h"
#import "OPFlowLayout.h"

@class OPProvider;
@interface OPViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, OPHeaderDelegate, OPProviderListDelegate, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) IBOutlet UICollectionView *internalCollectionView;
@property (strong, nonatomic) OPFlowLayout *flowLayout;
@property (strong, nonatomic) OPSingleImageLayout *singleImageLayout;
@property (strong, nonatomic) NSMutableArray* items;
@property (strong, nonatomic) OPProvider* currentProvider;

- (void) forceReload;

@end
