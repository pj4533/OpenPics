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
import Haneke

// Largely copied from the Artsy model setup: https://github.com/artsy/eidolon/blob/cb31168fa29dcc7815fd4a2e30e7c000bd1820ce/Kiosk/App/Models/Artwork.swift
final class Image: NSObject, JSONAbleType, SKPhotoProtocol {
    
    let url: String
    let title: String
    let providerType: String
    let providerSpecific: SwiftyJSON.JSON
    
    init(url: String, title: String, providerSpecific: SwiftyJSON.JSON, providerType: String) {
        self.url = url
        self.title = title
        self.caption = title
        self.providerSpecific = providerSpecific
        self.providerType = providerType
    }
    
    static func fromJSON(json:[String: AnyObject]) -> Image {
        let jsonObject = JSON(json)
        let url = jsonObject["imageUrl"].stringValue
        let title = jsonObject["title"].stringValue
        let providerSpecific = jsonObject["providerSpecific"]
        let providerType = jsonObject["providerType"].stringValue

        return Image(url: url, title: title, providerSpecific: providerSpecific, providerType: providerType)
    }
    
    func imageURL() -> NSURL? {
        return NSURL(string: self.url)
    }

    // MARK: SKPhoto
    
    // This is for using the SKPhotoBrowser, so that I have more control over loading of the images (ie: loading the uprezzed version)
    var underlyingImage:UIImage!
    var caption:String!
    
    func loadUnderlyingImageAndNotify() {
        
        // This is a hack obviously, just until i have a more permanent solution i hardcode hirezzing to LibraryOfCongress
        if self.providerType == "com.saygoodnight.loc" {
            let provider = LOCProvider()
            provider.getHiRezURLForImage(self, completionHandler: { (url) -> Void in
                if let hiRezURL = url {
                    Alamofire.request(.GET, hiRezURL)
                        .responseImage { response in
                            if let image = response.result.value {
                                self.underlyingImage = image
                                NSNotificationCenter.defaultCenter().postNotificationName(SKPHOTO_LOADING_DID_END_NOTIFICATION, object: self)
                            }
                    }
                }
            })
        } else {
            // If no hi rez, then just use the image from the Haneke cache
            if let url = self.imageURL() {
                let cache = Shared.imageCache
                cache.fetch(URL: url).onSuccess({ (image) -> () in
                    self.underlyingImage = image
                    NSNotificationCenter.defaultCenter().postNotificationName(SKPHOTO_LOADING_DID_END_NOTIFICATION, object: self)
                })
            }
        }
    }
    
    func checkCache() {
        
    }
}
