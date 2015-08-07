//
//  EventsMapViewController.h
//  SNAPprints
//
//  Created by Etay Luz on 07/04/15.

//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "AppDelegate.h"
#import "TSMessage.h"

@interface EventsMapViewController : UIViewController <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSArray *eventsArray;
@property (strong, nonatomic) NSMutableArray *arrAnnotation;
@property (nonatomic, retain) UINavigationController *superNavController;

//-(void) showEventDetails;

@end
