//
//  SignUpViewController.m
//  SNAPprints
//
//  Created by Etay Luz on 9/16/13.
//  Copyright (c) 2013 Etay Luz. All rights reserved.
//

#import "SignUpViewController.h"
#import "SignUpConfirmViewController.h"
#import "AFJSONRequestOperation.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+CFT.h"
#import "UIImage+ProportionalFill.h"
#import "TSMessage.h"
#import "WebViewController.h"
#import "ConstantFlags.h"

#define TEXTFIELD_TAG_USERNAME 22
#define TEXTFIELD_TAG_EMAIL 23
#define TEXTFIELD_TAG_PASSWORD 24
#define TEXTFIELD_TAG_CONFIRM_PASSWORD 25

@interface SignUpViewController () {
  UITextField *activeTextField;
}

@property(weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation SignUpViewController

@synthesize usernameTextField, emailTextField, passwordTextField,
    confirmPasswordTextField;
@synthesize cameraRollButton, takePhotoButton, profileThumbnailView;
@synthesize getStartedButton;

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.title = @"";
  }
  return self;
}

#pragma mark - View Life cycle

- (void)viewDidLoad {
  [super viewDidLoad];
  if (!library) {

    library = [[ALAssetsLibrary alloc] init];
  }

  [self registerForKeyboardNotifications];
  [self.view setBackgroundColor:[UIColor whiteColor]];
  usernameTextField = [self styleTextField:usernameTextField];
  emailTextField = [self styleTextField:emailTextField];
  passwordTextField = [self styleTextField:passwordTextField];
  confirmPasswordTextField = [self styleTextField:confirmPasswordTextField];

  [usernameTextField setFont:[UIFont fontWithName:kAppSupportedFontNormal size:16.0f]];
  [emailTextField setFont:[UIFont fontWithName:kAppSupportedFontNormal size:16.0f]];
  [passwordTextField setFont:[UIFont fontWithName:kAppSupportedFontNormal size:16.0f]];
  [confirmPasswordTextField
      setFont:[UIFont fontWithName:kAppSupportedFontNormal size:16.0f]];

  cameraRollButton.layer.cornerRadius = 5;
  cameraRollButton.tag = 0;
  takePhotoButton.layer.cornerRadius = 5;
  takePhotoButton.tag = 1;
  getStartedButton.layer.cornerRadius = 5;
  _lblCreateAccount.font = [UIFont fontWithName:kAppSupportedFontLight size:22.0f];
  _lblTerms.font = [UIFont fontWithName:kAppSupportedFontLight size:12.5f]; //14
  _btnGetStarted.titleLabel.font =
      [UIFont fontWithName:kAppSupportedFontLight size:19.0f];
  takePhotoButton.titleLabel.font =
      [UIFont fontWithName:kAppSupportedFontLight size:14.0f];
  cameraRollButton.titleLabel.font =
      [UIFont fontWithName:kAppSupportedFontLight size:14.0f];
  _termsDetailButton.titleLabel.font =
      [UIFont fontWithName:kAppSupportedFontLight size:14.0f];
  UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]
      initWithTarget:self
              action:@selector(displaySourceActionSheet:)];
  [profileThumbnailView addGestureRecognizer:tapGesture];
  self.navigationController.navigationBarHidden = NO;
    
    UILabel *lable = [[UILabel alloc] init];
    lable.frame = self.navigationController.navigationBar.frame;
    lable.numberOfLines = 2;
    lable.text = @"Sign Up";
    [lable sizeToFit];
    lable.textColor = [UIColor grayColor];
    lable.font = [UIFont fontWithName:kAppSupportedFontBold size:16.0f];
    self.navigationItem.titleView = lable;
    
  CALayer *l = [profileThumbnailView layer];
  [l setMasksToBounds:YES];
  [l setCornerRadius:35.0];
  [self termsText];

  [cameraRollButton.layer setMasksToBounds:YES];
  [cameraRollButton.layer setBorderWidth:0.5f];
  [cameraRollButton.layer setCornerRadius:3.0f];
  [cameraRollButton.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];

  [takePhotoButton.layer setMasksToBounds:YES];
  [takePhotoButton.layer setBorderWidth:0.5f];
  [takePhotoButton.layer setCornerRadius:3.0f];
  [takePhotoButton.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
}

