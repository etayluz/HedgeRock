//
//  ForgotPasswordViewController.m
//  SNAPprints
//
//  Created by Etay Luz on 2/12/14.
//  Copyright (c) 2014 Etay Luz. All rights reserved.
//

#import "ForgotPasswordViewController.h"
#import "TSMessage.h"
#import "MBProgressHUD.h"
@interface ForgotPasswordViewController ()

@end

@implementation ForgotPasswordViewController

@synthesize emailTextField, noticeLabel, resetButton;

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

  [self applyTextFieldStyleToTextField:emailTextField];
  noticeLabel.font = [UIFont fontWithName:kAppSupportedFontLight size:14.0f];
  resetButton.layer.cornerRadius = 5.0f;
  resetButton.titleLabel.font =
      [UIFont fontWithName:kAppSupportedFontLight size:16.0f];
  [_lblTitle setFont:[UIFont fontWithName:kAppSupportedFontLight size:22.0f]];
    
    UILabel *lable = [[UILabel alloc] init];
    lable.frame = self.navigationController.navigationBar.frame;
    lable.numberOfLines = 2;
    lable.text = @"Reset Password";
    [lable sizeToFit];
    lable.textColor = [UIColor grayColor];
    lable.font = [UIFont fontWithName:kAppSupportedFontBold size:16.0f];
    self.navigationItem.titleView = lable;
    
}
- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - Action Events

- (IBAction)resetPressed:(id)sender {
  [emailTextField resignFirstResponder];
  NSString *email = emailTextField.text;

  if (![self validateEmail:email]) {

    NSString *strTitle = @"Please enter valid email address.";
    emailTextField.layer.borderColor = [[UIColor redColor] CGColor];
    [TSMessage setDefaultViewController:self.navigationController];
    [TSMessage showNotificationWithTitle:@"Password Reset Error"
                                subtitle:strTitle
                                    type:TSMessageNotificationTypeError];
  } else {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading...";
    [hud show:YES];
    emailTextField.layer.borderColor = [[UIColor whiteColor] CGColor];
    NSDictionary *parameters =
        [NSDictionary dictionaryWithObjects:@[ email, @"mobile" ]
                                    forKeys:@[ @"User[email]", @"source" ]];
    [[SnapprintsClient sharedSnapprintsClient]
        postPath:@"/users/reset_password.json"
        parameters:parameters
        success:^(AFHTTPRequestOperation *operation, id responseObject) {

            NSString *message = [responseObject objectForKey:@"message"];
            if ([[responseObject objectForKey:@"status"]
                    isEqualToString:@"error"]) {
              [TSMessage setDefaultViewController:self.navigationController];
              [TSMessage
                  showNotificationWithTitle:@"Password Reset Error"
                                   subtitle:message
                                       type:TSMessageNotificationTypeError];

            } else {
              NSString *message = [responseObject objectForKey:@"message"];
              [TSMessage setDefaultViewController:self.navigationController];
              [TSMessage
                  showNotificationWithTitle:@"Success!"
                                   subtitle:message
                                       type:TSMessageNotificationTypeSuccess];
              [self.navigationController popViewControllerAnimated:YES];
            }
            [hud removeFromSuperview];
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [TSMessage setDefaultViewController:self.navigationController];
            [TSMessage
                showNotificationWithTitle:@"Password Reset Error"
                                 subtitle:
                                     @"We are unable to reset your password"
                                     type:TSMessageNotificationTypeError];
            [hud removeFromSuperview];
        }];
  }
}

#pragma mark - Custom Methods
/*
 Function: validateEmail
 Decription: Validation for email.
 Return: BOOL
 Param: NSString
 */
- (BOOL)validateEmail:(NSString *)email {
  NSString *emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
  NSPredicate *regExPredicate =
      [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
  BOOL myStringMatchesRegEx = [regExPredicate evaluateWithObject:email];

  if (!myStringMatchesRegEx) {
    return NO;
  } else
    return YES;
}

/*
 Function: applyTextFieldStyleToTextField
 Decription: Applies styling for textfield.
 Return: void
 Param: textfield
 */
- (void)applyTextFieldStyleToTextField:(UITextField *)textfield;
{
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

#pragma mark - UITextFiled delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  return YES;
}

@end
