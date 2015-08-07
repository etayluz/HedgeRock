//
//  AppDelegate.m
//  SNAPprints
//
//  Created by Etay Luz on 9/16/13.
//  Copyright (c) 2013 Etay Luz. All rights reserved.
//

#import "AppDelegate.h"
#import "FirstScreenViewController.h"
#import "EventListViewController.h"
#import "SideMenuGridViewController.h"
#import "LocationManagerSingleton.h"
#import <Crashlytics/Crashlytics.h>
#import "ConstantFlags.h"
#import <sqlite3.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [Crashlytics startWithAPIKey:@"0635eaca423a06f2190bd0a7f0ccb45e80ab65d3"];
    [self upgradeDatabaseIfNeeded];
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  // Override point for customization after application launch.
  FirstScreenViewController *firstVC = [[FirstScreenViewController alloc]
      initWithNibName:@"FirstScreenViewController"
               bundle:[NSBundle mainBundle]];

  UINavigationController *navBar =
      [[UINavigationController alloc] initWithRootViewController:firstVC];

  isFromEventsNearMe = YES;
  EventListViewController *eventVC = [[EventListViewController alloc]
      initWithNibName:@"EventListViewController"
               bundle:[NSBundle mainBundle]];
  NSInteger loggedUser_id = [[[NSUserDefaults standardUserDefaults]
      objectForKey:@"user_id"] integerValue];
  [eventVC getEventsForUser:loggedUser_id];

  firstVC.delegate = eventVC;

  UINavigationController *eventNav =
      [[UINavigationController alloc] initWithRootViewController:eventVC];
//  UIImageView *headerLogoView =
//      [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"new-logo"]];
//  [eventNav.navigationBar addSubview:headerLogoView];
//  headerLogoView.center = eventNav.navigationBar.center;
  SideMenuGridViewController *sideMenuVC = [[SideMenuGridViewController alloc]
      initWithNibName:@"SideMenuGridViewController"
               bundle:[NSBundle mainBundle]];
  NSArray *ver =
      [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];

  if ([[ver objectAtIndex:0] intValue] >= 7) {
    navBar.navigationBar.barTintColor = UIColorFromRGB(COLOR_LIGHT_BLUE);
    [navBar.navigationBar setTintColor:[UIColor whiteColor]];
    navBar.navigationBar.translucent = NO;

    eventNav.navigationBar.barTintColor = [UIColor whiteColor];
    [eventNav.navigationBar setTintColor:[UIColor blackColor]];
    eventNav.navigationBar.translucent = NO;
  } else {
    navBar.navigationBar.tintColor = [UIColor blackColor];
  }
  _sideMenuContainerVC = [MFSideMenuContainerViewController
      containerWithCenterViewController:eventNav
                 leftMenuViewController:sideMenuVC
                rightMenuViewController:nil];
  // Check to see if we have an open Facebook session

  if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
    // Yes, so just open the session (this won't display any UX).
      if(isFBUserRegistered)
          [self openSession];
  } else {
    // No, display the login page.
    [self showLoginView];
  }

  self.window.rootViewController = _sideMenuContainerVC;
  [self.window makeKeyAndVisible];

  if (![User isLoggedIn]) {
    [self.window.rootViewController presentViewController:navBar
                                                 animated:NO
                                               completion:^{}];
  }

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(dismissModal:)
                                               name:@"DismissModal"
                                             object:nil];

  [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];

  self.window.backgroundColor = [UIColor whiteColor];

  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(reachabilityChanged:)
             name:kReachabilityChangedNotification
           object:nil];

  internetReach = [Reachability reachabilityForInternetConnection];
  [internetReach startNotifier];
  [self updateInterfaceWithReachability:internetReach];

  arrCategory = [[NSMutableArray alloc] init];
  [self getCategories];
  return YES;
}

- (void)dismissModal:(id)sender {
  [self.window.rootViewController dismissViewControllerAnimated:YES
                                                     completion:^{}];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
  return [FBSession.activeSession handleOpenURL:url];

  return YES;
}

