//
//  SideMenuGridViewController.m
//  SNAPprints
//
//  Created by Etay Luz on 22/05/14.
//  Copyright (c) 2014 Etay Luz. All rights reserved.
//

#import "SideMenuGridViewController.h"
#import "InviteVC.h"
#import "ConstantFlags.h"
#import "PAImageView.h"
#import "MyPhotosVC.h"

@interface SideMenuGridViewController () {
  CGRect userNameFrame;
  PAImageView *avatarView;
}
@property(weak, nonatomic) IBOutlet UIButton *btnProfile;
- (IBAction)btnProfileClicked:(id)sender;
- (IBAction)btnInviteClicked:(id)sender;
@end

@implementation SideMenuGridViewController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

#pragma mark - LifeCycle

- (void)viewDidLoad {
  [super viewDidLoad];

  // Do any additional setup after loading the view from its nib.
  userNameFrame = _lblUserName.frame;
  [self layoutTableHeader];
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(menuEvent:)
             name:MFSideMenuStateNotificationEvent
           object:nil];
    [_lblNearbyEvents setFont:[UIFont fontWithName:kAppSupportedFontNormal size:10.0f]];
    [_lblAddEvent setFont:[UIFont fontWithName:kAppSupportedFontNormal size:10.0f]];
    [_lblMyPhotos setFont:[UIFont fontWithName:kAppSupportedFontNormal size:10.0f]];
    [_lblSendFeedback setFont:[UIFont fontWithName:kAppSupportedFontNormal size:10.0f]];
    [_lblMyProfile setFont:[UIFont fontWithName:kAppSupportedFontNormal size:10.0f]];
    [_lblMyEvents setFont:[UIFont fontWithName:kAppSupportedFontNormal size:10.0f]];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - Action Events

