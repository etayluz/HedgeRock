//
//  FirstScreenViewController.m
//  SNAPprints
//
//  Created by Etay Luz on 9/16/13.
//  Copyright (c) 2013 Etay Luz. All rights reserved.
//

#import "FirstScreenViewController.h"
#import "AppDelegate.h"
#import "SignUpViewController.h"
#import "LoginViewController.h"
#import "SideMenuGridViewController.h"
@interface FirstScreenViewController ()
{
    SideMenuGridViewController *sideMenuVC;
}
@property(strong, nonatomic)
MFSideMenuContainerViewController *sideMenuContainerVC;
@end

@implementation FirstScreenViewController

@synthesize facebookButton;
@synthesize snapprintsButton;
@synthesize createAccountButton;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
    self.title = @"";
  }
  return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

#pragma mark - View Life Cycle

- (void)viewDidLoad {
  [super viewDidLoad];
  [self.navigationController.navigationBar
      setBarTintColor:[UIColor whiteColor]];
  self.navigationController.navigationBar.tintColor =
      UIColorFromRGB(COLOR_LIGHT_BLUE);
  snapprintsButton.layer.cornerRadius = 5.0f;
  createAccountButton.layer.cornerRadius = 5.0f;
  facebookButton.layer.cornerRadius = 5.0f;
  [createAccountButton.layer setBorderWidth:1.0f];
  [createAccountButton.layer setBorderColor:[[UIColor whiteColor] CGColor]];
  [createAccountButton.titleLabel
      setFont:[UIFont fontWithName:kAppSupportedFontNormal size:13.f]];

  [snapprintsButton.layer setBorderWidth:1.0f];
  [snapprintsButton.layer setBorderColor:[[UIColor whiteColor] CGColor]];
  [snapprintsButton.titleLabel
      setFont:[UIFont fontWithName:kAppSupportedFontNormal size:13.f]];
  [[FBRequest requestForMe]
      startWithCompletionHandler:^(FBRequestConnection *connection,
                                   NSDictionary<FBGraphUser> *user,
                                   NSError *error) {

          if (!error) {
          }
      }];

//  UIImageView *headerLogoView =
//      [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"new-logo"]];
//  headerLogoView.frame =
//      CGRectMake(105.0f, 5.0f, headerLogoView.frame.size.width,
//                 headerLogoView.frame.size.height);
//  [self.navigationController.navigationBar addSubview:headerLogoView];
  self.navigationController.navigationBarHidden = YES;
  // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
  [self.navigationController setNavigationBarHidden:YES];
}

#pragma mark IBActions
- (void)signupTapped:(id)sender {
  SignUpViewController *signupVC =
      [[SignUpViewController alloc] initWithNibName:@"SignUpViewController"
                                             bundle:[NSBundle mainBundle]];
  // self.title = @"Back";
  [self.navigationController pushViewController:signupVC animated:YES];
}

- (void)loginSnapprintsButtonPressed:(id)sender {
  LoginViewController *loginVC =
      [[LoginViewController alloc] initWithNibName:@"LoginViewController"
                                            bundle:[NSBundle mainBundle]];

  [self.navigationController pushViewController:loginVC animated:YES];
}

