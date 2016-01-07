//
//  ViewController.swift
//  OpenPics
//
//  Created by PJ Gray on 1/2/16.
//  Copyright © 2016 Say Goodnight Software. All rights reserved.
//

import UIKit
import SKPhotoBrowser

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, SourceTableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var sourcesButton: UIBarButtonItem!
    
    let searchBar = UISearchBar(frame: CGRectMake(0.0,0.0,1024.0,44.0))
    
    let dataSource = ImageDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.titleView = self.searchBar
        self.searchBar.delegate = self;

        self.sourcesButton.title = "Source: \(CurrentSource.sourceShortName)"
        
        self.collectionView.dataSource = self.dataSource
        self.collectionView.delegate = self
        
        self.updateCurrentSourceData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        coordinator.animateAlongsideTransition({ (context) -> Void in
            self.collectionView.collectionViewLayout.invalidateLayout()
            }, completion: nil)
    }
    
    // MARK: Helpers
    
    func updateCurrentSourceData() {
        self.dataSource.images = []
        self.collectionView.reloadData()
        self.dataSource.loadImagesWithSource(CurrentSource, query: self.searchBar.text!) { () -> Void in
            self.collectionView.reloadData()
        }
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        let side = floor((collectionView.frame.size.width / 3) - (layout.minimumInteritemSpacing * (2/3)))
    
        return CGSizeMake(side, side)
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
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "sourcesTable" {
            if let destinationNavigationController = segue.destinationViewController as? UINavigationController {                
                if let sourceViewController = destinationNavigationController.topViewController as? SourceTableViewController {
                    sourceViewController.delegate = self
                }
            }
        }
    }

    // MARK: Sources Table View 
    func tappedSource(source: Source) {
        self.dismissViewControllerAnimated(true, completion: nil)
        CurrentSource = source
        self.sourcesButton.title = "Source: \(CurrentSource.sourceShortName)"
        self.updateCurrentSourceData()
    }
    
    // MARK: Search Bar Delegate
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            self.updateCurrentSourceData()
        }
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        self.updateCurrentSourceData()
    }
}

