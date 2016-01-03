//
//  ViewController.swift
//  OpenPics
//
//  Created by PJ Gray on 1/2/16.
//  Copyright © 2016 Say Goodnight Software. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let provider = PopularProvider()
        provider.getItemsWithQuery("", pageNumber: 0) { (items, canLoadMore, error) -> Void in
            if let itemsArray = items {
                let urlArray = itemsArray.valueForKey("url")
                print("URLs: \(urlArray)")
                
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

