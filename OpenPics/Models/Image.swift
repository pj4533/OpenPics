//
//  Image.swift
//  OpenPics
//
//  Created by PJ Gray on 1/2/16.
//  Copyright © 2016 Say Goodnight Software. All rights reserved.
//

import Foundation
import SwiftyJSON
import SKPhotoBrowser
import Alamofire
import AlamofireImage

// Largely copied from the Artsy model setup: https://github.com/artsy/eidolon/blob/cb31168fa29dcc7815fd4a2e30e7c000bd1820ce/Kiosk/App/Models/Artwork.swift
final class Image: NSObject, JSONAbleType, SKPhotoProtocol {
    
    let url: String
    let title: String
    
    init(url: String, title: String) {
        self.url = url
        self.title = title
        self.caption = title
    }
    
    static func fromJSON(json:[String: AnyObject]) -> Image {
        let jsonObject = JSON(json)
        let url = jsonObject["imageUrl"].stringValue
        let title = jsonObject["title"].stringValue
        
        print(jsonObject["providerType"])
        
        return Image(url: url, title: title)
    }
    
    func imageURL() -> NSURL? {
        return NSURL(string: self.url)
    }

    // MARK: SKPhoto
    
    // This is for using the SKPhotoBrowser, so that I have more control over loading of the images (ie: loading the uprezzed version)
    var underlyingImage:UIImage!
    var caption:String!
    
    func loadUnderlyingImageAndNotify() {
        Alamofire.request(.GET, self.url)
            .responseImage { response in
                if let image = response.result.value {
                    self.underlyingImage = image
                    NSNotificationCenter.defaultCenter().postNotificationName(SKPHOTO_LOADING_DID_END_NOTIFICATION, object: self)
                }
        }
    }
    
    func checkCache() {
        
    }
}
