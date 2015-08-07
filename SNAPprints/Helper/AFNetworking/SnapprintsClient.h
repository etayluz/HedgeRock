//
//  SnapprintsClient.h
//  SNAPprints
//
//  Created by Etay Luz on 9/26/13.
//  Copyright (c) 2013 Etay Luz. All rights reserved.
//

#import "AFHTTPClient.h"

@interface SnapprintsClient : AFHTTPClient

+ (SnapprintsClient *)sharedSnapprintsClient;
- (id)initWithBaseURL:(NSURL *)url;

@end
