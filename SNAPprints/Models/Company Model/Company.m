//
//  Company.m
//  SNAPprints
//
//  Created by Etay Luz on 9/26/13.
//  Copyright (c) 2013 Etay Luz. All rights reserved.
//

#import "Company.h"

@implementation Company

@synthesize name, companyId;

- (id)copyWithZone:(NSZone *)zone {
  id copy = [[[self class] alloc] init];

  if (copy) {
    // Set primitives
    [copy setName:name];
    [copy setCompanyId:companyId];
  }
  return copy;
}
@end
