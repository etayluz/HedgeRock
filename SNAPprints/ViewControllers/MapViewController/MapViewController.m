//
//  MapViewController.m
//  SNAPprints
//
//  Created by Etay Luz on 2/12/14.
//  Copyright (c) 2014 Etay Luz. All rights reserved.
//

#import "MapViewController.h"
#import "PinAnnotation.h"
#import "MBProgressHUD.h"

@interface MapViewController () {
  MBProgressHUD *hud;
}
@end

@implementation MapViewController

@synthesize mapView = _mapView;

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

#pragma mark - LifeCycle

- (void)viewDidLoad {
  [super viewDidLoad];
  hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
  hud.labelText = @"Loading...";

  CLGeocoder *geocoder = [[CLGeocoder alloc] init];

  Address *address = self.event.address;
  NSString *addressString = [NSString
      stringWithFormat:@"%@ %@ %@, %@, %@", address.address1, address.address2,
                       address.city, address.state, address.zip];

  [geocoder geocodeAddressString:addressString
               completionHandler:^(NSArray *placemarks, NSError *error) {
                   if (!error) {
                     [hud hide:YES];
                     CLPlacemark *placemark = [placemarks objectAtIndex:0];
                     _mapView.centerCoordinate = placemark.location.coordinate;
                     PinAnnotation *annotation = [[PinAnnotation alloc]
                         initWithCoordinates:placemark.location.coordinate
                                   placeName:self.event.title
                                 description:@"Description"];
                     [_mapView addAnnotation:annotation];
                     [_mapView setRegion:MKCoordinateRegionMake(
                                             placemark.location.coordinate,
                                             MKCoordinateSpanMake(.01, .01))];
                   } else {
                     [hud hide:YES];
                     [hud removeFromSuperview];
                   }
               }];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - Action Events

- (IBAction)doneTapped:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)getDirections:(id)sender {
  MKPlacemark *place =
      [[MKPlacemark alloc] initWithCoordinate:self.event.address.coordinate
                            addressDictionary:nil];
  MKMapItem *destination = [[MKMapItem alloc] initWithPlacemark:place];
  destination.name = self.event.title;
  NSArray *items = [[NSArray alloc] initWithObjects:destination, nil];
  NSDictionary *options = [[NSDictionary alloc]
      initWithObjectsAndKeys:MKLaunchOptionsDirectionsModeDriving,
                             MKLaunchOptionsDirectionsModeKey, nil];
  [MKMapItem openMapsWithItems:items launchOptions:options];
}

#pragma mark - MKMapViewDelegate methods
- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id<MKAnnotation>)annotation {
  if ([annotation isKindOfClass:[MKUserLocation class]])
    return nil;

  static NSString *annotationIdentifier = @"AnnotationIdentifier";

  MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView
      dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];

  if (!pinView) {
    pinView =
        [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                        reuseIdentifier:annotationIdentifier];

    [pinView setPinColor:MKPinAnnotationColorRed];
    pinView.animatesDrop = NO;
    pinView.canShowCallout = NO;
  } else {
    pinView.annotation = annotation;
  }

  return pinView;
}

@end
