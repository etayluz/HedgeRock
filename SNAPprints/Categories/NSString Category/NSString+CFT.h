//
//  NSString+CFT.h
//  SNAPprints
//
//  Created by Etay Luz on 1/2/14.
//  Copyright (c) 2014 Etay Luz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (CFT)

- (NSString *)urlencode;
+ (NSDateFormatter*)stringDateFormatter;
+ (NSDate*)stringDateFromString:(NSString*)string;
+ (NSString*)stringDateFromDate:(NSDate*)date;
@end
