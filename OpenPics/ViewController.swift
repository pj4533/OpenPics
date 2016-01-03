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
    
    let dataSource = ImageDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        self.collectionView.dataSource = self.dataSource
        
        let popularProvider = PopularProvider()
        self.dataSource.loadImagesWithProvider(popularProvider) { () -> Void in
            self.collectionView.reloadData()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

