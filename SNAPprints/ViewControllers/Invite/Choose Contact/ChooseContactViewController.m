//
//  Cho0seContactViewController.m
//  SNAPprints
//
//  Created by Etay Luz on 09/07/14.
//  Copyright (c) 2014 Etay Luz. All rights reserved.
//

#import "ChooseContactViewController.h"
#import "InviteVC.h"
#import "TSMessage.h"
#import "MFSideMenu.h"
#import "ConstantFlags.h"
#import "MBProgressHUD.h"

@interface ChooseContactViewController () {
  MBProgressHUD *hud;
}
@property(weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIView *containerView;
@end

@implementation ChooseContactViewController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
    self.title = @"";
  }
  return self;
}
#pragma mark - View Life Cycle

- (void)viewDidLoad {
  [super viewDidLoad];
  _btnChooseContacts.layer.cornerRadius = 5;
  _btnSubmit.layer.cornerRadius = 5;
  _btnSubmit.layer.borderColor = [[UIColor lightGrayColor] CGColor];
  _btnSubmit.layer.borderWidth = 1.0;
  _txtViewEmails = [self styleTextView:_txtViewEmails];
  hud = [[MBProgressHUD alloc] initWithView:self.view];
  // if([self.menuContainerViewController
  // respondsToSelector:@selector(toggleLeftSideMenuCompletion:)])
  if (isFromAddEvent) {
    UIImage *hamburgerImage = [UIImage imageNamed:@"hamburger-icon"];
    UIButton *sideButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sideButton addTarget:self
                   action:@selector(toggleLeft:)
         forControlEvents:UIControlEventTouchUpInside];
    sideButton.bounds =
        CGRectMake(0, 0, hamburgerImage.size.width, hamburgerImage.size.height);
    [sideButton setImage:hamburgerImage forState:UIControlStateNormal];
    UIBarButtonItem *hamburgerButton =
        [[UIBarButtonItem alloc] initWithCustomView:sideButton];
    self.navigationItem.leftBarButtonItem = hamburgerButton;
    [_btnLater setHidden:NO];
    _btnLater.layer.cornerRadius = 5;
    _btnLater.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    _btnLater.layer.borderWidth = 1.0;
    [_lblLater setHidden:NO];
  }
  else{
      CGRect originalFrame = _btnSubmit.frame;
      originalFrame.origin.x = 95;
      _btnSubmit.frame = originalFrame;
  }

    _scrollView.contentSize = _containerView.frame.size;
    
    UILabel *lable = [[UILabel alloc] init];
    lable.frame = self.navigationController.navigationBar.frame;
    lable.numberOfLines = 2;
    lable.text = @"Select Contact";
    [lable sizeToFit];
    lable.textColor = [UIColor grayColor];
    lable.font = [UIFont fontWithName:kAppSupportedFontBold size:16.0f];
    self.navigationItem.titleView = lable;
}
- (void)viewWillDisappear:(BOOL)animated {

  [super viewWillDisappear:animated];
  [_txtViewEmails resignFirstResponder];
}
- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - Action events

- (IBAction)btnLaterClicked:(id)sender {
    EventListViewController *eventVC = [[EventListViewController alloc]
                                        initWithNibName:@"EventListViewController"
                                        bundle:[NSBundle mainBundle]];
    NSInteger user_id = [[[NSUserDefaults standardUserDefaults]
                          objectForKey:@"user_id"] integerValue];
    if (isFromMyEvent)
        [eventVC getEventsForMyEvents:user_id];
    else
        [eventVC getEventsForUser:user_id];
    [self.navigationController pushViewController:eventVC animated:YES];
}

