//
//  AppDelegate.h
//  SNAPprints
//
//  Created by Etay Luz on 9/16/13.
//  Copyright (c) 2013 Etay Luz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"
#import "Categories.h"
#import "MFSideMenu.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate> {

  Reachability *internetReach;
  NSMutableArray *arrCategory;
}
@property(strong, nonatomic) UILabel *label;
@property(strong, nonatomic) UIWindow *window;
@property(assign, nonatomic) BOOL isInternetAvailable;
@property(strong, nonatomic)
    MFSideMenuContainerViewController *sideMenuContainerVC;
@property(strong, nonatomic)
    MFSideMenuContainerViewController *sideMenuContainerForLogin;
- (void)updateInterfaceWithReachability:(Reachability *)curReach;
- (BOOL)internetCheck;
- (void)reachabilityChanged:(NSNotification *)note;
- (void)openSession;
- (UIImage *)scaleAndRotateImage:(UIImage *)image;

@end