- (void)dealloc {
  [self unregisterForKeyboardNotifications];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - Action Events

- (void)getStartedButtonTapped:(id)sender {
  SignUpConfirmViewController *confirmVC = [[SignUpConfirmViewController alloc]
      initWithNibName:@"SignUpConfirmViewController"
               bundle:[NSBundle mainBundle]];

  if ([self formIsValid]) {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading...";
    [hud show:YES];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:usernameTextField.text forKey:@"User[username]"];
    [parameters setObject:emailTextField.text forKey:@"User[email]"];
    [parameters setObject:passwordTextField.text forKey:@"User[password]"];
    [parameters setObject:@"iOSApp" forKey:@"User[source]"];

    BOOL hasImage = NO;
    NSData *imageData;
    if (profileThumbnailView.image) {
      imageData = UIImagePNGRepresentation(profileThumbnailView.image);
      [parameters setObject:imageData forKey:@"User[profileImage]"];
      hasImage = YES;
    }

    SnapprintsClient *client = [SnapprintsClient sharedSnapprintsClient];

    NSMutableURLRequest *request = [client
        multipartFormRequestWithMethod:@"POST"
                                  path:@"/users/register.json"
                            parameters:parameters
             constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                 if (hasImage) {
                   [formData appendPartWithFileData:imageData
                                               name:@"User[profileImage]"
                                           fileName:@"temp.png"
                                           mimeType:@"image/png"];
                 }
             }];

    AFHTTPRequestOperation *operation =
        [[AFHTTPRequestOperation alloc] initWithRequest:request];

    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *
                                                   operation,
                                               id responseObject) {
        NSLog(@"RESPONSE:%@", responseObject);
        NSDictionary *dict =
            [NSJSONSerialization JSONObjectWithData:responseObject
                                            options:0
                                              error:nil];

        NSString *status =
            [[dict objectForKey:@"result"] objectForKey:@"status"];
        if ([status isEqualToString:@"failed"]) {
          NSDictionary *messageDict =
              [[dict objectForKey:@"result"] objectForKey:@"message"];
          NSString *messageString = @"";

          if ([messageDict objectForKey:@"username"] &&
              ![[messageDict objectForKey:@"username"]
                  isKindOfClass:[NSNull class]]) {
            messageString =
                [[messageDict objectForKey:@"username"] objectAtIndex:0];
            [usernameTextField becomeFirstResponder];
          } else if ([[messageDict objectForKey:@"email"] count] > 0) {
            messageString =
                [[messageDict objectForKey:@"email"] objectAtIndex:0];
            [emailTextField becomeFirstResponder];
          }

          [TSMessage setDefaultViewController:self.navigationController];
          [TSMessage showNotificationWithTitle:@"Sign Up Error"
                                      subtitle:messageString
                                          type:TSMessageNotificationTypeError];
          [hud removeFromSuperview];
          //                errorMessageLabel.hidden = YES;
          //                errorMessageLabel.text = messageString;
        } else {
          [hud removeFromSuperview];
          //                errorMessageLabel.hidden = YES;
          [self.navigationController pushViewController:confirmVC animated:YES];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([operation.response statusCode] == 403) {
          //                NSLog(@"Upload Failed");
          [hud removeFromSuperview];
          return;
        }
    }];

    [operation start];
  }
}

- (IBAction)tappedTerms:(id)sender {

  UIButton *button = (UIButton *)sender;
  button.selected = !button.selected;
  UIImage *image = (button.selected) ? [UIImage imageNamed:@"checked"]
                                     : [UIImage imageNamed:@"unchecked"];
  [button setImage:image forState:UIControlStateNormal];
}

- (void)tappedTermsDetail:(id)sender {

  WebViewController *webVC =
      [[WebViewController alloc] initWithNibName:@"WebViewController"
                                          bundle:[NSBundle mainBundle]];
  [self.navigationController pushViewController:webVC animated:YES];
}

