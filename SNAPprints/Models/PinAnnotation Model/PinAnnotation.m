//
//  PinAnnotation.m
//  SNAPprints
//
//  Created by Etay Luz on 10/20/13.
//  Copyright (c) 2013 Etay Luz. All rights reserved.
//

#import "PinAnnotation.h"

@implementation PinAnnotation

- (id)initWithCoordinates:(CLLocationCoordinate2D)location
                placeName:(NSString *)placeName
              description:(NSString *)description;
{
  self = [super init];

  if (self) {
    self.coordinate = location;
    _title = placeName;
    _subtitle = description;
  }

  return self;
}

- (NSString *)title {
  return _title;
}

- (NSString *)subtitle {
  return _subtitle;
}

- (void)setTitle:(NSString *)title {
  if (_title != title) {
    _title = title;
  }
}

- (void)setSubtitle:(NSString *)subtitle {
  if (_subtitle != subtitle) {
    _subtitle = subtitle;
  }
}

- (CLLocationCoordinate2D)coordinate {
  return _coordinate;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
  _coordinate = newCoordinate;
}

@end