- (IBAction)btnSubmit:(id)sender {
    [self.view endEditing:YES];
  NSString *strEmails = _txtViewEmails.text;
  NSArray *arr;
  BOOL isEmailsValid = NO;
  if ([strEmails length] > 0) {
    arr = [strEmails componentsSeparatedByString:@","];
    if ([arr count] > 0) {

      for (NSString *str in arr) {

        isEmailsValid = YES;

        if (![str isEqualToString:@""]) {

          if (![self Emailvalidate:str] && [str length] > 0) {

            isEmailsValid = NO;
          }
        } else
          isEmailsValid = NO;
      }
    }
  }

  if (isEmailsValid) {

    hud.labelText = @"Sending Invitation...";
    [self.view addSubview:hud];
    [hud show:YES];
    [self sendInvitation:arr];
  } else {

    [TSMessage setDefaultViewController:self.navigationController];
    [TSMessage
        showNotificationWithTitle:@"Invite Error"
                         subtitle:@"Please enter valid email address(es)."
                             type:TSMessageNotificationTypeError];
  }
}

- (IBAction)btnChooseFromContacts:(id)sender {

  InviteVC *ObjinviteVC =
      [[InviteVC alloc] initWithNibName:@"InviteVC" bundle:nil];
  ObjinviteVC.event = _event;
  [self.navigationController pushViewController:ObjinviteVC animated:YES];
}
#pragma mark
#pragma mark - API call

/*
 Function: sendInvitation
 Decription: Send invitation for selected contacts.
 Return: void
 Param: NSArray
 */
