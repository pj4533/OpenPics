//
//  OPMapViewController.m
//  OpenPics
//
//  Created by PJ Gray on 4/24/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import "OPMapViewController.h"
#import "OPAnnotation.h"
#import <QuartzCore/QuartzCore.h>
#import "AFNetworking.h"
#import "OPProvider.h"
#import "OPImageItem.h"
#import "OPViewController.h"

@interface OPMapViewController () {
    BOOL _firstUpdate;
    NSTimer* _updateTimer;
    NSArray* _items;
    NSMutableDictionary* _pins;
    
    BOOL _centeringMap;
    BOOL _selectedAnnotation;
}

@end

@implementation OPMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _firstUpdate = YES;
        _centeringMap = NO;
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
        _pins = [NSMutableDictionary dictionary];
        
        [self.internalMapView removeAnnotations:self.internalMapView.annotations];
        
        NSMutableDictionary* annotations = [NSMutableDictionary dictionary];
        
        for (NSInteger i=0; i < [items count]; i++) {
            OPImageItem* thisItem = items[i];
            OPAnnotation* newAnno = [[OPAnnotation alloc] initWithCoordinates:thisItem.location];
            newAnno.subtitle = [NSString stringWithFormat:@"%f,%f", thisItem.location.latitude,thisItem.location.longitude];
            newAnno.item = thisItem;
            NSValue* locationValue = [NSValue valueWithMKCoordinate:thisItem.location];
            if (_pins[locationValue]) {
                NSArray* itemsHereAlready = _pins[locationValue];
                _pins[locationValue] = [itemsHereAlready arrayByAddingObject:thisItem];
                newAnno.title = [NSString stringWithFormat:@"%d Photos Here", itemsHereAlready.count+1];
                annotations[locationValue] = newAnno;
            } else {
                _pins[locationValue] = @[thisItem];
                newAnno.title = [NSString stringWithFormat:@"1 Photo Here"];
                annotations[locationValue] = newAnno;
            }
        }
        [self.internalMapView addAnnotations:annotations.allValues];
    }];
    [self.activityIndicator startAnimating];
    [UIView animateWithDuration:0.5 animations:^{
        self.activityIndicatorView.alpha = 1.0;
    }];
}

#pragma mark - Actions

- (void) cancelTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)flipToGrid:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
        
        OPAnnotationView *annView = (OPAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"openpics"];
        if( annView == nil ){
            annView = [[OPAnnotationView alloc] initWithAnnotation:opAnnotation reuseIdentifier:@"openpics"];
            annView.delegate = self;
        }
        
        return annView;
    }
    
    return nil;
        
}

- (void) mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    // This smellyness has to do with when an annotation is near the edge of the map.  If you select it,
    // before showing the callout, it moves the map slightly.   For some reason if you CENTER the map while
    // this is happening, it flips the annotation to a 'selected' state, but doesn't show the callout. Hack
    // around it by putting in a delay before centering.  Details here:
    //          http://stackoverflow.com/questions/10047596/showing-callout-after-moving-mapview
    //
    // All ears for a better workaround.
    
    _selectedAnnotation = YES;
    dispatch_time_t dt = dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC);
    dispatch_after(dt, dispatch_get_main_queue(), ^(void)
    {
        [mapView setCenterCoordinate:view.annotation.coordinate animated:YES];
        _centeringMap = YES;
        _selectedAnnotation = NO;
    });
}

- (void) mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    if (_centeringMap || _selectedAnnotation) {
        _centeringMap = NO;
        return;
    }

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

#pragma mark - OPAnnotationDelegate

- (void) annotationButtonTapped:(OPAnnotation *)annotation {
    NSValue* locationValue = [NSValue valueWithMKCoordinate:annotation.item.location];
    OPViewController* viewController = [[OPViewController alloc] initWithNibName:@"OPViewController" bundle:nil];
    viewController.items = _pins[locationValue];
    viewController.flowLayout.itemSize = CGSizeMake(100.0f, 100.0f);
    viewController.flowLayout.headerReferenceSize = CGSizeMake(0.0f, 0.0f);
    viewController.singleImageLayout.headerReferenceSize = CGSizeMake(0.0f, 0.0f);
    viewController.currentProvider = self.provider;
    viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelTapped)];
    
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navController animated:YES completion:nil];
}

@end
