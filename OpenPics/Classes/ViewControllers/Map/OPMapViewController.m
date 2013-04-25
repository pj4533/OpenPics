//
//  OPMapViewController.m
//  OpenPics
//
//  Created by PJ Gray on 4/24/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import "OPMapViewController.h"
#import "OPAnnotationView.h"
#import "OPAnnotation.h"
#import <QuartzCore/QuartzCore.h>
#import "AFNetworking.h"
#import "OPProvider.h"
#import "OPImageItem.h"
#import "OPImageViewController.h"

@interface OPMapViewController () {
    BOOL _firstUpdate;
    NSTimer* _updateTimer;
    NSArray* _items;
}

@end

@implementation OPMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _firstUpdate = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.activityIndicatorView.alpha = 0.0;
    self.activityIndicatorView.layer.cornerRadius = 5.0f;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    [self.locationManager startUpdatingLocation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) zoomToUserLocation {
    MKCoordinateRegion zoomRegion;
    zoomRegion.center = self.locationManager.location.coordinate;
    zoomRegion.span.latitudeDelta = 0.05f;
    zoomRegion.span.longitudeDelta = 0.05f;
    
    [self.internalMapView setRegion:zoomRegion animated:YES];
}


- (void) updateMapFromAPI {
    
    MKCoordinateRegion region = self.internalMapView.region;

    [_provider getItemsWithRegion:region completion:^(NSArray *items) {
        [UIView animateWithDuration:0.5 animations:^{
            self.activityIndicatorView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self.activityIndicator stopAnimating];
        }];
        
        NSLog(@"%d ITEMS", items.count);
        
        _items = items;
        
        [self.internalMapView removeAnnotations:self.internalMapView.annotations];
        
        NSMutableArray* mapAnnotations = [[NSMutableArray alloc] init];
        
        for (NSInteger i=0; i < [items count]; i++) {
            OPImageItem* thisItem = items[i];
            OPAnnotation* newAnno = [[OPAnnotation alloc] initWithCoordinates:thisItem.location];
            newAnno.imageUrl = thisItem.imageUrl;
            newAnno.index = i;
            [mapAnnotations addObject:newAnno];
        }
        
        [self.internalMapView addAnnotations:mapAnnotations];
    }];
    [self.activityIndicator startAnimating];
    [UIView animateWithDuration:0.5 animations:^{
        self.activityIndicatorView.alpha = 1.0;
    }];
}

#pragma mark - Actions

- (IBAction)flipToGrid:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction) gotoImage:(id)sender {
	int index = ((UIButton *)sender).tag;
    if (index < [_items count]) {
        OPImageViewController* imageViewController = [[OPImageViewController alloc] initWithNibName:@"OPImageViewController" bundle:nil];
        imageViewController.item = _items[index];
        imageViewController.provider = self.provider;
        imageViewController.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:imageViewController animated:YES completion:nil];
    }
}

- (void) updateMap {
    [self updateMapFromAPI];
    _firstUpdate = NO;
}

#pragma mark - CLLocationDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
	if (oldLocation == nil) {
        [self zoomToUserLocation];
	}
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {

    if (![mapView.userLocation isEqual:annotation]) {
        OPAnnotation* opAnnotation = (OPAnnotation*) annotation;
        
        MKAnnotationView *annView = (MKAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"openpics"];
        if( annView == nil ){
            annView = [[OPAnnotationView alloc] initWithAnnotation:opAnnotation reuseIdentifier:@"openpics"];
        }
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
        annView.leftCalloutAccessoryView = imageView;
        [imageView setImageWithURL:opAnnotation.imageUrl];
        annView.canShowCallout = YES;
        [annView setEnabled:YES];
        
        UIButton *annoButton =[UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        annoButton.tag = opAnnotation.index;
        [annoButton addTarget:self action:@selector(gotoImage:) forControlEvents:UIControlEventTouchUpInside];
        annView.rightCalloutAccessoryView = annoButton;
        
        return annView;
    }
    
    return nil;
        
}

- (void) mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    if (_firstUpdate) {
        if (_updateTimer)
            [_updateTimer invalidate];
        
        _updateTimer = [NSTimer scheduledTimerWithTimeInterval:2.0
                                                        target:self
                                                      selector:@selector(updateMap)
                                                      userInfo:nil
                                                       repeats:NO];
    } else {
        
        [self updateMapFromAPI];
    }
}

@end
