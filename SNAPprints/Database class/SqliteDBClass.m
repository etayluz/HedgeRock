//
//  SqliteDBClass.m
//  SNAPprints
//
//  Created by Etay Luz on 26/06/14.
//  Copyright (c) 2014 Etay Luz. All rights reserved.
//

#import "SqliteDBClass.h"

@implementation SqliteDBClass

- (BOOL)getDB {
  NSArray *arrayDest =
      [NSArray arrayWithObjects:NSHomeDirectory(), @"Documents",
                                @"SNAPprintsDatabase.sqlite", nil];
  destinationPath = [NSString pathWithComponents:arrayDest];

  NSFileManager *manager = [NSFileManager defaultManager];
  if (![manager fileExistsAtPath:destinationPath]) {
//    NSArray *arraySRC =
//        [NSArray arrayWithObjects:NSHomeDirectory(), @"SNAPprints.app",
//                                  @"SNAPprintsDatabase.sqlite", nil];
      
      NSArray *arraySRC =
      [NSArray arrayWithObjects:[[NSBundle mainBundle] resourcePath],
       @"SNAPprintsDatabase.sqlite", nil];
    NSString *SRC = [NSString pathWithComponents:arraySRC];
    NSError *error;
    if (![manager copyItemAtPath:SRC toPath:destinationPath error:&error]) {
      NSLog(@"error is %@", error);
      return NO;
    }
  }
  return YES;
}
- (void)insertCategoryList:(NSArray *)list {
  if ([self getDB]) {
    if (sqlite3_open([destinationPath UTF8String], &dbObject) == SQLITE_OK) {
      sqlite3_stmt *stmt = nil;
      sqlite3_exec(dbObject, "BEGIN EXCLUSIVE TRANSACTION", 0, 0, 0);
      for (NSString *category in list) {
        NSString *insertSQL = [NSString
            stringWithFormat:
                @"INSERT INTO Category_list( c_Name) values ('%@');", category];
        if (sqlite3_prepare_v2(dbObject, [insertSQL UTF8String], -1, &stmt,
                               NULL) == SQLITE_OK) {
          if (sqlite3_step(stmt) == SQLITE_DONE)
            NSLog(@"Record Inserted successfully.");
          if (sqlite3_reset(stmt) != SQLITE_OK)
            NSLog(@"SQL Error: %s", sqlite3_errmsg(dbObject));
        } else {
          NSLog(@"SQL Error: %s", sqlite3_errmsg(dbObject));
        }
      }
      if (sqlite3_finalize(stmt) != SQLITE_OK)
        NSLog(@"SQL Error: %s", sqlite3_errmsg(dbObject));

      if (sqlite3_exec(dbObject, "COMMIT TRANSACTION", 0, 0, 0) != SQLITE_OK)
        NSLog(@"SQL Error: %s", sqlite3_errmsg(dbObject));

      sqlite3_close(dbObject);
    }
  }
}

- (NSMutableArray *)selectCategory {
  NSMutableArray *arrMCategory = [[NSMutableArray alloc] init];
  if ([self getDB]) {
    if (sqlite3_open([destinationPath UTF8String], &dbObject) == SQLITE_OK) {
      sqlite3_stmt *stmt = nil;
      NSString *query = @"Select c_Name from Category_list";
      if (sqlite3_prepare(dbObject, [query UTF8String], -1, &stmt, NULL) ==
          SQLITE_OK) {
        while (sqlite3_step(stmt) == SQLITE_ROW) {
          char *cname = (char *)sqlite3_column_text(stmt, 0);
          NSString *strc_name = nil;
          if (cname == NULL)
            strc_name = @"";
          strc_name = [NSString stringWithUTF8String:cname];
          [arrMCategory addObject:strc_name];
        }
      }
    }
  }
  return arrMCategory;
}