- (IBAction)takePhoto:(UIButton *)sender {
  UIImagePickerController *imagePickerVC =
      [[UIImagePickerController alloc] init];
  if (sender.tag == 0) {
    imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePickerVC animated:YES completion:nil];

  } else if (sender.tag == 1) {
    if ([UIImagePickerController
            isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
      imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
      [self presentViewController:imagePickerVC animated:YES completion:nil];
    } else {
      UIAlertView *alertView = [[UIAlertView alloc]
              initWithTitle:@""
                    message:@"Your device does not have a camera"
                   delegate:nil
          cancelButtonTitle:nil
          otherButtonTitles:@"OK", nil];
      [alertView show];
    }
  } else {
    return;
  }

  imagePickerVC.delegate = (id)self;

  //[self presentViewController:imagePickerVC animated:YES completion:nil];
}

- (void)displaySourceActionSheet:(id)sender {
  UIActionSheet *actionSheet =
      [[UIActionSheet alloc] initWithTitle:@"Select Photo Source"
                                  delegate:self
                         cancelButtonTitle:@"Cancel"
                    destructiveButtonTitle:nil
                         otherButtonTitles:@"Camera Roll", @"Take Photo", nil];
  [actionSheet showInView:self.view];
}

#pragma mark - Custom Methods

/*
 Function: termsText
 Decription: Displays text for label of 'Terms of Services'.
 Return: void
 */
- (void)termsText {

  NSString *termsText = @"Terms of Services & Privacy Policy";
  NSString *text = [NSString stringWithFormat:@"I agree to the %@", termsText];
  if ([_lblTerms respondsToSelector:@selector(setAttributedText:)]) {
    NSDictionary *attribs = @{
      NSForegroundColorAttributeName : self.lblTerms.textColor,
      NSFontAttributeName : self.lblTerms.font
    };
    NSMutableAttributedString *attributedText =
        [[NSMutableAttributedString alloc] initWithString:text
                                               attributes:attribs];
    UIColor *grayColor = UIColorFromRGB(COLOR_LIGHT_BLUE);
    NSRange redTextRange = [text rangeOfString:termsText];
    [attributedText setAttributes:@{
      NSForegroundColorAttributeName : grayColor,
      NSUnderlineStyleAttributeName : [NSNumber numberWithInt:1]
    } range:redTextRange];
    self.lblTerms.attributedText = attributedText;
  }
}

- (UITextField *)styleTextField:(UITextField *)textField {
  textField.layer.borderColor = [[UIColor whiteColor] CGColor];
  textField.backgroundColor = [UIColor colorWithRed:230.0f / 255.0f
                                              green:230.0f / 255.0f
                                               blue:230.0f / 255.0f
                                              alpha:1.0];
  // textField.layer.borderWidth = 0.5f;
  textField.layer.cornerRadius = 1.0f;
  [textField setValue:[UIColor grayColor]
           forKeyPath:@"_placeholderLabel.textColor"];
  [textField setFont:[UIFont fontWithName:kAppSupportedFontLight size:12.0]];

  UIView *leftPadding = [[UIView alloc]
      initWithFrame:CGRectMake(0, 0, 10, textField.frame.size.height)];
  textField.leftView = leftPadding;
  textField.leftViewMode = UITextFieldViewModeAlways;
  return textField;
}

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
 Function: formIsValid
 Decription: Validation method for all fileds in Add event.
 Return: BOOL
 */
