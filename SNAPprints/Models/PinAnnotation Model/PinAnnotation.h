//
//  PinAnnotation.h
//  SNAPprints
//
//  Created by Etay Luz on 10/20/13.
//  Copyright (c) 2013 Etay Luz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface PinAnnotation : NSObject <MKAnnotation> {
  NSString *_title;
  NSString *_subtitle;

  CLLocationCoordinate2D _coordinate;
}

- (void)setTitle:(NSString *)title;
- (void)setSubtitle:(NSString *)subtitle;

- (id)initWithCoordinates:(CLLocationCoordinate2D)location
                placeName:(NSString *)placeName
              description:(NSString *)description;

@end
