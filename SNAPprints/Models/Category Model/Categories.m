//
//  Categories.m
//  SNAPprints
//
//  Created by Etay Luz on 30/06/14.
//  Copyright (c) 2014 Etay Luz. All rights reserved.
//

#import "Categories.h"

@implementation Categories

- (void)encodeWithCoder:(NSCoder *)encoder {
  NSNumber *ct_id = [NSNumber numberWithInteger:_cat_id];
  [encoder encodeObject:ct_id forKey:@"cat_id"];
  [encoder encodeObject:_cat_name forKey:@"cat_name"];
  [encoder encodeObject:_parent_id forKey:@"parent_id"];
  [encoder encodeObject:_created_date forKey:@"created_date"];
  [encoder encodeObject:_is_active forKey:@"is_active"];
}

- (id)initWithCoder:(NSCoder *)decoder {
  self = [super init];
  if (self != nil) {
    _cat_id = [[decoder decodeObjectForKey:@"cat_id"] integerValue];
    _cat_name = [decoder decodeObjectForKey:@"cat_name"];
    _parent_id = [decoder decodeObjectForKey:@"parent_id"];
    _created_date = [decoder decodeObjectForKey:@"created_date"];
    _is_active = [decoder decodeObjectForKey:@"is_active"];
  }
  return self;
}

@end
