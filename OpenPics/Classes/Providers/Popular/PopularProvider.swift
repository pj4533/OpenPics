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
    
    override func doInitialSearchWithSuccess(success: ((AnyObject[]!, Bool) -> Void)!, failure: ((NSError!) -> Void)!) {
        var cachedQuery = TMCache.sharedCache().objectForKey("initial_popular_query") as NSDictionary
        
        if  (cachedQuery != nil) {
            if (success != nil) {
                var items = cachedQuery["items"] as NSArray
                var canLoadMore = cachedQuery["canLoadMore"] as NSNumber
                success(items, canLoadMore.boolValue)
            }
        }
        
        self.getItemsWithQuery(nil, withPageNumber: 1, success: {(items: AnyObject[]!, canLoadMore: Bool) in
            if ((cachedQuery != nil) && (cachedQuery["items"] as NSArray).isEqualToArray(items)) {
                return
            }
            var newCachedQuery = ["items": items, "canLoadMore": NSNumber(bool: canLoadMore)]
            TMCache.sharedCache().setObject(newCachedQuery, forKey: "initial_popular_query")
            if (success != nil) {
                success(items, canLoadMore)
            }
        }, failure: failure);
    }
}
