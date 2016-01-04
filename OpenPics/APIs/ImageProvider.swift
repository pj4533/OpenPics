//
//  ImageProvider.swift
//  OpenPics
//
//  Created by PJ Gray on 1/3/16.
//  Copyright © 2016 Say Goodnight Software. All rights reserved.
//

import Foundation
import Moya

protocol ImageProvider {
    var name: String { get }
    var shortName: String { get }
    
    // Somehow make this a class func or something for syntax like LOCProvider.providerType
    var providerType: String { get }
    
    func getImagesWithQuery(query: String, pageNumber: Int, completionHandler: ([Image], Bool?) -> Void)
    func getHiRezURLForImage(image: Image, completionHandler: (NSURL?) -> Void)

}
