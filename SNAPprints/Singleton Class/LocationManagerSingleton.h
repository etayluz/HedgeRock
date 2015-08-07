//
//  LocationManagerSingleton.h
//  SNAPprints
//
//  Created by Etay Luz on 12/7/13.
//  Copyright (c) 2013 Etay Luz. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface LocationManagerSingleton : NSObject <CLLocationManagerDelegate>

@property(nonatomic, strong) CLLocationManager *locationManager;

+ (LocationManagerSingleton *)sharedSingleton;
+ (BOOL)locationServicesEnabled;
@end
