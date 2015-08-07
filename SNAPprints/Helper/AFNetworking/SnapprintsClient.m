//
//  SnapprintsClient.m
//  SNAPprints
//
//  Created by Etay Luz on 9/26/13.
//  Copyright (c) 2013 Etay Luz. All rights reserved.
//

#import "SnapprintsClient.h"
#import "AFNetworking.h"

@implementation SnapprintsClient

+ (SnapprintsClient *)sharedSnapprintsClient {
  NSString *urlStr; //= @"http://staging.snapprintshere.com";

  urlStr = [Constants retriveServerURL];
  NSLog(@"URL:%@", urlStr);
  static dispatch_once_t pred;
  static SnapprintsClient *_sharedSnapprintsClient = nil;

  dispatch_once(&pred, ^{
      _sharedSnapprintsClient =
          [[self alloc] initWithBaseURL:[NSURL URLWithString:urlStr]];
  });
  return _sharedSnapprintsClient;
}

- (id)initWithBaseURL:(NSURL *)url {
  self = [super initWithBaseURL:url];
  if (!self) {
    return nil;
  }

  [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
  [self setDefaultHeader:@"Accept" value:@"application/json"];

  return self;
}

@end
