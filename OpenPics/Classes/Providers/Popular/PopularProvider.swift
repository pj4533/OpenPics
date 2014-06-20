//
//  OPPopularProvider.swift
//  OpenPics
//
//  Created by PJ Gray on 6/19/14.
//  Copyright (c) 2014 Say Goodnight Software. All rights reserved.
//

import UIKit

let OPProviderTypePopular = "com.saygoodnight.loc"

class PopularProvider: OPProvider {

    init(providerType: String) {
        super.init(providerType: providerType)
        self.providerName = "Currently Popular Images"
        self.supportsInitialSearching = true
    }
    
    override func getItemsWithQuery(queryString: String!, withPageNumber pageNumber: NSNumber!, success: ((AnyObject[]!, Bool) -> Void)!, failure: ((NSError!) -> Void)!) {
        OPBackend.shared().getItemsCreatedByUserWithQuery(queryString, withPageNumber: pageNumber, success: success, failure: failure);
    }
    
    override func doInitialSearchWithSuccess(success: ((AnyObject[]!,Bool) -> Void)!, failure: ((NSError!) -> Void)!) {
        var cachedQuery = TMCache.sharedCache().objectForKey("initial_popular_query") as NSDictionary

        var items = NSDictionary()
        success(items: items, canLoadMore: false)
        
    }

//    - (void) doInitialSearchWithSuccess:(void (^)(NSArray* items, BOOL canLoadMore))success
//    failure:(void (^)(NSError* error))failure {
//    
//    NSDictionary* cachedQuery = [[TMCache sharedCache] objectForKey:@"initial_popular_query"];
//    
//    if (cachedQuery) {
//    if (success) {
//    success(cachedQuery[@"items"],[cachedQuery[@"canLoadMore"] boolValue]);
//    }
//    }
//    
//    [self getItemsWithQuery:nil
//    withPageNumber:@1
//    success:^(NSArray *items, BOOL canLoadMore) {
//    
//    if (cachedQuery && [cachedQuery[@"items"] isEqualToArray:items]) {
//    return;
//    }
//    
//    NSDictionary* newCachedQuery = @{@"items": items, @"canLoadMore":[NSNumber numberWithBool:canLoadMore]};
//    [[TMCache sharedCache] setObject:newCachedQuery forKey:@"initial_popular_query"];
//    if (success) {
//    success(items,canLoadMore);
//    }
//    }
//    failure:failure];
//    }

}
