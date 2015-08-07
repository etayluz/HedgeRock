//
//  User.m
//  SNAPprints
//
//  Created by Etay Luz on 9/27/13.
//  Copyright (c) 2013 Etay Luz. All rights reserved.
//

#import "User.h"
#import <FacebookSDK/FacebookSDK.h>

@implementation User

@synthesize userId, username, profileImage, token;

- (id)copyWithZone:(NSZone *)zone {
  id copy = [[[self class] alloc] init];

  if (copy) {
    // Set primitives
    [copy setUserId:userId];
    [copy setUsername:username];
    [copy setProfileImage:profileImage];
    [copy setToken:token];
  }

  return copy;
}

+ (BOOL)isLoggedIn {
  if ([FBSession.activeSession isOpen]) {
    return YES;
  }

  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

  if ([defaults objectForKey:@"user_id"]) {
    return YES;
  }

  return NO;
}

@end
