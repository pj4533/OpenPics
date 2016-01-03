//
//  ImageDataSource.swift
//  OpenPics
//
//  Created by PJ Gray on 1/2/16.
//  Copyright © 2016 Say Goodnight Software. All rights reserved.
//

import UIKit
import Haneke

class ImageDataSource: NSObject, UICollectionViewDataSource {

    // why does this have to be an NSArray vs. a [Image]() which is more stongly typed?
    var images: NSArray?
    
    func loadImagesWithProvider(provider: Provider, completionHandler: (NSError?) -> Void) {
        provider.getImagesWithQuery("", pageNumber: 0) { (images, canLoadMore, error) -> Void in
            self.images = images
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completionHandler(error)
            })
        }
    }
    
    // MARK: UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
        
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        // seems like an optional should allow for if, but do i always have to do if-let?
        if let images = self.images {
            return images.count
        }
        
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("imageCell", forIndexPath: indexPath) as! ImageCollectionViewCell
        
        
        // Look at Orta's talk about where to do this...should be in a different place
        // this should just create the cell, there is an Apple example that
        // shows more about it too.

        // cause self.images is just a nsarray, we don't know the type here?
        let image = self.images![indexPath.item] as! Image

        cell.imageView.contentMode = .ScaleAspectFill
        cell.imageView.hnk_setImageFromURL(image.url)
        
        return cell
    }

}