- (IBAction)btnActionMenuItems:(id)sender {

  UIButton *btn = (UIButton *)sender;

  switch (btn.tag) {
  case 0: // Events Near Me
  {
    isFromEventsNearMe = YES;
    isFromMyEvent = NO;
    isFromMyPicture = NO;
    EventListViewController *eventVC = [[EventListViewController alloc]
        initWithNibName:@"EventListViewController"
                 bundle:[NSBundle mainBundle]];
    NSInteger user_id = [[[NSUserDefaults standardUserDefaults]
        objectForKey:@"user_id"] integerValue];
    [eventVC getEventsForUser:user_id];

    UINavigationController *eventNav =
        [[UINavigationController alloc] initWithRootViewController:eventVC];

//    UIImageView *headerLogoView =
//        [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"new-logo"]];
//    [eventNav.navigationBar addSubview:headerLogoView];
//    headerLogoView.center = eventNav.navigationBar.center;

    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
      eventNav.navigationBar.barTintColor = [UIColor whiteColor];
      [eventNav.navigationBar setTintColor:[UIColor blackColor]];
      eventNav.navigationBar.translucent = NO;
    } else {
      eventNav.navigationBar.tintColor = [UIColor blackColor];
      //        eventNav.navigationBar.tintColor = [UIColor blackColor];
    }

    self.menuContainerViewController.centerViewController = eventNav;
    [self.menuContainerViewController toggleLeftSideMenuCompletion:nil];
  } break;
  case 1: // Add new Event
  {
    isFromEventsNearMe = NO;
    isFromMyEvent = NO;
    isEditEvent = NO;
    AddEventViewController *eventVC = [[AddEventViewController alloc]
        initWithNibName:@"AddEventViewController"
                 bundle:[NSBundle mainBundle]];

    UINavigationController *eventNav =
        [[UINavigationController alloc] initWithRootViewController:eventVC];
//    UIImageView *headerLogoView =
//        [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"new-logo"]];
//    [eventNav.navigationBar addSubview:headerLogoView];
//    headerLogoView.center = eventNav.navigationBar.center;

    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
      eventNav.navigationBar.barTintColor = [UIColor whiteColor];
      [eventNav.navigationBar setTintColor:[UIColor blackColor]];
      eventNav.navigationBar.translucent = NO;
    } else {
      eventNav.navigationBar.tintColor = [UIColor blackColor];
      //        eventNav.navigationBar.tintColor = [UIColor blackColor];
    }

    self.menuContainerViewController.centerViewController = eventNav;
    [self.menuContainerViewController toggleLeftSideMenuCompletion:nil];

  } break;
  case 2: // My Photos
  {
      MyPhotosVC *myPhotosVC = [[MyPhotosVC alloc] initWithNibName:@"MyPhotosVC" bundle:[NSBundle mainBundle]];
      UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:myPhotosVC];
      
      if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
          nav.navigationBar.barTintColor = [UIColor whiteColor];
          [nav.navigationBar setTintColor:[UIColor blackColor]];
          nav.navigationBar.translucent = NO;
      } else {
          nav.navigationBar.tintColor = [UIColor blackColor];
          //        eventNav.navigationBar.tintColor = [UIColor blackColor];
      }
      
      self.menuContainerViewController.centerViewController = nav;
      [self.menuContainerViewController toggleLeftSideMenuCompletion:nil];
  } break;
  case 3: // Send Feedback
  {
    if ([MFMailComposeViewController canSendMail]) {
      MFMailComposeViewController *mailVC =
          [[MFMailComposeViewController alloc] init];
      mailVC.mailComposeDelegate = self;
      [mailVC setToRecipients:@[ @"info@snapprintshere.com" ]];
      [mailVC setSubject:@"SNAPprints Feedback"];

      [self.menuContainerViewController presentViewController:mailVC
                                                     animated:YES
                                                   completion:nil];
    } else {
      UIAlertView *alert =
          [[UIAlertView alloc] initWithTitle:@"SNAPprints"
                                     message:@"Please add mail account from "
                                             @"Settings-> Mail-> Add Account"
                                    delegate:nil
                           cancelButtonTitle:@"OK"
                           otherButtonTitles:nil, nil];
      [alert show];
    }

  } break;
  case 4: // My Profile
  {

    ProfileViewController *profileVC =
        [[ProfileViewController alloc] initWithNibName:@"ProfileViewController"
                                                bundle:[NSBundle mainBundle]];
    UINavigationController *nav =
        [[UINavigationController alloc] initWithRootViewController:profileVC];

    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
      nav.navigationBar.barTintColor = [UIColor whiteColor];
      [nav.navigationBar setTintColor:[UIColor blackColor]];
      nav.navigationBar.translucent = NO;
    } else {
      nav.navigationBar.tintColor = [UIColor blackColor];
      //        eventNav.navigationBar.tintColor = [UIColor blackColor];
    }

    self.menuContainerViewController.centerViewController = nav;
    [self.menuContainerViewController toggleLeftSideMenuCompletion:nil];

  } break;
  case 5: // My Events
  {

    isFromMyEvent = YES;
    isFromEventsNearMe = NO;
    isFromMyPicture = NO;
    EventListViewController *eventVC = [[EventListViewController alloc]
        initWithNibName:@"EventListViewController"
                 bundle:[NSBundle mainBundle]];
    NSInteger user_id = [[[NSUserDefaults standardUserDefaults]
        objectForKey:@"user_id"] integerValue];
    [eventVC getEventsForMyEvents:user_id];
    UINavigationController *eventNav =
        [[UINavigationController alloc] initWithRootViewController:eventVC];

//    UIImageView *headerLogoView =
//        [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"new-logo"]];
//    [eventNav.navigationBar addSubview:headerLogoView];
//    headerLogoView.center = eventNav.navigationBar.center;

    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
      eventNav.navigationBar.barTintColor = [UIColor whiteColor];
      [eventNav.navigationBar setTintColor:[UIColor blackColor]];
      eventNav.navigationBar.translucent = NO;
    } else {
      eventNav.navigationBar.tintColor = [UIColor blackColor];
    }

    self.menuContainerViewController.centerViewController = eventNav;
    [self.menuContainerViewController toggleLeftSideMenuCompletion:nil];

  } break;

  default:
    break;
  }
}

