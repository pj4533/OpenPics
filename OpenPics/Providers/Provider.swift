//
//  Provider.swift
//  OpenPics
//
//  Created by PJ Gray on 1/2/16.
//  Copyright © 2016 Say Goodnight Software. All rights reserved.
//

import Foundation

protocol Provider {
    // this is meant to mimic the UIActivityType, is this right?  :notsureif:
    var providerType: String { get }
    
    var providerName: String { get }
    var providerShortName: String { get }
    
    func getImagesWithQuery(query: String, pageNumber: Int, completionHandler: (NSArray?, Bool?, NSError?) -> Void)
}