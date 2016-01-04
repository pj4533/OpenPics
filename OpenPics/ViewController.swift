//
//  ViewController.swift
//  OpenPics
//
//  Created by PJ Gray on 1/2/16.
//  Copyright © 2016 Say Goodnight Software. All rights reserved.
//

import UIKit
import SKPhotoBrowser

class ViewController: UIViewController, UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    let dataSource = ImageDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        self.collectionView.dataSource = self.dataSource
        self.collectionView.delegate = self
        
        let popularProvider = PopularProvider()
        self.dataSource.loadImagesWithProvider(popularProvider) { () -> Void in
            self.collectionView.reloadData()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {        
        if let images = self.dataSource.images {
            let cell = collectionView.cellForItemAtIndexPath(indexPath) as! ImageCollectionViewCell
            let originImage = cell.imageView.image! // some image for baseImage
            let browser = SKPhotoBrowser(originImage: originImage, photos: images, animatedFromView: cell)
            browser.initializePageIndex(indexPath.row)
            self.presentViewController(browser, animated: true, completion: nil)
        }
    }
}

