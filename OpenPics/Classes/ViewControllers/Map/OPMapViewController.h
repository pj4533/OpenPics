//
//  OPMapViewController.h
//  OpenPics
//
//  Created by PJ Gray on 4/24/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OPAnnotationView.h"

@class OPProvider;
@interface OPMapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate,OPAnnotationDelegate,UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *internalMapView;
@property (strong, nonatomic) IBOutlet UIView *activityIndicatorView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) CLLocationManager* locationManager;
@property (strong, nonatomic) OPProvider* provider;
@property (strong, nonatomic) IBOutlet UISearchBar *mapSearchBar;
@property (strong, nonatomic) IBOutlet UIView *backBackgroundView;
@property (strong, nonatomic) IBOutlet UIView *searchBackgroundView;

- (IBAction)searchTapped:(id)sender;
- (IBAction)flipToGrid:(id)sender;

@end
