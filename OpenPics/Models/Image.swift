//
//  Image.swift
//  OpenPics
//
//  Created by PJ Gray on 1/2/16.
//  Copyright © 2016 Say Goodnight Software. All rights reserved.
//

import Foundation
import SwiftyJSON

// Largely copied from the Artsy model setup: https://github.com/artsy/eidolon/blob/cb31168fa29dcc7815fd4a2e30e7c000bd1820ce/Kiosk/App/Models/Artwork.swift
final class Image: NSObject, JSONAbleType {
    
    let url: String
    
    init(url: String) {
        self.url = url
    }
    
    static func fromJSON(json:[String: AnyObject]) -> Image {
        let json = JSON(json)
        let url = json["imageUrl"].stringValue
        
        return Image(url: url)
    }
    
    func imageURL() -> NSURL? {
        return NSURL(string: self.url)
    }
}
