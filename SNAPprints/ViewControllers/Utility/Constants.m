//
//  Constants.m
//  Sandbox
//
//  Created by Etay Luz on 11/12/13.
//  Copyright (c) 2013 Etay Luz. All rights reserved.
//

#import "Constants.h"

@implementation Constants

+ (NSString *)retriveServerURL {

  NSString *urlForServer = [[NSString alloc] init];
  NSString *configuration =
      [[[NSBundle mainBundle] infoDictionary] objectForKey:@"Configuration"];
  NSString *trimmedConfig = [[configuration
      stringByTrimmingCharactersInSet:
          [NSCharacterSet whitespaceCharacterSet]] uppercaseString];

  if ([trimmedConfig isEqualToString:@"PRODUCTION"]) {
    urlForServer = kProductionServerURL;
  } else if ([trimmedConfig isEqualToString:@"LOCAL"]) {
    urlForServer = kLocalServerURL;
  } else if ([trimmedConfig isEqualToString:@"BENCHMARK"]) {
    urlForServer = kBenchmarkServerURL;
  }
  else if ([trimmedConfig isEqualToString:@"STAGING"]) {
      urlForServer = kStagingServerURL;
  }

  return urlForServer;
}

@end