- (void)insertForContacts:(NSArray *)arrContact {
  int i = 0;
  NSLog(@"Display array count : %lu", (unsigned long)[arrContact count]);
  if ([self getDB]) {
    sqlite3 *dataBase = NULL;
    sqlite3_stmt *statement = nil;
    if (sqlite3_open([destinationPath UTF8String], &dataBase) == SQLITE_OK) {
      sqlite3_exec(dataBase, "BEGIN EXCLUSIVE TRANSACTION", 0, 0, 0);
      for (ContactInformation *_user in arrContact) {
        NSInteger contact_id = _user.contactId.integerValue;
        NSString *insertSQL = [NSString
            stringWithFormat:@"INSERT INTO Contact_list(c_ContactId,c_fname, "
                             @"c_lname, c_username, c_phone, c_email, "
                             @"c_imageurl) values "
                             @"(%ld,'%@','%@','%@','%@','%@','%@');",
                             (long)contact_id, _user.firstName, _user.lastName,
                             _user.userName, _user.phoneNo, _user.emailAdd,
                             _user.imageUrlDocument];
        if (sqlite3_prepare_v2(dataBase, [insertSQL UTF8String], -1, &statement,
                               NULL) == SQLITE_OK) {
          NSLog(@"Contact %d", i++);
          if (sqlite3_step(statement) != SQLITE_DONE)
            NSLog(@"DB not updated. Error: %s", sqlite3_errmsg(dataBase));
          if (sqlite3_reset(statement) != SQLITE_OK)
            NSLog(@"SQL Error: %s", sqlite3_errmsg(dataBase));

        } else {
          NSLog(@"SQL Error: %s", sqlite3_errmsg(dataBase));
        }
      }
      if (sqlite3_finalize(statement) != SQLITE_OK)
        NSLog(@"SQL Error: %s", sqlite3_errmsg(dataBase));
      if (sqlite3_exec(dataBase, "COMMIT TRANSACTION", 0, 0, 0) != SQLITE_OK)
        NSLog(@"SQL Error: %s", sqlite3_errmsg(dataBase));
      sqlite3_close(dataBase);
    }
  }
}

- (void)deleteContacts {
  if ([self getDB]) {
    sqlite3_stmt *statement = nil;
    if (sqlite3_open([destinationPath UTF8String], &dbObject) == SQLITE_OK) {
      NSString *query = @"Delete from Contact_list";
      if (sqlite3_prepare(dbObject, [query UTF8String], -1, &statement, NULL) ==
          SQLITE_OK) {
        if (sqlite3_step(statement) == SQLITE_DONE) {
          NSLog(@"Delete data successfully");
        } else {
        }
        sqlite3_reset(statement);
      }
      sqlite3_finalize(statement);
      sqlite3_close(dbObject);
      statement = nil;
    }
  }
}

- (NSMutableArray *)getContact {

  NSMutableArray *arrMSMSList;

  if (!arrMSMSList) {

    arrMSMSList = [[NSMutableArray alloc] init];
  }
  if ([self getDB]) {
    if (sqlite3_open([destinationPath UTF8String], &dbObject) == SQLITE_OK) {

      char *selectQuery = "select * from Contact_list  WHERE  c_email NOT IN "
                          "('', 'null', '(null)')";

      sqlite3_stmt *selectStmnt = nil;

      if (sqlite3_prepare(dbObject, selectQuery, -1, &selectStmnt, NULL) ==
          SQLITE_OK) {

        while (sqlite3_step(selectStmnt) == SQLITE_ROW) {

          ContactInformation *user = [[ContactInformation alloc] init];

          int c_id = sqlite3_column_int(selectStmnt, 1);
          NSString *strc_id = [NSString stringWithFormat:@"%d", c_id];
          user.contactId = strc_id;

          char *fname = (char *)sqlite3_column_text(selectStmnt, 2);
          NSString *strc_fname = [NSString stringWithUTF8String:fname];
          user.firstName = strc_fname;

          char *lname = (char *)sqlite3_column_text(selectStmnt, 3);
          NSString *strc_lname = [NSString stringWithUTF8String:lname];
          user.lastName = strc_lname;

          char *name = (char *)sqlite3_column_text(selectStmnt, 4);
          NSString *strc_name = [NSString stringWithUTF8String:name];
          user.userName = strc_name;

          char *phone = (char *)sqlite3_column_text(selectStmnt, 5);
          NSString *strc_phone = [NSString stringWithUTF8String:phone];
          user.phoneNo = strc_phone;

          char *email = (char *)sqlite3_column_text(selectStmnt, 6);
          NSString *strc_email = [NSString stringWithUTF8String:email];
          user.emailAdd = strc_email;

          char *imageurl = (char *)sqlite3_column_text(selectStmnt, 7);
          NSString *strc_imageurl = [NSString stringWithUTF8String:imageurl];
          user.imageUrlDocument = strc_imageurl;
          [arrMSMSList addObject:user];
        }

        sqlite3_reset(selectStmnt);
      }
      sqlite3_finalize(selectStmnt);
      sqlite3_close(dbObject);
      selectStmnt = nil;
    }
  }
  return arrMSMSList;
}

