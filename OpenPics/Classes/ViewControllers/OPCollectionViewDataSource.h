//
//  OPCollectionViewDataSource.h
//  OpenPics
//
//  Created by PJ Gray on 5/4/14.
//  Copyright (c) 2014 Say Goodnight Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OPCollectionViewDataSource : NSObject <UICollectionViewDataSource>

@property (strong, nonatomic) NSString* currentQueryString;

- (void) doInitialSearchWithSuccess:(void (^)(NSArray* items, BOOL canLoadMore))success
                            failure:(void (^)(NSError* error))failure;

- (void) getMoreItemsWithSuccess:(void (^)(NSArray* indexPaths))success
                         failure:(void (^)(NSError* error))failure;

- (void) clearData;

@end