#pragma mark Facebook methods
- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState)state
                      error:(NSError *)error {

  switch (state) {
  case FBSessionStateOpen: {

    break;
  }
  case FBSessionStateClosed:
  case FBSessionStateClosedLoginFailed:

    break;
  default:
    break;
  }

  if (error) {
    UIAlertView *alertView =
        [[UIAlertView alloc] initWithTitle:@"Error"
                                   message:error.localizedDescription
                                  delegate:nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
    [alertView show];
  }
}
/**
 *  Open Session for Facebook
 */
- (void)openSession {
  [FBSession openActiveSessionWithReadPermissions:nil
                                     allowLoginUI:YES
                                completionHandler:^(FBSession *session,
                                                    FBSessionState state,
                                                    NSError *error) {
                                    [self sessionStateChanged:session
                                                        state:state
                                                        error:error];
                                }];
}

- (void)showLoginView {
}
#pragma mark -
#pragma mark Rechability method

/**
 * reachabilityChanged()
 * @desc Check the internet connection
 * @param NSNotification note is the notification of internet state changed
 */

- (void)reachabilityChanged:(NSNotification *)note {

  Reachability *curReach = [note object];
  NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
  [self updateInterfaceWithReachability:curReach];
}

/**
 * updateInterfaceWithReachability()
 * @desc Update the internet connection state
 * @param Reachability curReach is the instance of Reachbility
 */

- (void)updateInterfaceWithReachability:(Reachability *)curReach {

  if (curReach == internetReach) {

    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    BOOL connectionRequired = [curReach connectionRequired];
    NSString *statusString = @"";

    switch (netStatus) {

    case NotReachable: {

      statusString = @"Internet connection not available. Please check your "
          @"internet settings.";
      connectionRequired = NO;
      _isInternetAvailable = NO;
      [_label removeFromSuperview];
      break;
    }

    case ReachableViaWWAN: {

      statusString = @"Reachable WWAN";
      _isInternetAvailable = YES;
      connectionRequired = YES;
      [_label removeFromSuperview];
      break;
    }

    case ReachableViaWiFi: {

      statusString = @"Reachable WiFi";
      _isInternetAvailable = YES;
      connectionRequired = YES;
      [_label removeFromSuperview];
      break;
    }
    }

    if (!connectionRequired) {
      // statusString = [NSString stringWithFormat: @"%@, Connection Required",
      // statusString];

      if (IS_IPAD) {
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 994, 768, 30)];
        _label.font = [UIFont boldSystemFontOfSize:23];
      } else {
        //_label.font = [UIFont boldSystemFontOfSize:15];
        [_label setFont:[UIFont fontWithName:kAppSupportedFontLight size:12.0]];
        if (self.window.frame.size.height < 568) {

          _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 450, 320, 30)];
        } else {

          _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 538, 320, 30)];
        }
      }

      [_label setBackgroundColor:UIColorFromRGB(COLOR_LIGHT_BLUE)];
      _label.textColor = [UIColor whiteColor];
      _label.text = @"No Internet Connection";
      _label.textAlignment = NSTextAlignmentCenter;
      [self.window addSubview:_label];
      [_label superview];
      //            UIAlertView *alert=[[UIAlertView alloc]
      //            initWithTitle:NSLocalizedString(@"APP_NAME", nil)
      //            message:statusString delegate:nil cancelButtonTitle:nil
      //            otherButtonTitles:@"OK",nil];
      //            [alert show];
      NSLog(@"%@", statusString);
    }
  }
}

/**
 * internetCheck()
 * @desc store the internet connection state
 * @return BOOL internet is available or not
 */

- (BOOL)internetCheck {

  return _isInternetAvailable;
}

#pragma mark Application methods
- (void)applicationWillResignActive:(UIApplication *)application {
  // Sent when the application is about to move from active to inactive state.
  // This can occur for certain types of temporary interruptions (such as an
  // incoming phone call or SMS message) or when the user quits the application
  // and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down
  // OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  // Use this method to release shared resources, save user data, invalidate
  // timers, and store enough application state information to restore your
  // application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called
  // instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  // Called as part of the transition from the background to the inactive state;
  // here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  if ([User isLoggedIn]) {
    //[self.window.rootViewController dismissViewControllerAnimated:YES
    // completion:nil];
  }
}