- (BOOL)formIsValid {
  NSString *strTitle = nil;
  BOOL isValid = YES;
  if ([usernameTextField.text length] < 6 ||
      [usernameTextField.text length] > 20) {

    strTitle = @"Please enter valid username between 6 to 20 character length.";
    isValid = NO;
    usernameTextField.layer.borderColor = [[UIColor redColor] CGColor];
    emailTextField.layer.borderColor = [[UIColor whiteColor] CGColor];
    passwordTextField.layer.borderColor = [[UIColor whiteColor] CGColor];
    confirmPasswordTextField.layer.borderColor = [[UIColor whiteColor] CGColor];
    // _termsDetailButton.titleLabel.textColor =[UIColor grayColor];

  } else if (![self validateEmail:emailTextField.text]) {

    strTitle = @"Please enter valid email address.";
    isValid = NO;
    emailTextField.layer.borderColor = [[UIColor redColor] CGColor];
    usernameTextField.layer.borderColor = [[UIColor whiteColor] CGColor];
    passwordTextField.layer.borderColor = [[UIColor whiteColor] CGColor];
    confirmPasswordTextField.layer.borderColor = [[UIColor whiteColor] CGColor];
    // _termsDetailButton.titleLabel.textColor =[UIColor grayColor];

  } else if ([passwordTextField.text length] == 0 ||
             [confirmPasswordTextField.text length] == 0) {

    strTitle = @"Please enter same password for both text fields.";
    isValid = NO;
    passwordTextField.layer.borderColor = [[UIColor redColor] CGColor];
    confirmPasswordTextField.layer.borderColor = [[UIColor redColor] CGColor];
    emailTextField.layer.borderColor = [[UIColor whiteColor] CGColor];
    usernameTextField.layer.borderColor = [[UIColor whiteColor] CGColor];
    // _termsDetailButton.titleLabel.textColor =[UIColor grayColor];

  } else if ([passwordTextField.text length] > 0 &&
             [confirmPasswordTextField.text length] > 0) {
    if (!([passwordTextField.text length] >= 6 &&
          [passwordTextField.text length] <= 12)) {
      strTitle =
          @"Please enter valid password between 6 to 12 character length.";
      isValid = NO;
      passwordTextField.layer.borderColor = [[UIColor redColor] CGColor];
      confirmPasswordTextField.layer.borderColor = [[UIColor redColor] CGColor];
      emailTextField.layer.borderColor = [[UIColor whiteColor] CGColor];
      usernameTextField.layer.borderColor = [[UIColor whiteColor] CGColor];
    } else if (!([passwordTextField.text length] ==
                 [confirmPasswordTextField.text length]) ||
               !([passwordTextField.text
                   isEqualToString:confirmPasswordTextField.text])) {

      strTitle = @"Please enter same password for both text fields.";
      isValid = NO;
      passwordTextField.layer.borderColor = [[UIColor redColor] CGColor];
      confirmPasswordTextField.layer.borderColor = [[UIColor redColor] CGColor];
      emailTextField.layer.borderColor = [[UIColor whiteColor] CGColor];
      usernameTextField.layer.borderColor = [[UIColor whiteColor] CGColor];
      // _termsDetailButton.titleLabel.textColor =[UIColor grayColor];

    } else if (!_termsButton.selected) {
      usernameTextField.layer.borderColor = [[UIColor whiteColor] CGColor];
      emailTextField.layer.borderColor = [[UIColor whiteColor] CGColor];
      passwordTextField.layer.borderColor = [[UIColor whiteColor] CGColor];
      confirmPasswordTextField.layer.borderColor =
          [[UIColor whiteColor] CGColor];
      // _termsDetailButton.titleLabel.textColor =[UIColor redColor];
      strTitle = @"In order to use SNAPprints, You must agree to our Terms of "
          @"Services and Privacy Policy.";
      isValid = NO;
    }
  }
  if (!isValid) {

    [TSMessage setDefaultViewController:self.navigationController];
    [TSMessage showNotificationWithTitle:@"SignUp"
                                subtitle:strTitle
                                    type:TSMessageNotificationTypeError];

  } else {
    // _termsDetailButton.titleLabel.textColor =[UIColor grayColor];
    isValid = YES;
  }
  return isValid;
}

- (void)setTitle:(NSString *)title {
  [super setTitle:title];
  UILabel *titleView = (UILabel *)self.navigationItem.titleView;
  if (!titleView) {
    titleView = [[UILabel alloc] initWithFrame:CGRectZero];
    titleView.backgroundColor = [UIColor clearColor];
    titleView.font = [UIFont boldSystemFontOfSize:20.0];
    titleView.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];

    titleView.textColor = [UIColor whiteColor]; // Change to desired color
      titleView.font = [UIFont fontWithName:kAppSupportedFontBold size:16.0f];
    self.navigationItem.titleView = titleView;
  }
  titleView.text = title;
  [titleView sizeToFit];
}

#pragma mark - UIActionSheetDelegate methods
- (void)actionSheet:(UIActionSheet *)actionSheet
    clickedButtonAtIndex:(NSInteger)buttonIndex {
  UIButton *button = [[UIButton alloc] init];
  button.tag = buttonIndex;

  [self takePhoto:button];
}

