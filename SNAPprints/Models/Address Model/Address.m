//
//  Address.m
//  SNAPprints
//
//  Created by Etay Luz on 9/26/13.
//  Copyright (c) 2013 Etay Luz. All rights reserved.
//

#import "Address.h"

@implementation Address

@synthesize address1, address2, city, state, zip;

- (id)copyWithZone:(NSZone *)zone {
  id copy = [[[self class] alloc] init];

  if (copy) {
    // Set primitives
    [copy setAddress1:address1];
    [copy setAddress2:address2];
    [copy setCity:city];
    [copy setState:state];
    [copy setZip:zip];
  }

  return copy;
}

@end