- (void)applicationWillTerminate:(UIApplication *)application {
  // Called when the application is about to terminate. Save data if
  // appropriate. See also applicationDidEnterBackground:.
}

#pragma mark- API Call

- (void)getCategories {

  [[SnapprintsClient sharedSnapprintsClient] getPath:@"categories.json"
      parameters:[NSDictionary dictionaryWithObject:@"1" forKey:@"flag"]
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSArray *arr = [responseObject objectForKey:@"categories"];
          for (NSDictionary *category in arr) {
            NSMutableDictionary *catDict = [category objectForKey:@"Category"];
            Categories *cat_Info = [[Categories alloc] init];
            cat_Info.cat_id = [[catDict objectForKey:@"cat_id"] integerValue];
            cat_Info.cat_name = [catDict objectForKey:@"cat_name"];
            cat_Info.parent_id = [catDict objectForKey:@"parent_id"];
            cat_Info.created_date = [catDict objectForKey:@"created_date"];
            cat_Info.is_active = [catDict objectForKey:@"is_active"];
            [arrCategory addObject:cat_Info];
          }
          NSUserDefaults *objDefaults = [NSUserDefaults standardUserDefaults];
          id data = [NSKeyedArchiver archivedDataWithRootObject:arrCategory];
          [objDefaults setObject:data forKey:@"Categories"];
          [objDefaults synchronize];
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          NSLog(@"Error From Server :%@", error.description);
      }];
}

#pragma mark - Other Methods

-(void)upgradeDatabaseIfNeeded{
    
    NSArray  *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory  = [documentPaths objectAtIndex:0];
    
    NSString *dbPath = [documentsDirectory stringByAppendingPathComponent:DATABASE_NAME];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL dbSuccess = [fileManager fileExistsAtPath:dbPath];
    
    if (dbSuccess)
    {
        
        NSString *databaseVersion = [self queryUserVersion:dbPath];
        NSLog(@"%@",NEW_DB_VERSION);
        //if(![databaseVersion isEqualToString:NEW_DB_VERSION])
        if([databaseVersion caseInsensitiveCompare:NEW_DB_VERSION] == NSOrderedAscending)
        {
            NSLog(@"NEW_DB_VERSION is greater than the currentVersion");
            
            //Remove the old Database
            [fileManager removeItemAtPath:dbPath error:nil];
            
            // Remove all data from NSUSERDefault
            NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
            [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
        }
        else
        {
            NSLog(@"no code change needed");
        }
    }
}

-(NSString*)queryUserVersion: (NSString*) destinationPath {
    // get current database version of schema
    static sqlite3_stmt *stmt_version;
    int databaseVersion = 0;
    sqlite3 *db;
    if(sqlite3_open([destinationPath UTF8String], &db)==SQLITE_OK)
    {
        NSLog(@"&stmt_version : %@", stmt_version);
        if(sqlite3_prepare(db, "PRAGMA user_version;", -1, &stmt_version, NULL) == SQLITE_OK) {
            while(sqlite3_step(stmt_version) == SQLITE_ROW) {
                databaseVersion = sqlite3_column_int(stmt_version, 0);
                NSLog(@"%s: version %d", __FUNCTION__, databaseVersion);
            }
            NSLog(@"%s: the databaseVersion is: %d", __FUNCTION__, databaseVersion);
        }
        else {
            NSLog(@"%s: ERROR Preparing: , %s", __FUNCTION__, sqlite3_errmsg(db) );
        }
        sqlite3_finalize(stmt_version);
        
        sqlite3_close(db);
        //stmt_version = nil;
    }
    
    return [NSString stringWithFormat:@"%d",databaseVersion];
}

#pragma mark- Image Pick Rotation

- (UIImage *)scaleAndRotateImage:(UIImage *)image
{
    int kMaxResolution = 2000;
    
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = bounds.size.width / ratio;
        }else{
            bounds.size.height = kMaxResolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }else{
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}


@end
