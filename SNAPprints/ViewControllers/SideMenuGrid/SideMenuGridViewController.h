//
//  SideMenuGridViewController.h
//  SNAPprints
//
//  Created by Etay Luz on 22/05/14.
//  Copyright (c) 2014 Etay Luz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "MFSideMenu.h"
#import <FacebookSDK/FacebookSDK.h>
#import "MenuItem.h"
#import "MFSideMenu.h"
//#import "FirstScreenViewController.h"
#import "EventListViewController.h"
#import "UIImageView+AFNetworking.h"
#import "AddEventViewController.h"
#import "ProfileViewController.h"
#import "UIImage+RoundedImage.h"
#import "Constants.h"
#import "MenuCell.h"
@interface SideMenuGridViewController
    : UIViewController <MFMailComposeViewControllerDelegate>

@property(nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property(nonatomic, weak) IBOutlet UIImageView *imgProfileView;
@property(nonatomic, weak) IBOutlet UILabel *lblName;
@property(nonatomic, weak) IBOutlet UILabel *lblUserName;
@property (strong, nonatomic) IBOutlet UILabel *lblNearbyEvents;
@property (strong, nonatomic) IBOutlet UILabel *lblAddEvent;
@property (strong, nonatomic) IBOutlet UILabel *lblMyPhotos;
@property (strong, nonatomic) IBOutlet UILabel *lblSendFeedback;
@property (strong, nonatomic) IBOutlet UILabel *lblMyProfile;
@property (strong, nonatomic) IBOutlet UILabel *lblMyEvents;
- (IBAction)btnActionMenuItems:(id)sender;
@end
