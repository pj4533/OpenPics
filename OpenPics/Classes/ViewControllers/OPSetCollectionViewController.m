//
//  OPSetCollectionViewController.m
//  OpenPics
//
//  Created by PJ Gray on 6/22/14.
//  Copyright (c) 2014 Say Goodnight Software. All rights reserved.
//

#import "OPSetCollectionViewController.h"
#import "OPSetCollectionViewDataSource.h"
#import "OPNavigationControllerDelegate.h"

@interface OPSetCollectionViewController ()

@end

@implementation OPSetCollectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.setItem.title;
    
    self.navigationController.delegate = [OPNavigationControllerDelegate shared];

    OPSetCollectionViewDataSource* dataSource = (OPSetCollectionViewDataSource*) self.collectionView.dataSource;
    dataSource.setItem = self.setItem;
    dataSource.delegate = self;
    
    [self.collectionView reloadData];
    [self doInitialSearch];
}

- (void)viewDidDisappear:(BOOL)animated {
    OPSetCollectionViewDataSource* dataSource = (OPSetCollectionViewDataSource*) self.collectionView.dataSource;
    [dataSource removeCachedImageOperations];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
