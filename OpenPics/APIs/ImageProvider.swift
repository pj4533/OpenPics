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
    var providerType: String { get }
    
    func getImagesWithQuery(query: String, pageNumber: Int, completionHandler: ([Image], Bool?) -> Void)
}