#pragma mark - UIImagePickerViewControllerDelegate methods
- (void)imagePickerController:(UIImagePickerController *)picker
    didFinishPickingMediaWithInfo:(NSDictionary *)info {
  UIImage *originalImage =
      [info objectForKey:UIImagePickerControllerOriginalImage];
  float y = originalImage.size.height / 2.0 - originalImage.size.width / 2.0;
  CGRect cropRect =
      CGRectMake(0, y, originalImage.size.width, originalImage.size.width);
  UIImage *croppedImage = [originalImage crop:cropRect];
  UIImage *resizedImage =
      [croppedImage imageCroppedToFitSize:CGSizeMake(100, 100)];
  profileThumbnailView.image = resizedImage;

  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  if ([[defaults valueForKeyPath:@"savephoto"] isEqualToString:@"1"] &&
      ![info valueForKey:@"UIImagePickerControllerReferenceURL"]) {

    // UIImageWriteToSavedPhotosAlbum(originalImage, nil, nil, nil);

    [library saveImage:originalImage
        toAlbum:@"SNAPprints"
        completion:^(NSURL *assetURL, NSError *error) {

            NSLog(@"Saved Successfully url = %@ error = %@",
                  [assetURL absoluteString], [error description]);
        }
        failure:^(NSError *error) {
            NSLog(@"Saved error = %@", [error description]);
        }];
  }
  [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate methods
- (BOOL)textField:(UITextField *)textField
    shouldChangeCharactersInRange:(NSRange)range
                replacementString:(NSString *)string {
  NSString *currentString =
      [textField.text stringByReplacingCharactersInRange:range
                                              withString:string];
  // if(textField.tag == 22)
  // if(!(textField.tag == TEXTFIELD_TAG_EMAIL))
  if (textField.tag == TEXTFIELD_TAG_PASSWORD ||
      textField.tag == TEXTFIELD_TAG_CONFIRM_PASSWORD) {
    NSCharacterSet *nonNumberSet =
        [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    if ([currentString rangeOfCharacterFromSet:nonNumberSet].location !=
        NSNotFound) {
      return NO;
    }
  }
  if (textField.tag == TEXTFIELD_TAG_USERNAME) {
    NSCharacterSet *nonNumberSet =
        [[NSCharacterSet characterSetWithCharactersInString:
                             ACCEPTABLE_CHAR_USERNAME] invertedSet];
    if ([currentString rangeOfCharacterFromSet:nonNumberSet].location !=
        NSNotFound) {
      return NO;
    }
  }

  return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  //    [self formIsValid];
  [textField resignFirstResponder];
  return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
  activeTextField = confirmPasswordTextField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
  activeTextField = nil;
}

#pragma mark - Event of keyboard relative methods
- (void)registerForKeyboardNotifications {
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(keyboardWillShown:)
             name:UIKeyboardWillShowNotification
           object:nil];

  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(keyboardWillHide:)
             name:UIKeyboardWillHideNotification
           object:nil];
}

- (void)unregisterForKeyboardNotifications {
  [[NSNotificationCenter defaultCenter]
      removeObserver:self
                name:UIKeyboardWillShowNotification
              object:nil];
  // unregister for keyboard notifications while not visible.
  [[NSNotificationCenter defaultCenter]
      removeObserver:self
                name:UIKeyboardWillHideNotification
              object:nil];
}

#pragma mark - Keyboard Delegate

- (void)keyboardWillShown:(NSNotification *)aNotification {
  NSDictionary *info = [aNotification userInfo];
  CGSize kbSize =
      [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

  CGRect frame = _scrollView.frame; // self.view.frame;

  if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
    frame.size.height -= kbSize.height;

  } else {
    frame.size.height -= kbSize.width;
  }

  CGPoint fOrigin = activeTextField.frame.origin;
  fOrigin.y -= _scrollView.contentOffset.y;
  fOrigin.y += activeTextField.frame.size.height;
  if (!CGRectContainsPoint(frame, fOrigin)) {
    CGPoint scrollPoint =
        CGPointMake(0.0, activeTextField.frame.origin.y - kbSize.height +
                             activeTextField.frame.size.height + 30);
    [_scrollView setContentOffset:scrollPoint animated:YES];
  }
}

- (void)keyboardWillHide:(NSNotification *)notification {
  [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

#pragma mark - UINavigation controller delegate

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {

  [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault
                                              animated:NO];
}
@end
