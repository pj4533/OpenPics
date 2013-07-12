//
//  OPMainCollectionViewController.h
//  OpenPics
//
//  Created by PJ Gray on 6/11/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SGSStaggeredFlowLayout.h"
#import "OPProviderTableViewController.h"

@class OPProvider;

@interface OPMainCollectionViewController : UICollectionViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, OPProviderTableDelegate>


@property (strong, nonatomic) SGSStaggeredFlowLayout *flowLayout;



@property (strong, nonatomic) NSMutableArray* items;
@property (strong, nonatomic) OPProvider* currentProvider;

- (void) forceReload;

@end
