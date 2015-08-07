//
//  Region.h
//  SNAPprints
//
//  Created by Etay Luz on 1/2/14.
//  Copyright (c) 2014 Etay Luz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Region : NSObject

@property(nonatomic, retain) NSString *countryName;
@property(nonatomic, retain) NSString *countryCode;
@property(nonatomic, retain) NSString *stateCode;
@property(nonatomic, retain) NSString *stateName;
@property(nonatomic, retain) NSString *cityName;
@property CLLocationCoordinate2D coordinate;

@end
