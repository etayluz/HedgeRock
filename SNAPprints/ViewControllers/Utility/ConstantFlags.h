//
//  ConstantFlags.h
//  SNAPprints
//
//  Created by Etay Luz on 03/07/14.
//  Copyright (c) 2014 Etay Luz. All rights reserved.
//

BOOL isFromEventsNearMe; // To check for Events Near me(isFromEventsNearMe=YES)
                         // or for My picture section(isFromEventsNearMe=NO)

BOOL isFromAddEvent;

BOOL isFromMyEvent; // To check for Events Near me

BOOL
isResetFromSearch; // To check advance searched data is reset from Search event.

BOOL isEditEvent; // YES when edit event button clicked by user on Events near
                  // me and My events section.

BOOL isFromMyPicture;

BOOL isFromLogin;

BOOL isSearched;

BOOL isFBUserRegistered;

#define KEUSAVEPHOTO = @"savephoto";
// Google Admob
//#define ADUNITID @"ca-app-pub-5019397802068108/1863192472" // clients account
//#define ADUNITID @"ca-app-pub-3532183069571473/4468672142" // my account
//(Ashish)
//#define ADUNITID                                                               \
  @"ca-app-pub-3292513430923039/5103405309" // Benchmark's
                                            // bits.qa9@gmail.com/Benchmark123
// account
#define ADLOCATION @"10001 US"
#define ADACCURACYINMETER @"40233.6"
#define ADBIRTHDAY @"1"
#define ADBIRTHMONTH @"12"
#define ADBIRTHYEAR @"1986"
#define CONSTANT_DISTANCE @"25"//@"100"
#define Photo_Limit @"100"

#define ACCEPTABLE_CHAR_USERNAME                                               \
  @"1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz._"

#define DATABASE_NAME @"SNAPprintsDatabase.sqlite"

#define NEW_DB_VERSION @"1"

#define DISCLIAMER_TEXT @"***SNAPprints allows you to remove any image taken prior to the end of the event. Simply review your image on the event page or the My Pictures section and click delete. The image will no longer be saved and permanently deleted from the creator's archives."
