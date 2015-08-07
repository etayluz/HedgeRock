//
//  EventsMapViewController.m
//  SNAPprints
//
//  Created by Etay Luz on 07/04/15.

//

#import "EventsMapViewController.h"
#import "Event.h"
#import "PinAnnotation.h"
#import "MBProgressHUD.h"
#import "EventDetailVC.h"

@interface EventsMapViewController (){
    CLGeocoder *geocoder;
    MBProgressHUD *hud;
}

@end

@implementation EventsMapViewController

@synthesize eventsArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.delegate = self;
    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    hud = [[MBProgressHUD alloc]initWithWindow:appDel.window];
    hud.labelText = @"Loading...";
    [hud show:YES];
    [hud setMode:MBProgressHUDModeIndeterminate];

//    [self plotPins:eventsArray];
}

-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    NSMutableArray * annotationsToRemove = [ _mapView.annotations mutableCopy ] ;
    if([annotationsToRemove count] >0)
    {
        [annotationsToRemove removeObject:_mapView.userLocation ] ;
        [_mapView removeAnnotations:annotationsToRemove];
    }
    _arrAnnotation = [[NSMutableArray alloc] init];
    [self plotPins:eventsArray];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSArray *selectedAnnotations = _mapView.selectedAnnotations;
    for(id annotation in selectedAnnotations) {
        [_mapView deselectAnnotation:annotation animated:NO];
    }
    _arrAnnotation = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom methods

-(void) getAddessDetails{
    for (Event *event in eventsArray) {
        geocoder = [[CLGeocoder alloc] init];
        Address *address = event.address;
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
                                                          placeName:event.title
                                                          description:@"Description"];
//                             [_mapView addAnnotation:annotation];
                             
                             [_mapView setRegion:MKCoordinateRegionMake(
                                                                        placemark.location.coordinate,
                                                                        MKCoordinateSpanMake(.01, .01))];
                         } else {
                             [hud hide:YES];
                             [hud removeFromSuperview];
                         }
                     }];
    }
}

-(void)plotPins:(NSArray*)arr
{
    CLLocationCoordinate2D myLocation;
    for(Event *event in arr)
    {
        Address *address = event.address;
        NSString *addressString = [NSString
                                   stringWithFormat:@"%@ %@ %@, %@, %@", address.address1, address.address2,
                                   address.city, address.state, address.zip];
        
        NSString *esc_addr = [addressString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
        
        NSString *req = [NSString stringWithFormat: @"http://maps.google.com/maps/api/geocode/json?sensor=false&address=%@", esc_addr];
        
        //        NSDictionary *googleResponse = [NSString stringWithContentsOfURL: [NSURL URLWithString: req] encoding: NSUTF8StringEncoding error: NULL];
        NSError *error = nil;
        NSData *jsonData = [NSData dataWithContentsOfURL:[NSURL URLWithString:req]];
        NSDictionary *googleResponse = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                       options:NSJSONReadingMutableContainers
                                                                         error:&error];
        
        
        NSDictionary *resultsDict = [googleResponse valueForKey:  @"results"];
        NSDictionary *geometryDict = [resultsDict valueForKey: @"geometry"];
        NSDictionary *locationDict = [geometryDict valueForKey: @"location"];
        NSArray *latArray = [locationDict valueForKey: @"lat"];
        NSString *latString = [latArray lastObject];
        NSArray *lngArray = [locationDict valueForKey: @"lng"];
        NSString *lngString = [lngArray lastObject];
        
        myLocation.latitude = [latString doubleValue];
        myLocation.longitude = [lngString doubleValue];
        
        NSLog(@"lat: %f\tlon:%f", myLocation.latitude, myLocation.longitude);
        
        NSString *strAddress = [NSString stringWithFormat:@"%@, %@",event.address.city, event.address.zip];
        
        PinAnnotation *annotation = [[PinAnnotation alloc]
                                     initWithCoordinates:myLocation
                                     placeName:event.title
                                     description:strAddress];
        if(annotation)
            [_arrAnnotation addObject:annotation];
    }
    [self addMapAnnotationToMapView:_arrAnnotation];
}
#pragma mark - MKMapView Delegate

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    MKPinAnnotationView *newAnnotation = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pinLocation"];
    
    newAnnotation.canShowCallout = YES;
    UIButton *btnDisclosure = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    newAnnotation.rightCalloutAccessoryView = btnDisclosure;
    [hud hide:YES];
    return newAnnotation;
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    EventDetailVC *eventVC = [[EventDetailVC alloc] initWithNibName:@"EventDetailVC" bundle:[NSBundle mainBundle]];
    PinAnnotation *annotation1 = view.annotation;
    for (Event *event in eventsArray) {
        if ([event.title isEqualToString:annotation1.title]) {
            eventVC.event = event;
            break;
        }
    }
    [_superNavController pushViewController:eventVC animated:YES];
}
- (MKMapRect) getMapRectUsingAnnotations:(NSArray*)theAnnotations {
    MKMapPoint points[[theAnnotations count]];
    
    for (int i = 0; i < [theAnnotations count]; i++) {
        PinAnnotation *annotation = [theAnnotations objectAtIndex:i];
        points[i] = MKMapPointForCoordinate(annotation.coordinate);
    }
    
    MKPolygon *poly = [MKPolygon polygonWithPoints:points count:[theAnnotations count]];
    
    return [poly boundingMapRect];
}

/* this adds the provided annotation to the mapview object, zooming
 as appropriate */
- (void) addMapAnnotationToMapView:(NSArray*)arrAnnotation {
    if ([_arrAnnotation count] == 1) {
        // If there is only one annotation then zoom into it.
        PinAnnotation *annotation = [arrAnnotation objectAtIndex:0];
        [self zoomToAnnotation:annotation];
    } else {
        // If there are several, then the default behaviour is to show all of them
        //
        MKCoordinateRegion region = MKCoordinateRegionForMapRect([self getMapRectUsingAnnotations:_arrAnnotation]);
        
        if (region.span.latitudeDelta < 0.1) {  //0.027
            region.span.latitudeDelta = 0.1;
        }
        
        if (region.span.longitudeDelta < 0.1) { //0.027
            region.span.longitudeDelta = 0.1;
        }
//        [_mapView setRegion:region];
        if(region.center.longitude == -180.00000000 || region.center.latitude == -180.00000000){
            NSLog(@"Invalid region!");
            [TSMessage
             setDefaultViewController:_superNavController];
            [TSMessage
             showNotificationWithTitle:@"Error"
             subtitle:@"Invalid region!"
             type:
             TSMessageNotificationTypeError];
        }else{
            [_mapView setRegion:region animated:YES];
        }
    }
    
    [_mapView addAnnotations:arrAnnotation];
    //    [_mapView selectAnnotation:annotation animated:YES];
}

/* this simply adds a single pin and zooms in on it nicely */
- (void) zoomToAnnotation:(PinAnnotation*)annotation {
    MKCoordinateSpan span = {0.027, 0.027};
    MKCoordinateRegion region = {[annotation coordinate], span};
    [_mapView setRegion:region animated:YES];
}
@end
