//
//  Address.h
//  SNAPprints
//
//  Created by Etay Luz on 9/26/13.
//  Copyright (c) 2013 Etay Luz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Address : NSObject

@property(nonatomic, retain) NSString *address1;
@property(nonatomic, retain) NSString *address2;
@property(nonatomic, retain) NSString *city;
@property(nonatomic, retain) NSString *state;
@property(nonatomic, retain) NSString *zip;
@property CLLocationCoordinate2D coordinate;

@end
