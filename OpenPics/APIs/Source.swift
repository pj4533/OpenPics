//
//  ImageProvider.swift
//  OpenPics
//
//  Created by PJ Gray on 1/3/16.
//  Copyright © 2016 Say Goodnight Software. All rights reserved.
//

import Foundation
import Moya

// Not sure I like how this is global, but seems simplest for now?
// Maybe i break this out into a SourceHelper class at some point?
//
// I mean in the end, what is the difference with this and a singleton
// thats global anyway, right?
let Sources: [String:Source] = [
    PopularSource.sourceType: PopularSource(),
    LOCSource.sourceType: LOCSource()
]

var CurrentSource: Source = Sources[PopularSource.sourceType]!

protocol Source {
    var sourceName: String { get }
    var sourceShortName: String { get }
    
    static var sourceType: String { get }
    
    func getImagesWithQuery(query: String, pageNumber: Int, completionHandler: ([Image], Bool?) -> Void)
    func getHiRezURLForImage(image: Image, completionHandler: (NSURL?) -> Void)

}
