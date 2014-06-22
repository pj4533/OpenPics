//
//  OPSetCollectionViewController.m
//  OpenPics
//
//  Created by PJ Gray on 6/22/14.
//  Copyright (c) 2014 Say Goodnight Software. All rights reserved.
//

#import "OPSetCollectionViewController.h"
#import "OPSetCollectionViewDataSource.h"

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

// REFACTOR SHARED CODE FROM PROVIDER/SET COLLECTION VIEW CONTROLLER TO BASE CLASS
//
// Should be all the code needed to show images, the segue stuff, the delegates etc.
- (void)viewDidLoad
{
    [super viewDidLoad];
    OPSetCollectionViewDataSource* dataSource = [[OPSetCollectionViewDataSource alloc] init];
    dataSource.setItem = self.setItem;
//    dataSource.delegate = self;
    self.collectionView.dataSource = dataSource;
    
    // if we have search bar text, it isn't empty and we aren't switching to popular,
    // continue to search with the same search string -- this is a usablity thing
    // for quickly finding similar images among several providers
//    [self.collectionView reloadData];
//    [self doInitialSearch];
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