- (void)sendInvitation:(NSArray *)arr {
  // http://snapprints.benchmarkitsolution.com/invites/add.json

  NSString *user_id =
      [[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"];
  NSString *event_id = [NSString stringWithFormat:@"%ld", (long)_event.eventId];
  NSMutableString *strInvites = [NSMutableString stringWithString:@""];
  for (int i = 0; i < [arr count]; i++) {
    [strInvites appendFormat:@"%@#", [arr objectAtIndex:i]];
    if (i < [arr count] - 1) {
      [strInvites appendFormat:@","];
    }
  }
  NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
  [parameters setObject:strInvites forKey:@"Invite[invitees]"];
  [parameters setObject:user_id forKey:@"user_id"];
  [parameters setObject:event_id forKey:@"event_id"];

  [[SnapprintsClient sharedSnapprintsClient] postPath:@"invites/add.json"
      parameters:parameters
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSLog(@"Response for Invite:%@", responseObject);
          [hud hide:YES];
          if ([[responseObject objectForKey:@"status"]
                  isEqualToString:@"success"]) {
            if (isFromAddEvent) {
              EventListViewController *eventVC =
                  [[EventListViewController alloc]
                      initWithNibName:@"EventListViewController"
                               bundle:[NSBundle mainBundle]];

              NSInteger loggedUser_id = [[[NSUserDefaults standardUserDefaults]
                  objectForKey:@"user_id"] integerValue];
              if (isFromMyEvent)
                [eventVC getEventsForMyEvents:loggedUser_id];
              else
                [eventVC getEventsForUser:loggedUser_id];

              UINavigationController *eventNav = [[UINavigationController alloc]
                  initWithRootViewController:eventVC];
              [TSMessage setDefaultViewController:eventNav];
              [TSMessage
                  showNotificationWithTitle:@"Invite"
                                   subtitle:[responseObject
                                                objectForKey:@"message"]
                                       type:TSMessageNotificationTypeSuccess];

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

              self.menuContainerViewController.centerViewController = eventNav;

            } else {
              [TSMessage setDefaultViewController:self.navigationController];
              [TSMessage
                  showNotificationWithTitle:@"Invite"
                                   subtitle:[responseObject
                                                objectForKey:@"message"]
                                       type:TSMessageNotificationTypeSuccess];
              NSString *str = @"EventDetailVC";
              [self popControllerToSpecified:str];
            }

          } else {
            [TSMessage setDefaultViewController:self.navigationController];
            [TSMessage
                showNotificationWithTitle:@"Error"
                                 subtitle:[responseObject
                                              objectForKey:@"message"]
                                     type:TSMessageNotificationTypeError];
          }
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          NSLog(@"Error: %@", error.description);
          [TSMessage setDefaultViewController:self.navigationController];
          [TSMessage showNotificationWithTitle:@"Error"
                                      subtitle:@"Fail to send invitation."
                                          type:TSMessageNotificationTypeError];
          [hud hide:YES];
      }];
}

#pragma mark
#pragma mark - Custom Methods
/*
 Function: Emailvalidate
 Decription: Validation for emails.
 Return: BOOL
 Param: NSString
 */
- (BOOL)Emailvalidate:(NSString *)mail {
  BOOL stricterFilter = YES;
  NSString *stricterFilterString =
      @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
  NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
  NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
  NSPredicate *emailTest =
      [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
  return [emailTest evaluateWithObject:mail];
}

/*
 Function: popControllerToSpecified
 Decription: Removes specific controller from navigation controller's stack.
 Return: void
 Param: NSString
 */
- (void)popControllerToSpecified:(NSString *)className {

  UINavigationController *navController = self.navigationController;

  for (NSInteger i = 0; i < [navController.viewControllers count]; i++) {

    UIViewController *controller =
        [navController.viewControllers objectAtIndex:i];

    if ([controller.nibName isEqualToString:className]) {
      [navController popToViewController:controller animated:YES];
      return;
    }
  }
}

/*
 Function: styleTextView
 Decription: Applies font styling to textview.
 Return: UITextView
 Param: UITextView
 */
- (UITextView *)styleTextView:(UITextView *)textView {
  textView.layer.borderColor = [[UIColor whiteColor] CGColor];
  textView.backgroundColor = [UIColor colorWithRed:230.0f / 255.0f
                                             green:230.0f / 255.0f
                                              blue:230.0f / 255.0f
                                             alpha:1.0];
  // textField.layer.borderWidth = 0.5f;
  textView.layer.cornerRadius = 1.0f;
  [textView setFont:[UIFont fontWithName:kAppSupportedFontLight size:12.0]];
  _lblTitle.font = [UIFont fontWithName:kAppSupportedFontLight size:22.0f];
  _lblEnterEmail.font = [UIFont fontWithName:kAppSupportedFontLight size:15.0f];

  _lblExample.font = [UIFont fontWithName:kAppSupportedFontLight size:13.0f];
  _lblOR.font = [UIFont fontWithName:kAppSupportedFontLight size:14.0f];
  _lblOR.font = [UIFont boldSystemFontOfSize:14.0];
  _btnSubmit.titleLabel.font =
      [UIFont fontWithName:kAppSupportedFontLight size:14.0f];
  _btnChooseContacts.titleLabel.font =
      [UIFont fontWithName:kAppSupportedFontLight size:17.0f];
  _btnSubmit.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
  return textView;
}

- (void)toggleLeft:(id)sender {
  [self.menuContainerViewController toggleLeftSideMenuCompletion:^{}];
}

#pragma mark UITextFields
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {

  return YES;
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView {

  [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
  return YES;
}
- (void)textViewDidBeginEditing:(UITextView *)textView {
  CGPoint scrollPoint = CGPointMake(0.0, textView.frame.size.height-20);
  [_scrollView setContentOffset:scrollPoint animated:YES];
}
- (BOOL)textView:(UITextView *)textView
    shouldChangeTextInRange:(NSRange)range
            replacementText:(NSString *)text {

  NSString *currentString =
      [textView.text stringByReplacingCharactersInRange:range withString:text];

  if ([currentString length] > 0 && ![currentString isEqualToString:@"\n"]) {

    NSRange range = [currentString rangeOfString:@"\n"];
    if (range.location != NSNotFound) {
      [textView resignFirstResponder];
    }

    NSCharacterSet *nonNumberSet = [[NSCharacterSet
        characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGH"
                                           @"IJKLMNOPQRSTUVWXYZ0123456789-.@,"
                                           @"_"] invertedSet];
    if ([currentString rangeOfCharacterFromSet:nonNumberSet].location !=
        NSNotFound) {

      return NO;
    }

  } else {

    textView.text = @"";
    [textView resignFirstResponder];
    return NO;
  }

  return YES;
}

@end
