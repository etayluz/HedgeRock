//
//  SqliteDBClass.h
//  SNAPprints
//
//  Created by Etay Luz on 26/06/14.
//  Copyright (c) 2014 Etay Luz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "ContactInformation.h"

@interface SqliteDBClass : NSObject {
  NSString *destinationPath;
  sqlite3 *dbObject;
}

- (BOOL)getDB;
- (void)insertCategoryList:(NSArray *)list;
- (NSMutableArray *)selectCategory;
- (void)insertForContacts:(NSArray *)arrContact;
- (NSMutableArray *)getContact;
- (void)deleteContacts;
- (void)insertEventCalendar:(NSDictionary*)dict;
- (NSMutableArray *)getEventsCalendar;
@end
