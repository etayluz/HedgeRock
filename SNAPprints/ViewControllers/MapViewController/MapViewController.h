//
//  MapViewController.h
//  SNAPprints
//
//  Created by Etay Luz on 2/12/14.
//  Copyright (c) 2014 Etay Luz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Event.h"

@interface MapViewController : UIViewController

@property(nonatomic, retain) IBOutlet MKMapView *mapView;
@property(nonatomic, retain) Event *event;

- (IBAction)doneTapped:(id)sender;
- (IBAction)getDirections:(id)sender;

@end
