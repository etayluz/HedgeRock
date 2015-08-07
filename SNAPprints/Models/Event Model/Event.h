//
//  Event.h
//  SNAPprints
//
//  Created by Etay Luz on 9/26/13.
//  Copyright (c) 2013 Etay Luz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Address.h"
#import "Company.h"
#import "User.h"

@interface Event : NSObject <NSCopying>

@property NSInteger eventId;
@property(nonatomic, retain) Address *address;
@property(nonatomic, retain) Company *company;

@property(nonatomic, retain) NSDate *created;
@property(nonatomic, retain) NSDate *updated;

@property(nonatomic, retain) NSDate *eventStartDateTime;
@property(nonatomic, retain) NSDate *eventEndDateTime;

@property(nonatomic, retain) NSNumber *price;

@property(nonatomic, retain) NSString *title;
@property(nonatomic, retain) NSString *description;
@property NSInteger intInvite;
@property(nonatomic, retain) NSString *thumbnail;
@property(nonatomic, retain, strong) UIImage *thumbnailImage;
@property float distance;

@property(nonatomic, retain) User *eventUser;

@property(nonatomic, retain) NSMutableArray *photos;
@property NSInteger photoLimit;
@property BOOL isPrivate;

@property(strong, nonatomic) NSString *type;

@property(strong, nonatomic) NSString *bannerUrl;

@property(strong, nonatomic) NSString *bannerImgName;

- (NSString *)getImageURL;

@property(strong, nonatomic) NSString *category_Id;

@end
