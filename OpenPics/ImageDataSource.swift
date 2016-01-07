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

    var images: [Image]?
    var currentPage = 0
    var query: String = ""
    
    func loadImagesWithQuery(query: String, completionHandler: () -> Void) {
        self.query = query
        CurrentSource.getImagesWithQuery(query, pageNumber: self.currentPage) { (images, canLoadMore) -> Void in
            self.images = images
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completionHandler()
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
        
        // Paging...this could be tightened up i bet....
        if indexPath.item == ((self.images?.count)!-1) {
            self.currentPage = self.currentPage + 1
            CurrentSource.getImagesWithQuery(self.query, pageNumber: self.currentPage) { (images, canLoadMore) -> Void in
                var indexPaths: [NSIndexPath] = []
                for i in 0..<images.count {
                    indexPaths.append(NSIndexPath(forItem: i+(self.images?.count)!-1, inSection: 0))
                }
                self.images! += images
                collectionView.insertItemsAtIndexPaths(indexPaths)
            }
        }
        
        // Look at Orta's talk about where to do this...should be in a different place
        // this should just create the cell, there is an Apple example that
        // shows more about it too.

        let image = self.images![indexPath.item]

        cell.imageView.alpha = 0.0
        cell.imageView.contentMode = .ScaleAspectFill
        if let url = image.imageURL() {
            cell.imageView.hnk_setImageFromURL(url, placeholder: nil, format: nil, failure: nil, success: { (image) -> () in
                cell.imageView.image = image
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    cell.imageView.alpha = 1.0
                })
            })
        }
        
        return cell
    }

}
