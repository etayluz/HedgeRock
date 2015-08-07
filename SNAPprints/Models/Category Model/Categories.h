//
//  Categories.h
//  SNAPprints
//
//  Created by Etay Luz on 30/06/14.
//  Copyright (c) 2014 Etay Luz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Categories : NSObject

@property NSInteger cat_id;

@property(strong, nonatomic) NSString *cat_name;

@property(strong, nonatomic) NSString *parent_id;

@property(strong, nonatomic) NSDate *created_date;

@property(strong, nonatomic) NSString *is_active;

//{"categories":[{"Category":{"cat_id":"1","cat_name":"AfterHour","parent_id":"0","created_date":"2014-06-26
//12:13:23","is_active":"1"}},
@end