- (void)insertEventCalendar:(NSDictionary*)dict
{
    if ([self getDB]) {
        if (sqlite3_open([destinationPath UTF8String], &dbObject) == SQLITE_OK) {
            sqlite3_stmt *stmt = nil;
            sqlite3_exec(dbObject, "BEGIN EXCLUSIVE TRANSACTION", 0, 0, 0);
            NSInteger event_Id = [[dict valueForKey:@"Event[id]"]integerValue];
            NSString *strEvent_Name = [dict valueForKey:@"Event[title]"];
                NSString *insertSQL = [NSString
                                       stringWithFormat:
                                       @"INSERT INTO Event_Calendar(E_Id,E_Name) values (%ld,\"%@\");",(long)event_Id,strEvent_Name];
                if (sqlite3_prepare_v2(dbObject, [insertSQL UTF8String], -1, &stmt,
                                       NULL) == SQLITE_OK) {
                    if (sqlite3_step(stmt) == SQLITE_DONE)
                        NSLog(@"Record Inserted successfully.");
                    if (sqlite3_reset(stmt) != SQLITE_OK)
                        NSLog(@"SQL Error: %s", sqlite3_errmsg(dbObject));
                }
                else {
                    NSLog(@"SQL Error: %s", sqlite3_errmsg(dbObject));
                }
            
            if (sqlite3_finalize(stmt) != SQLITE_OK)
                NSLog(@"SQL Error: %s", sqlite3_errmsg(dbObject));
            
            if (sqlite3_exec(dbObject, "COMMIT TRANSACTION", 0, 0, 0) != SQLITE_OK)
                NSLog(@"SQL Error: %s", sqlite3_errmsg(dbObject));
            
            sqlite3_close(dbObject);
        }
    }
}

- (NSMutableArray *)getEventsCalendar{
    NSMutableArray *arrMSMSList;
    
    if (!arrMSMSList) {
        
        arrMSMSList = [[NSMutableArray alloc] init];
    }
    if ([self getDB]) {
        if (sqlite3_open([destinationPath UTF8String], &dbObject) == SQLITE_OK) {
            
            char *selectQuery = "select * from Event_Calendar";
            
            sqlite3_stmt *selectStmnt = nil;
            
            if (sqlite3_prepare(dbObject, selectQuery, -1, &selectStmnt, NULL) ==
                SQLITE_OK) {
                
                while (sqlite3_step(selectStmnt) == SQLITE_ROW) {
                    
                    NSMutableDictionary *eventDict = [[NSMutableDictionary alloc] init];
                    
                    int e_id = sqlite3_column_int(selectStmnt, 0);
                    NSString *stre_id = [NSString stringWithFormat:@"%d", e_id];
                    [eventDict setObject:stre_id forKey:@"Event_ID"];
                    
                    char *event_Name = (char *)sqlite3_column_text(selectStmnt, 1);
                    NSString *strEname = [NSString stringWithUTF8String:event_Name];
                     [eventDict setObject:strEname forKey:@"Event_NAME"];
                    [arrMSMSList addObject:eventDict];
                }
                
                sqlite3_reset(selectStmnt);
            }
            sqlite3_finalize(selectStmnt);
            sqlite3_close(dbObject);
            selectStmnt = nil;
        }
    }
    return arrMSMSList;
}
@end
