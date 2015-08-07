//
//  LocationManagerSingleton
//  SNAPprints
//
//  Created by Etay Luz on 12/7/13.
//  Copyright (c) 2013 Etay Luz. All rights reserved.
//

#import "LocationManagerSingleton.h"

@implementation LocationManagerSingleton

@synthesize locationManager;

- (id)init {
  self = [super init];

  if (self) {
    self.locationManager = [CLLocationManager new];
    [self.locationManager setDelegate:self];
    [self.locationManager setDistanceFilter:kCLDistanceFilterNone];
    [self.locationManager setHeadingFilter:kCLHeadingFilterNone];
      if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
          [self.locationManager requestWhenInUseAuthorization];
      }
    [self.locationManager startUpdatingLocation];
    // do any more customization to your location manager
  }

  return self;
}
+ (BOOL)locationServicesEnabled {
//    if (([CLLocationManager locationServicesEnabled]) &&
//        ([CLLocationManager authorizationStatus] ==
//         kCLAuthorizationStatusAuthorized)) {
//    return YES;
//  } else {
//    return NO;
//  }
    if ([CLLocationManager locationServicesEnabled]) {
        switch ([CLLocationManager authorizationStatus]) {
            case kCLAuthorizationStatusAuthorized:
                return YES;
                break;
            case kCLAuthorizationStatusAuthorizedWhenInUse:
                return YES;
                break;
            case kCLAuthorizationStatusDenied:
                return NO;
                break;
            case kCLAuthorizationStatusNotDetermined:
                return NO;
                break;
            default:
                return NO;
                break;
        }
    }
    return NO;
}
+ (LocationManagerSingleton *)sharedSingleton {
  static LocationManagerSingleton *sharedSingleton;
  if (!sharedSingleton) {
    @synchronized(sharedSingleton) {
      sharedSingleton = [LocationManagerSingleton new];
    }
  }

  return sharedSingleton;
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
  // handle your location updates here
}

- (void)locationManager:(CLLocationManager *)manager
       didUpdateHeading:(CLHeading *)newHeading {
  // handle your heading updates here- I would suggest only handling the nth
  // update, because they
  // come in fast and furious and it takes a lot of processing power to handle
  // all of them
}

@end
