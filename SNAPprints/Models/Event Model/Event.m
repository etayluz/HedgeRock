//
//  Event.m
//  SNAPprints
//
//  Created by Etay Luz on 9/26/13.
//  Copyright (c) 2013 Etay Luz. All rights reserved.
//

#import "Event.h"
#import "Photo.h"

@implementation Event

@synthesize eventId;
@synthesize address, company, eventUser;
@synthesize created, updated;
@synthesize eventEndDateTime, eventStartDateTime;
@synthesize price;
@synthesize title, description;
@synthesize photos;
@synthesize photoLimit;
@synthesize thumbnail, thumbnailImage;
@synthesize distance, category_Id, type;
@synthesize isPrivate, intInvite;

- (id)init {
  self = [super init];

  if (self) {
    photos = [[NSMutableArray alloc] init];
  }

  return self;
}

- (id)copyWithZone:(NSZone *)zone {
  id copy = [[[self class] alloc] init];

  if (copy) {
    // Copy NSObject subclasses
    [copy setCompany:company];
    [copy setAddress:address];
    [copy setEventUser:eventUser];
    // Set primitives
    [copy setEventId:eventId];
    [copy setCategory_Id:category_Id];
    [copy setEventStartDateTime:eventStartDateTime];
    [copy setEventEndDateTime:eventEndDateTime];
    [copy setPhotos:photos];
    [copy setDistance:distance];
    [copy setPhotoLimit:photoLimit];
    [copy setTitle:title];
    [copy setPrice:price];
    [copy setDescription:description];
    [copy setIsPrivate:isPrivate];
    [copy setIntInvite:intInvite];
    [copy setCreated:created];
    [copy setUpdated:updated];
    [copy setThumbnail:thumbnail];
    [copy setThumbnailImage:thumbnailImage];
    [copy setType:type];
  }

  return copy;
}
- (NSString *)getImageURL {

  NSString *urlString;
  if (![self.thumbnail isEqualToString:@""]) {
    urlString = [NSString stringWithFormat:@"%@uploads/events/%@",
                                           [Constants retriveServerURL],
                                           self.thumbnail];
    return urlString;
  } else if ([self.photos count] == 0) {
    return @"";
  } else {
    Photo *photo = [self.photos objectAtIndex:0];
    urlString = [NSString stringWithFormat:@"%@/uploads/photos/%@",
                                           [Constants retriveServerURL],
                                           photo.thumbnail_filename];
    return urlString;
  }
}

@end
