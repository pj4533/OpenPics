//
//  Image.swift
//  OpenPics
//
//  Created by PJ Gray on 1/2/16.
//  Copyright © 2016 Say Goodnight Software. All rights reserved.
//

import UIKit

// Not necessary to derive from NSObject here, but I like to cause
// i can then use things like valueForKey on properties.
class Image: NSObject {
    
    var url: NSURL?
    
    init(jsonDictionary: NSDictionary) {
        if let urlString = jsonDictionary["imageUrl"] as? String {
            self.url = NSURL(string: urlString)
        }
    }
}
