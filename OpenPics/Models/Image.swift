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
    let sourceType: String
    let sourceSpecific: SwiftyJSON.JSON
    
    init(url: String?, title: String?, sourceSpecific: SwiftyJSON.JSON, sourceType: String) {
        if let url = url {
            self.url = url
        } else {
            self.url = ""
        }
        if let title = title {
            self.title = title
            self.caption = title
        } else {
            self.title = ""
            self.caption = title
        }
        self.sourceSpecific = sourceSpecific
        self.sourceType = sourceType
    }
    
    static func fromJSON(json:[String: AnyObject]) -> Image {
        let jsonObject = JSON(json)
        return Image.fromJSON(jsonObject)
    }
    
    static func fromJSON(json: SwiftyJSON.JSON) -> Image {
        let url = json["imageUrl"].stringValue
        let title = json["title"].stringValue
        
        // these are throwbacks to pre-3.0 days when they were called providers
        let sourceSpecific = json["providerSpecific"]
        let sourceType = json["providerType"].stringValue
        
        return Image(url: url, title: title, sourceSpecific: sourceSpecific, sourceType: sourceType)
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
        if self.sourceType == LOCSource.sourceType {
            let source = Sources[LOCSource.sourceType]
            source!.getHiRezURLForImage(self, completionHandler: { (url) -> Void in
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
