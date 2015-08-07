//
//  Photo.h
//  SNAPprints
//
//  Created by Etay Luz on 11/3/13.
//  Copyright (c) 2013 Etay Luz. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;

@interface Photo : NSObject

@property NSInteger photoID;
@property(nonatomic, retain) NSString *filename;
@property(nonatomic, retain) NSString *thumbnail_filename;
@property(nonatomic, retain) UIImage *photoImage;
@property(nonatomic, retain) UIImage *thumbnailImage;
@property(nonatomic, retain) NSString *caption;
@property(nonatomic, retain) User *user;
@property(nonatomic, retain) NSDate *created;
@property(nonatomic, retain) NSDate *updated;
@property(nonatomic, retain) NSString *published;
@property (nonatomic, retain) NSString *is_deleted;
@property int flagCount;

@end