- (IBAction)facebookButtonTapped:(id)sender {
  hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
  hud.labelText = @"Loading...";
  [hud show:YES];
  if ([FBSession.activeSession isOpen]) {
    // Session is open

    [self dismissViewControllerAnimated:YES completion:nil];
    [hud removeFromSuperview];

  } else {
    // Initialize a session object
    FBSession *session = [[FBSession alloc] init];

    // Set the active session
    [FBSession setActiveSession:session];

    // Open the session
    [FBSession
        openActiveSessionWithReadPermissions:nil allowLoginUI:
                  YES completionHandler:^(FBSession *session,
                                          FBSessionState status,
                                          NSError *error) {
                      if (error) {
                          NSLog(@"%@", [error description]);
                        [hud removeFromSuperview];
                      } else {
                        NSString *accessToken =
                            [FBSession activeSession]
                                .accessTokenData.accessToken;

 
                        //Changes by mohsinali on 27 may 2015
//                        NSDictionary *parameters = [[NSDictionary alloc] initWithObjectsAndKeys:accessToken, @"access_token", nil];

                        // Get Facebook request
                        [[FBRequest requestForMe]
                            startWithCompletionHandler:^(FBRequestConnection *
                                                             connection,
                                                         NSDictionary<
                                                             FBGraphUser> *user,
                                                         NSError *error) {

                                if (!error) {
                                    NSLog(@"facebook user data==%@", user);
                                  // Register the user
                                    NSString *strUrl = [NSString stringWithFormat:@"/users/register.json?access_token=%@",accessToken];//Changes by mohsinali on 27 may 2015

                                  [[SnapprintsClient sharedSnapprintsClient]postPath:strUrl parameters:nil success:^(AFHTTPRequestOperation *operation,id responseObject) {

                                          NSString *status = [[responseObject
                                              objectForKey:@"result"]
                                              objectForKey:@"status"];
                                          if ([status isEqualToString:@"success"]) {
                                              isFBUserRegistered = YES;
                                            NSDictionary *userDict =[[[responseObject objectForKey:@"result"]objectForKey:@"user"]objectForKey:@"User"];

                                            NSString *user_id =
                                                [userDict objectForKey:@"id"];
                                            NSString *email = [userDict
                                                objectForKey:@"email"];
                                            NSString *facebook_id = [userDict
                                                objectForKey:@"facebook_id"];
                                            NSString *facebook_token = [userDict
                                                objectForKey:@"fb_token"];
                                            NSString *profile_image = [userDict
                                                objectForKey:@"profile_image"];
                                            NSString *token = [userDict
                                                objectForKey:@"token"];
                                            NSString *username = [userDict
                                                objectForKey:@"username"];
                                            NSString *firstName = [userDict
                                                objectForKey:@"fname"];
                                            NSString *lastName = [userDict
                                                objectForKey:@"lname"];

                                            NSUserDefaults *defaults =
                                                [NSUserDefaults
                                                        standardUserDefaults];

                                            if (![user_id isKindOfClass:
                                                              [NSNull class]])
                                              [defaults setObject:user_id
                                                           forKey:@"user_id"];

                                            if (![email isKindOfClass:
                                                            [NSNull class]])
                                              [defaults setObject:email
                                                           forKey:@"email"];

                                            if (![facebook_id
                                                    isKindOfClass:
                                                        [NSNull class]])
                                              [defaults
                                                  setObject:facebook_id
                                                     forKey:@"facebook_id"];

                                            if (![facebook_token
                                                    isKindOfClass:
                                                        [NSNull class]])
                                              [defaults
                                                  setObject:facebook_token
                                                     forKey:@"facebook_token"];

                                            if (![profile_image
                                                    isKindOfClass:
                                                        [NSNull class]])
                                              [defaults
                                                  setObject:profile_image
                                                     forKey:@"profile_image"];

                                            if (![token isKindOfClass:
                                                            [NSNull class]])
                                              [defaults setObject:token
                                                           forKey:@"token"];

                                            if (![username isKindOfClass:
                                                               [NSNull class]])
                                              [defaults setObject:username
                                                           forKey:@"username"];

                                            if (![firstName
                                                    isKindOfClass:
                                                        [NSNull class]]) {
                                              [defaults setObject:firstName
                                                           forKey:@"fname"];
                                            }

                                            if (![lastName
                                                    isKindOfClass:
                                                        [NSNull class]]) {
                                              [defaults setObject:firstName
                                                           forKey:@"lname"];
                                            }

                                            [defaults synchronize];
                                            [hud removeFromSuperview];
//                                            [self dismissViewControllerAnimated:
//                                                      YES completion:nil];
//                                              if ([self.delegate
//                                                   respondsToSelector:@selector(firstScreenViewController:
//                                                                                didLogin:)]) {
//                                                       [self.delegate firstScreenViewController:self
//                                                                                       didLogin:@"success"];
//                                                   }
                                              // New changes to land app on one specific home page
                                              isFromEventsNearMe = YES;
                                              isFromMyEvent = NO;
                                              EventListViewController *eventVC =
                                              [[EventListViewController alloc]
                                               initWithNibName:@"EventListViewController"
                                               bundle:[NSBundle mainBundle]];
                                              
                                              [eventVC getEventsForUser:user_id.integerValue];
                                              
                                              UINavigationController *eventNav = [[UINavigationController alloc]
                                                                                  initWithRootViewController:eventVC];
                                              
//                                              UIImageView *headerLogoView = [[UIImageView alloc]
//                                                                             initWithImage:[UIImage imageNamed:@"new-logo"]];
//                                              [eventNav.navigationBar addSubview:headerLogoView];
//                                              headerLogoView.center = eventNav.navigationBar.center;
                                              
                                              if ([[[UIDevice currentDevice] systemVersion] floatValue] >=
                                                  7.0) {
                                                  eventNav.navigationBar.barTintColor = [UIColor whiteColor];
                                                  [eventNav.navigationBar setTintColor:[UIColor blackColor]];
                                                  eventNav.navigationBar.translucent = NO;
                                              } else {
                                                  eventNav.navigationBar.tintColor = [UIColor blackColor];
                                              }
                                              
                                              sideMenuVC = [[SideMenuGridViewController alloc]
                                                            initWithNibName:@"SideMenuGridViewController"
                                                            bundle:[NSBundle mainBundle]];
                                              
                                              _sideMenuContainerVC = [MFSideMenuContainerViewController
                                                                      containerWithCenterViewController:eventNav
                                                                      leftMenuViewController:sideMenuVC
                                                                      rightMenuViewController:nil];
                                              AppDelegate *appdelegate =
                                              (AppDelegate *)[[UIApplication sharedApplication] delegate];
                                              appdelegate.sideMenuContainerForLogin = _sideMenuContainerVC;
                                              [self presentViewController:_sideMenuContainerVC
                                                                 animated:YES
                                                               completion:^{ [hud removeFromSuperview]; }];

                                          } else {
                                              isFBUserRegistered = NO;
                                              [hud removeFromSuperview];
                                              NSString *errMSg = [NSString stringWithFormat:@"Your Facebook account '%@' is not the verified account. Please use another Facebook account to Login in SNAPprints.",[user objectForKey:@"email"]];
                                              UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SNAPprints" message:errMSg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                              [alertView show];
                                              if ([FBSession.activeSession isOpen]) {
                                                  [FBSession.activeSession closeAndClearTokenInformation];                                              }
                                          }
                                      }
                                      failure:^(AFHTTPRequestOperation *
                                                    operation,
                                                NSError *error) {
                                          isFBUserRegistered = NO;
                                          if ([FBSession.activeSession isOpen]) {
                                              [FBSession.activeSession closeAndClearTokenInformation];
                                          }
                                          [hud removeFromSuperview];
                                      }];
                                }
                            }];
                      }
                  }];
  }
}

