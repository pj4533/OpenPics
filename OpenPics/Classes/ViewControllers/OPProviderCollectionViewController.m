//
//  OPCollectionViewController.m
//  OpenPics
//
//  Created by PJ Gray on 3/22/14.
//  Copyright (c) 2014 Say Goodnight Software. All rights reserved.
//

#import "OPProviderCollectionViewController.h"
#import "OPProviderListViewController.h"
#import "OPImageCollectionViewController.h"
#import "SVProgressHUD.h"
#import "OPNavigationControllerDelegate.h"
#import "OPItem.h"
#import "OPContentCell.h"
#import "OPProviderController.h"
#import "OPProvider.h"
#import "OPCollectionViewDataSource.h"
#import "FRDLivelyButton.h"
#import "OPImageManager.h"
#import "OPPopularProvider.h"
#import "OPSetCollectionViewController.h"

@interface OPProviderCollectionViewController () <UINavigationControllerDelegate,OPProviderListDelegate,UISearchBarDelegate,UICollectionViewDelegateFlowLayout> {
    UISearchBar* _searchBar;
    UIBarButtonItem* _sourceButton;
    UIBarButtonItem* _sourceCaret;
    UIToolbar* _toolbar;
    UIPopoverController* _popover;
}

@end

@implementation OPProviderCollectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    OPCollectionViewDataSource* dataSource = (OPCollectionViewDataSource*) self.collectionView.dataSource;
    dataSource.delegate = self;

    [[OPProviderController shared] selectFirstProvider];
    OPProvider* selectedProvider = [[OPProviderController shared] getSelectedProvider];

    self.navigationController.delegate = [OPNavigationControllerDelegate shared];
        
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 1024.0f, 44.0f)];
    _searchBar.delegate = self;
    
    _sourceButton = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"Source: %@", selectedProvider.providerShortName]
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                    action:@selector(sourceTapped)];
    FRDLivelyButton *button = [[FRDLivelyButton alloc] initWithFrame:CGRectMake(0,0,36,28)];
    [button setStyle:kFRDLivelyButtonStyleCaretDown animated:NO];
    [button addTarget:self action:@selector(sourceTapped) forControlEvents:UIControlEventTouchUpInside];
    [button setOptions:@{ kFRDLivelyButtonLineWidth: @(1.0f),
                          kFRDLivelyButtonHighlightedColor: [UIColor colorWithRed:0.5 green:0.8 blue:1.0 alpha:1.0],
                          kFRDLivelyButtonColor: [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]
                          }];
    _sourceCaret = [[UIBarButtonItem alloc] initWithCustomView:button];

    self.navigationItem.titleView = _searchBar;
    
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        CGRect frame, remain;
        CGRectDivide(self.view.bounds, &frame, &remain, 44, CGRectMaxYEdge);
        _toolbar = [[UIToolbar alloc] initWithFrame:frame];
        [_toolbar setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
        [button setStyle:kFRDLivelyButtonStyleCaretUp animated:NO];
        _toolbar.items = @[
                          [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                          _sourceButton,
                          _sourceCaret,
                          [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]
                          ];
        [self.view addSubview:_toolbar];
    } else {
        self.navigationItem.rightBarButtonItems = @[_sourceCaret, _sourceButton];
    }
    
    [self doInitialSearch];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [self.view bringSubviewToFront:_toolbar];
}

#pragma mark - Loading Data Helper Functions

- (void) searchForQuery:(NSString*) searchQuery {
    OPCollectionViewDataSource* dataSource = (OPCollectionViewDataSource*) self.collectionView.dataSource;

    dataSource.currentQueryString = searchQuery;
    [dataSource clearData];
    [self.collectionView reloadData];
    
    [SVProgressHUD showWithStatus:@"Searching..." maskType:SVProgressHUDMaskTypeClear];
    [self getMoreItems];
}

#pragma mark - actions

- (void) sourceTapped {
    if (_popover) {
        [_popover dismissPopoverAnimated:YES];
    }
    
    UIStoryboard *storyboard = self.storyboard;
    OPProviderListViewController* providerListViewController =
    [storyboard instantiateViewControllerWithIdentifier:@"OPProviderListViewController"];
    providerListViewController.title = @"Choose Image Source";
    providerListViewController.delegate = self;
    
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:providerListViewController];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self presentViewController:navController animated:YES completion:nil];
    } else {
        _popover = [[UIPopoverController alloc] initWithContentViewController:navController];
        [_popover presentPopoverFromBarButtonItem:_sourceButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

#pragma mark - OPProviderListDelegate

- (void)tappedProvider:(OPProvider *)provider {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [_popover dismissPopoverAnimated:YES];
    }
    
    OPProvider* currentProvider = [[OPProviderController shared] getSelectedProvider];
    if (![provider.providerType isEqualToString:currentProvider.providerType]) {
        
        _sourceButton.title = [NSString stringWithFormat:@"Source: %@", provider.providerShortName];
        
        [[OPProviderController shared] selectProvider:provider];
        
        OPCollectionViewDataSource* dataSource = [[OPCollectionViewDataSource alloc] init];
        dataSource.delegate = self;
        self.collectionView.dataSource = dataSource;
        
        // if we have search bar text, it isn't empty and we aren't switching to popular,
        // continue to search with the same search string -- this is a usablity thing
        // for quickly finding similar images among several providers
        if (_searchBar.text &&
            ![_searchBar.text isEqualToString:@""] &&
            ![provider.providerType isEqualToString:OPProviderTypePopular]) {
            [self searchForQuery:_searchBar.text];
        } else {
            [self.collectionView reloadData];
            _searchBar.text = @"";
            [self doInitialSearch];
        }
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchText isEqualToString:@""]) {
        OPCollectionViewDataSource* dataSource = [[OPCollectionViewDataSource alloc] init];
        dataSource.delegate = self;
        self.collectionView.dataSource = dataSource;

        [self doInitialSearch];
    }
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
}

#pragma mark Notifications

- (void) keyboardDidHide:(id) note {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self searchForQuery:_searchBar.text];
}

#pragma mark - DERPIN

-(void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake ) {
        [self.view endEditing:YES];
        
        NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
        NSNumber* uprezMode = [currentDefaults objectForKey:@"uprezMode"];
        if (uprezMode && uprezMode.boolValue) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"BOOM!"
                                                            message:@"Exiting full uprez mode."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            [currentDefaults setObject:[NSNumber numberWithBool:NO] forKey:@"uprezMode"];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"BOOM!"
                                                            message:@"Entering full uprez mode."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            [currentDefaults setObject:[NSNumber numberWithBool:YES] forKey:@"uprezMode"];
        }
        [currentDefaults synchronize];
    }
}

@end