- (IBAction)btnProfileClicked:(id)sender {

  ProfileViewController *profileVC =
      [[ProfileViewController alloc] initWithNibName:@"ProfileViewController"
                                              bundle:[NSBundle mainBundle]];

  UINavigationController *nav =
      [[UINavigationController alloc] initWithRootViewController:profileVC];

  if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
    nav.navigationBar.barTintColor = [UIColor whiteColor];
    [nav.navigationBar setTintColor:[UIColor blackColor]];
    nav.navigationBar.translucent = NO;
  } else {
    nav.navigationBar.tintColor = [UIColor blackColor];
    //        eventNav.navigationBar.tintColor = [UIColor blackColor];
  }

  self.menuContainerViewController.centerViewController = nav;
  [self.menuContainerViewController toggleLeftSideMenuCompletion:nil];
}

- (IBAction)btnInviteClicked:(id)sender {
  InviteVC *inviteVC = [[InviteVC alloc] initWithNibName:@"InviteVC"
                                                  bundle:[NSBundle mainBundle]];

  UINavigationController *nav =
      [[UINavigationController alloc] initWithRootViewController:inviteVC];

  if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
    nav.navigationBar.barTintColor = [UIColor whiteColor];
    [nav.navigationBar setTintColor:[UIColor blackColor]];
    nav.navigationBar.translucent = NO;
  } else {
    nav.navigationBar.tintColor = [UIColor blackColor];
  }

  self.menuContainerViewController.centerViewController = nav;
  [self.menuContainerViewController toggleLeftSideMenuCompletion:nil];
}

#pragma mark - MFSideMenuStateNotificationEvent
- (void)menuEvent:(NSNotification *)sender {

  if ([[sender.userInfo objectForKey:@"eventType"] integerValue] == 1) {
    [self layoutTableHeader];
  }
}

#pragma mark - Custom Methods

- (void)layoutTableHeader {

  [_lblUserName setFont:[UIFont fontWithName:kAppSupportedFontNormal size:24]];
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSString *strUserName =
      [NSString stringWithFormat:@"%@", [defaults objectForKey:@"username"]];
  _lblUserName.text = strUserName;
  NSString *profileImage =
      [[NSUserDefaults standardUserDefaults] objectForKey:@"profile_image"];
  NSString *strURL;

  if (profileImage && ![profileImage isEqualToString:@""]) {

    strURL =
        [NSString stringWithFormat:@"%@uploads/profiles/%@", [Constants retriveServerURL], profileImage];
    // strURL = [NSString
    // stringWithFormat:@"http://culturecrossfire.com/wp-content/uploads/2014/01/The-Rock.jpeg"];
  } else {

    NSString *facebook_id = [[NSUserDefaults standardUserDefaults] objectForKey:@"facebook_id"];
    strURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=320&height=320", facebook_id];
  }
  CALayer *l = [_imgProfileView layer];
  [l setMasksToBounds:YES];
  [l setCornerRadius:_imgProfileView.frame.size.height / 2];
  [l setBorderWidth:2.0f];
  [l setBorderColor:[UIColor whiteColor].CGColor];

    //[_imgProfileView setImageWithURL:[NSURL URLWithString:strURL] placeholderImage:[UIImage imageNamed:@"default-human-img"] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
 NSURLRequest *req =
      [NSURLRequest requestWithURL:[NSURL URLWithString:strURL]];
  BOOL valid = [NSURLConnection canHandleRequest:req];
  if (valid) {
    [_activityIndicator startAnimating];
    AFImageRequestOperation *operation = [AFImageRequestOperation
        imageRequestOperationWithRequest:req
        imageProcessingBlock:nil
        success:^(NSURLRequest *request, NSHTTPURLResponse *response,
                  UIImage *image) {
            dispatch_async(dispatch_get_global_queue(
                               DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                           ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (image) {
                      [_activityIndicator stopAnimating];

                      // Later
                      // avatarView
                      if (!avatarView) {

                        avatarView = [[PAImageView alloc]
                                      initWithFrame:
                                          CGRectMake(
                                              _imgProfileView.frame.origin.x,
                                              _imgProfileView.frame.origin.y,
                                              _imgProfileView.frame.size.width,
                                              _imgProfileView.frame.size.height)
                            backgroundProgressColor:[UIColor whiteColor]
                                      progressColor:[UIColor lightGrayColor]];
                        [self.view insertSubview:avatarView
                                    belowSubview:_btnProfile];
                        //[self.view addSubview:avatarView];
                      }

                      [avatarView setImageURL:[NSURL URLWithString:strURL]];
                      avatarView.cacheEnabled = YES;
                    }
                });
            });
        }
        failure:^(NSURLRequest *request, NSHTTPURLResponse *response,
                  NSError *error) {
            [_imgProfileView
                setImage:[UIImage imageNamed:@"default-human-img"]];
        }];
    [operation start];
  }
}

