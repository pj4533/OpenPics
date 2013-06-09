//
//  OPMapViewController.h
//  OpenPics
//
//  Created by PJ Gray on 4/24/13.
// 
// Copyright (c) 2013 Say Goodnight Software
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


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
