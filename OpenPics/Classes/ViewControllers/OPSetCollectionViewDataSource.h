//
//  OPSetCollectionViewDataSource.h
//  OpenPics
//
//  Created by PJ Gray on 6/22/14.
//  Copyright (c) 2014 Say Goodnight Software. All rights reserved.
//

#import "OPCollectionViewDataSource.h"

@class OPItem;
@interface OPSetCollectionViewDataSource : OPCollectionViewDataSource

@property (weak, nonatomic) OPItem* setItem;

@end
