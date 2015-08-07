//
//  LoginViewController.m
//  SNAPprints
//
//  Created by Etay Luz on 9/16/13.
//  Copyright (c) 2013 Etay Luz. All rights reserved.
//

#import "LoginViewController.h"
#import "EventListViewController.h"
#import "TSMessage.h"
#import "ForgotPasswordViewController.h"
#import "MBProgressHUD.h"
#import "ConstantFlags.h"
#import "EventListViewController.h"
#import "MFSideMenu.h"
#import "SideMenuGridViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

@synthesize usernameTextField, passwordTextField, forgotPasswordButton;
@synthesize loginButton, errorMessage;

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

#pragma mark - View Life Cycle

- (void)viewDidLoad {
  [super viewDidLoad];
  [self applyTextFieldStyleToTextField:usernameTextField];
  [self applyTextFieldStyleToTextField:passwordTextField];
  [usernameTextField setFont:[UIFont fontWithName:kAppSupportedFontNormal size:16.0f]];
  [passwordTextField setFont:[UIFont fontWithName:kAppSupportedFontNormal size:16.0f]];
  loginButton.layer.cornerRadius = 5.0f;
  loginButton.titleLabel.font =
      [UIFont fontWithName:kAppSupportedFontLight size:19.0f];
  forgotPasswordButton.titleLabel.font =
      [UIFont fontWithName:kAppSupportedFontLight size:14.0f];
  [_lblTitle setFont:[UIFont fontWithName:kAppSupportedFontLight size:22.0f]];
    
    UILabel *lable = [[UILabel alloc] init];
    lable.frame = self.navigationController.navigationBar.frame;
    lable.numberOfLines = 2;
    lable.text = @"Login";
    [lable sizeToFit];
    lable.textColor = [UIColor grayColor];
    lable.font = [UIFont fontWithName:kAppSupportedFontBold size:16.0f];
    self.navigationItem.titleView = lable;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
  self.navigationController.navigationBarHidden = NO;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - Custom Methods

- (void)applyTextFieldStyleToTextField:(UITextField *)textfield;
{
  [textfield setFont:[UIFont fontWithName:kAppSupportedFontLight size:16.0f]];
  [textfield setBackgroundColor:[UIColor whiteColor]];
  textfield.backgroundColor = [UIColor colorWithRed:230.0f / 255.0f
                                              green:230.0f / 255.0f
                                               blue:230.0f / 255.0f
                                              alpha:1.0];
  textfield.layer.borderWidth = 0.5;
  textfield.layer.borderColor = [[UIColor lightGrayColor] CGColor];
  textfield.layer.cornerRadius = 5.0;
  textfield.textColor = [UIColor blackColor];
  [textfield setValue:[UIColor lightGrayColor]
           forKeyPath:@"_placeholderLabel.textColor"];
  CGRect frame = textfield.frame;
  frame.size.height = 80;
  textfield.frame = frame;
}

/*
 Function: formIsValid
 Decription: Validation method for all fileds .
 Return: BOOL
 */
- (BOOL)formIsValid {
  usernameTextField.text = [usernameTextField.text
      stringByTrimmingCharactersInSet:
          [NSCharacterSet whitespaceAndNewlineCharacterSet]];
  passwordTextField.text = [passwordTextField.text
      stringByTrimmingCharactersInSet:
          [NSCharacterSet whitespaceAndNewlineCharacterSet]];

  BOOL isValid = YES;
  NSString *strTitle = nil;
  if ([usernameTextField.text length] == 0 &&
      [passwordTextField.text length] == 0) {

    usernameTextField.layer.borderColor = [[UIColor redColor] CGColor];
    passwordTextField.layer.borderColor = [[UIColor redColor] CGColor];
    strTitle = @"Please enter valid username and password.";
    isValid = NO;
  } else if ([usernameTextField.text length] == 0) {

    usernameTextField.layer.borderColor = [[UIColor redColor] CGColor];
    passwordTextField.layer.borderColor = [[UIColor whiteColor] CGColor];
    strTitle = @"Please enter valid username.";
    isValid = NO;
  } else if ([passwordTextField.text length] == 0) {

    passwordTextField.layer.borderColor = [[UIColor redColor] CGColor];
    usernameTextField.layer.borderColor = [[UIColor whiteColor] CGColor];
    strTitle = @"Please enter valid password.";
    isValid = NO;
  }

  if (!isValid) {

    [TSMessage setDefaultViewController:self.navigationController];
    [TSMessage showNotificationWithTitle:@"Login"
                                subtitle:strTitle
                                    type:TSMessageNotificationTypeError];
  }

  return isValid;
}

#pragma mark - IBAction Methods

- (void)loginButtonPressed:(id)sender {
  [self.view endEditing:YES];
  if ([self formIsValid]) {

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading...";
    [hud show:YES];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:usernameTextField.text forKey:@"User[username]"];
    [parameters setObject:passwordTextField.text forKey:@"User[password]"];
    [parameters setObject:@"iOSApp" forKey:@"User[source]"];

    [[SnapprintsClient sharedSnapprintsClient] postPath:@"users/login.json"
        parameters:parameters
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"%@", [SnapprintsClient sharedSnapprintsClient]);
            NSString *status = [[responseObject objectForKey:@"result"]
                objectForKey:@"status"];
            if ([status isEqualToString:@"success"]) {
              NSDictionary *userDict = [[[responseObject objectForKey:@"result"]
                  objectForKey:@"user"] objectForKey:@"User"];

              NSString *user_id = [userDict objectForKey:@"id"];
              NSString *email = [userDict objectForKey:@"email"];
              NSString *facebook_id = [userDict objectForKey:@"facebook_id"];
              NSString *facebook_token = [userDict objectForKey:@"fb_token"];
              NSString *profile_image =
                  [userDict objectForKey:@"profile_image"];
              NSString *token = [userDict objectForKey:@"token"];
              NSString *username = [userDict objectForKey:@"username"];

              NSString *fname = @"";

              if (![[userDict objectForKey:@"fname"]
                      isKindOfClass:[NSNull class]]) {
                fname = [userDict objectForKey:@"fname"];
              }

              NSString *lname = @"";
              if (![[userDict objectForKey:@"lname"]
                      isKindOfClass:[NSNull class]]) {
                lname = [userDict objectForKey:@"lname"];
              }

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

              if (![username isKindOfClass:[NSNull class]]) {
                [defaults setObject:username forKey:@"username"];
              } else {
                [defaults setObject:@"" forKey:@"username"];
              }

              [defaults setObject:fname forKey:@"fname"];
              [defaults setObject:lname forKey:@"lname"];
              [defaults synchronize];

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

//              UIImageView *headerLogoView = [[UIImageView alloc]
//                  initWithImage:[UIImage imageNamed:@"new-logo"]];
//              [eventNav.navigationBar addSubview:headerLogoView];
//              headerLogoView.center = eventNav.navigationBar.center;

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
              [hud removeFromSuperview];
              [TSMessage setDefaultViewController:self.navigationController];
              [TSMessage
                  showNotificationWithTitle:@"Login Error"
                                   subtitle:[[responseObject
                                                valueForKey:@"result"]
                                                valueForKey:@"message"]
                                       type:TSMessageNotificationTypeError];
            }
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {

            [hud removeFromSuperview];
            [TSMessage setDefaultViewController:self.navigationController];
            [TSMessage
                showNotificationWithTitle:@"Login"
                                 subtitle:@"Unkown error from server."
                                     type:TSMessageNotificationTypeError];
        }];
  }
}

- (void)forgotPasswordPressed:(id)sender {
  ForgotPasswordViewController *forgotVC = [[ForgotPasswordViewController alloc]
      initWithNibName:@"ForgotPasswordViewController"
               bundle:[NSBundle mainBundle]];
  self.title = @"";

  [self.navigationController pushViewController:forgotVC animated:YES];
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  return YES;
}
@end