#pragma mark FBLoginViewDelegate methods
- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
  NSString *accessToken = [FBSession activeSession].accessTokenData.accessToken;

  NSDictionary *parameters = [[NSDictionary alloc]
      initWithObjectsAndKeys:accessToken, @"access_token", nil];

  [[SnapprintsClient sharedSnapprintsClient] postPath:@"/users/register.json"
      parameters:parameters
      success:^(AFHTTPRequestOperation *operation, id responseObject) {

          NSString *status =
              [[responseObject objectForKey:@"result"] objectForKey:@"status"];
          if ([status isEqualToString:@"success"]) {
            NSDictionary *userDict =
                [[[responseObject objectForKey:@"result"] objectForKey:@"user"]
                    objectForKey:@"User"];

            NSString *user_id = [userDict objectForKey:@"id"];
            NSString *email = [userDict objectForKey:@"email"];
            NSString *facebook_id = [userDict objectForKey:@"facebook_id"];
            NSString *facebook_token = [userDict objectForKey:@"fb_token"];
            NSString *profile_image = [userDict objectForKey:@"profile_image"];
            NSString *token = [userDict objectForKey:@"token"];
            NSString *username = [userDict objectForKey:@"username"];

            NSString *firstName = [userDict objectForKey:@"fname"];
            NSString *lastName = [userDict objectForKey:@"lname"];

            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

            if (![user_id isKindOfClass:[NSNull class]])
              [defaults setObject:user_id forKey:@"user_id"];

            if (![email isKindOfClass:[NSNull class]])
              [defaults setObject:email forKey:@"email"];

            if (![facebook_id isKindOfClass:[NSNull class]])
              [defaults setObject:facebook_id forKey:@"facebook_id"];

            if (![facebook_token isKindOfClass:[NSNull class]])
              [defaults setObject:facebook_token forKey:@"facebook_token"];

            if (![profile_image isKindOfClass:[NSNull class]])
              [defaults setObject:profile_image forKey:@"profile_image"];

            if (![token isKindOfClass:[NSNull class]])
              [defaults setObject:token forKey:@"token"];

            if (![username isKindOfClass:[NSNull class]])
              [defaults setObject:username forKey:@"username"];

            if (![firstName isKindOfClass:[NSNull class]]) {
              [defaults setObject:firstName forKey:@"fname"];
            }

            if (![lastName isKindOfClass:[NSNull class]]) {
              [defaults setObject:lastName forKey:@"lname"];
            }

            [defaults synchronize];

            if ([self.delegate
                    respondsToSelector:@selector(firstScreenViewController:
                                                                  didLogin:)]) {
              [self.delegate firstScreenViewController:self
                                              didLogin:@"success"];
            }

            [self dismissViewControllerAnimated:YES completion:nil];
          }
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {}];
}

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
}

#pragma mark Memory Warning
- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
