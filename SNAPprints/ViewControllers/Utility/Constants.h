//
//  Constants.h
//  Sandbox
//
//  Created by Etay Luz on 11/12/13.
//  Copyright (c) 2013 Etay Luz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constants : NSObject
#define isiPhone5 ([[UIScreen mainScreen] bounds].size.height == 568) ? YES : NO
#define IS_IPAD                                                                \
  ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#define kStagingServerURL @"http://staging.snapprintshere.com/"
//#define kBenchmarkServerURL @"http://snapprints.benchmarkitsolution.com/"
//#define kProductionServerURL @"https://snapprintshere.com/"

//#define kProductionServerURL                                                   \
//  @"https://www.snapprintshere.com/" // LIVE ITunes server
#define kBenchmarkServerURL                                                    \
  @"http://71.43.59.189:10028/" // Benchmark Demo OR QA Release OR Client
                                // Release
#define kProductionServerURL                                                       \
@"http://api.snapprintshere.com/"  //Live URL
//
//#define kLocalServerURL @"http://192.168.1.242:10020/" // For Developers
//#define kLocalServerURL @"http://192.168.1.144/snapprints/"
//#define kLocalServerURL @"http://192.168.1.242:9005/snapprints/"
#define kLocalServerURL @"http://117.239.190.50:10020/"

#define APPNAME @"SNAPprints"/

+ (NSString *)retriveServerURL;



@end