#pragma mark - UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView
    clickedButtonAtIndex:(NSInteger)buttonIndex {

//  if (alertView.tag == 2001) {
//
//    if (buttonIndex == 0) {
//
//      [FBSession.activeSession closeAndClearTokenInformation];
//
//      NSDictionary *parameters =
//          [NSDictionary dictionaryWithObject:@"mobile" forKey:@"source"];
//
//      [[SnapprintsClient sharedSnapprintsClient] postPath:@"/users/logout.json"
//          parameters:parameters
//          success:^(AFHTTPRequestOperation *operation, id responseObject) {
//
//              NSString *status = [[responseObject objectForKey:@"result"]
//                  objectForKey:@"status"];
//
//              if ([status isEqualToString:@"failed"]) {
//
//              } else {
//                NSUserDefaults *defaults =
//                    [NSUserDefaults standardUserDefaults];
//                [defaults removeObjectForKey:@"user_id"];
//                [defaults removeObjectForKey:@"email"];
//                [defaults removeObjectForKey:@"facebook_id"];
//                [defaults removeObjectForKey:@"facebook_token"];
//                [defaults removeObjectForKey:@"profile_image"];
//                [defaults removeObjectForKey:@"token"];
//                [defaults removeObjectForKey:@"username"];
//                [defaults synchronize];
//
//                FirstScreenViewController *viewController =
//                    [[FirstScreenViewController alloc]
//                        initWithNibName:@"FirstScreenViewController"
//                                 bundle:[NSBundle mainBundle]];
//
//                UINavigationController *navBar = [[UINavigationController alloc]
//                    initWithRootViewController:viewController];
//
//                if ([[[UIDevice currentDevice] systemVersion] floatValue] >=
//                    7.0) {
//                  navBar.navigationBar.barTintColor =
//                      UIColorFromRGB(COLOR_LIGHT_BLUE);
//                  [navBar.navigationBar setTintColor:[UIColor whiteColor]];
//                  navBar.navigationBar.translucent = NO;
//                } else {
//                  navBar.navigationBar.tintColor = [UIColor blackColor];
//                  //        eventNav.navigationBar.tintColor = [UIColor
//                  //        blackColor];
//                }
//
//                [self.menuContainerViewController
//                    presentViewController:navBar
//                                 animated:YES
//                               completion:^{
//                                   [self.menuContainerViewController
//                                       toggleLeftSideMenuCompletion:nil];
//                               }];
//              }
//          }
//          failure:^(AFHTTPRequestOperation *operation, NSError *error) {}];
//    }
//  }
}

#pragma mark MFMailComposerViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error {

  if (!error) {
    [self.menuContainerViewController dismissViewControllerAnimated:YES
                                                         completion:nil];
  } else {
    UIAlertView *alertView = [[UIAlertView alloc]
            initWithTitle:@"Error"
                  message:@"Your message could not be sent at this time"
                 delegate:nil
        cancelButtonTitle:@"OK"
        otherButtonTitles:nil, nil];
    [alertView show];
    [self.menuContainerViewController dismissViewControllerAnimated:YES
                                                         completion:nil];
  }
}

@end
