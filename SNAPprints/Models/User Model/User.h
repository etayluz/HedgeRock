//
//  User.h
//  SNAPprints
//
//  Created by Etay Luz on 9/27/13.
//  Copyright (c) 2013 Etay Luz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property NSInteger userId;
@property(nonatomic, retain) NSString *username;
@property(nonatomic, retain) NSString *profileImage;
@property(nonatomic, retain) NSString *token;

+ (BOOL)isLoggedIn;

@end
