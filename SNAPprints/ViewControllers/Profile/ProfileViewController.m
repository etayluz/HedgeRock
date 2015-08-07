//
//  ProfileViewController.m
//  SNAPprints
//
//  Created by Etay Luz on 3/23/14.
//  Copyright (c) 2014 Etay Luz. All rights reserved.
//

#import "ProfileViewController.h"
#import "AFHTTPRequestOperation.h"
#import "TSMessage.h"
#import "MFSideMenu.h"
#import "UIImage+CFT.h"
#import "UIImage+ProportionalFill.h"
#import "UIImageView+AFNetworking.h"
#import "ConstantFlags.h"
#import "FirstScreenViewController.h"
#define ACCEPTABLE_CHARECTERS                                                  \
@" ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
#define ACCEPTABLE_CHARECTERS_FOR_NAME                                               \
@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'"

#define TEXTFIELD_TAG_USERNAME 100
#define TEXTFIELD_TAG_FNAME 101
#define TEXTFIELD_TAG_LNAME 102
#define TEXTFIELD_TAG_NEW_PASSWORD 103
#define TEXTFIELD_TAG_CONFIRM_PASSWORD 104

@interface ProfileViewController () {
    NSMutableDictionary *pwdDict;
}
@end

@implementation ProfileViewController

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
    _library = [[ALAssetsLibrary alloc] init];
    default1 = [NSUserDefaults standardUserDefaults];
    self.title = @"";
    isImagePicked = NO;
    
//    UIImageView *headerLogoView =
//    [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"new-logo"]];
//    headerLogoView.frame =
//    CGRectMake(116.0f, 5.0f, headerLogoView.frame.size.width,
//               headerLogoView.frame.size.height);
//    [self.navigationController.navigationBar addSubview:headerLogoView];
   
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
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.bounds = CGRectMake(0, 0, 35, 32);
    [btn setImage:[UIImage imageNamed:@"logout-btn"]
         forState:UIControlStateNormal];
    [btn addTarget:self
            action:@selector(btnLogoutClicked:)
  forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btnLogout = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = btnLogout;
    
    UILabel *lable = [[UILabel alloc] init];
    lable.frame = self.navigationController.navigationBar.frame;
    lable.numberOfLines = 2;
    lable.text = @"My Profile";
    [lable sizeToFit];
    lable.textColor = [UIColor grayColor];
    lable.font = [UIFont fontWithName:kAppSupportedFontBold size:16.0f];
    self.navigationItem.titleView = lable;
    
    [self.navigationController.navigationBar
     setTintColor:UIColorFromRGB(COLOR_LIGHT_BLUE)];
    
    self.tableView.tableHeaderView = _headerView;
    self.tableView.tableFooterView = _footerView;
    [_tableView registerClass:[UITableViewCell class]
       forCellReuseIdentifier:@"CellIdentifier"];
    [self setProfileImage];
    CALayer *l = [_btnSaveProfile layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:3.0];
    _lblUploadProfile.font = [UIFont fontWithName:kAppSupportedFontNormal size:13.0f];
    _btnSaveProfile.titleLabel.font = [UIFont fontWithName:kAppSupportedFontNormal size:20.0f];
    pwdDict = [[NSMutableDictionary alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom Methods

- (void)setProfileImage {
    
    NSString *profileURLString = @"";
    NSString *profileImage =
    [[NSUserDefaults standardUserDefaults] objectForKey:@"profile_image"];
    
    if (profileImage && ![profileImage isEqualToString:@""]) {
        
        profileURLString =
        [NSString stringWithFormat:@"%@uploads/profiles/%@",
         [Constants retriveServerURL], profileImage];
        
    } else {
        NSString *facebook_id =
        [[NSUserDefaults standardUserDefaults] objectForKey:@"facebook_id"];
        if (facebook_id) {
            profileURLString = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=320&height=320",facebook_id];
            
        } else {
            
            profileImage = @"";
        }
    }
    CALayer *l = [_imgProfile layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:34.0];
    [l setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [l setBorderWidth:0.5f];
    
    NSURLRequest *req =
    [NSURLRequest requestWithURL:[NSURL URLWithString:profileURLString]];
    BOOL valid = [NSURLConnection canHandleRequest:req];
    if (valid) {
        [_activityIndicator startAnimating];
        AFImageRequestOperation *operation = [AFImageRequestOperation
                                              imageRequestOperationWithRequest:req
                                              imageProcessingBlock:nil
                                              success:^(NSURLRequest *request, NSHTTPURLResponse *response,
                                                        UIImage *image) {
                                                  dispatch_async(
                                                                 dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                                                                 ^{
                                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                                         if (image) {
                                                                             [_activityIndicator stopAnimating];
                                                                             _imgProfile.image = image;
                                                                         }
                                                                     });
                                                                 });
                                              }
                                              failure:^(NSURLRequest *request, NSHTTPURLResponse *response,
                                                        NSError *error) {
                                                  [_imgProfile setImage:[UIImage imageNamed:@"default-human-img"]];
                                              }];
        [operation start];
    }
}

- (void)toggleLeft:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{}];
}

- (NSString *)valueForCellAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell =
    (UITableViewCell *)[_tableView cellForRowAtIndexPath:indexPath];
    NSArray *subviews = [cell.contentView subviews];
    
    for (UIView *view in subviews) {
        if ([view isKindOfClass:[UITextField class]]) {
            UITextField *textField = (UITextField *)view;
            return textField.text;
        }
    }
    return @"";
}
- (int)tagForIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return TEXTFIELD_TAG_USERNAME;
        } else if (indexPath.row == 1) {
            return TEXTFIELD_TAG_FNAME;
        } else if (indexPath.row == 2) {
            return TEXTFIELD_TAG_LNAME;
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            return TEXTFIELD_TAG_NEW_PASSWORD;
        } else {
            return TEXTFIELD_TAG_CONFIRM_PASSWORD;
        }
    }
    return 1;
}

- (BOOL)formIsValid {
    BOOL isValid = YES;
    NSString *strMessage = nil;
    NSString *username = [self
                          valueForCellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    NSString *password = [self
                          valueForCellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    NSString *confirm_pass = [self
                              valueForCellAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
    
    if (username.length >= 6 && username.length <= 20) {
        if ([password isEqualToString:@""] && [confirm_pass isEqualToString:@""])
            isValid = YES;
        else {
            if ([password isEqualToString:@""] &&
                ![confirm_pass isEqualToString:@""]) {
                strMessage = @"Please enter same password for both text fields.";
                isValid = NO;
            } else if (![password isEqualToString:@""] &&
                       [confirm_pass isEqualToString:@""]) {
                strMessage = @"Please enter same password for both text fields.";
                isValid = NO;
            } else if (![password isEqualToString:@""] &&
                       ![confirm_pass isEqualToString:@""]) {
                if ((password.length >= 6 && password.length <= 12)) {
                    if (![password isEqualToString:confirm_pass]) {
                        strMessage = @"Please enter same password for both text fields.";
                        isValid = NO;
                    }
                } else {
                    strMessage =
                    @"Please enter valid password between 6 to 12 character length.";
                    isValid = NO;
                }
            }
        }
    } else {
        isValid = NO;
        strMessage =
        @"Please enter valid username between 6 to 20 character length.";
    }
    
    if (!isValid) {
        [TSMessage setDefaultViewController:self.navigationController];
        [TSMessage showNotificationWithTitle:@"Profile"
                                    subtitle:strMessage
                                        type:TSMessageNotificationTypeError];
    }
    return isValid;
}

#pragma mark - Action Events

- (IBAction)btnTakePhoto:(id)sender {
    
    UIActionSheet *actionSheet =
    [[UIActionSheet alloc] initWithTitle:@"Select Photo Source"
                                delegate:self
                       cancelButtonTitle:@"Cancel"
                  destructiveButtonTitle:nil
                       otherButtonTitles:@"Camera Roll", @"Take Photo", nil];
    [actionSheet showInView:self.view];
}
- (IBAction)btnSaveProfile:(id)sender {
    [self.view endEditing:TRUE];
    
    if ([self formIsValid]) {
        [self saveProfile:nil];
    }
}

- (IBAction)btnLogoutClicked:(id)sender {
    UIAlertView *alert =
    [[UIAlertView alloc] initWithTitle:@"SNAPprints"
                               message:@"Are you sure you want to log out?"
                              delegate:self
                     cancelButtonTitle:@"Yes"
                     otherButtonTitles:@"No", nil];
    [alert show];
    [alert setTag:2001];
}

- (IBAction)btnSavePhotoToCameraRoll:(id)sender {
    
    UISwitch *switchSavePhoto = (UISwitch *)sender;
    // NSUserDefaults *newDefaults = [NSUserDefaults standardUserDefaults];
    if (switchSavePhoto.isOn) {
        
        [default1 setObject:@"1" forKey:@"savephoto"];
        
    } else {
        
        [default1 setObject:@"0" forKey:@"savephoto"];
    }
    [default1 synchronize];
}

- (IBAction)takePhoto:(UIButton *)sender {
    UIImagePickerController *imagePickerVC =
    [[UIImagePickerController alloc] init];
    [imagePickerVC setEditing:YES animated:YES];
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
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        return 70;
    }
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return 4;
    else if (section == 1)
        return 2;
    else
        return 1;
}

#pragma mark - UITableViewDelegate Methods

- (NSString *)getValueForIndexPath:(NSIndexPath *)indexPath {
    NSString *value = @"";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            NSString *strNewPwd = [pwdDict objectForKey:@"Username"];
            if (strNewPwd == nil)
                value = [defaults objectForKey:@"username"];
            else
                value = strNewPwd;
        } else if (indexPath.row == 1) {
            NSString *strNewPwd = [pwdDict objectForKey:@"Fname"];
            if (strNewPwd == nil)
                value = [defaults objectForKey:@"fname"];
            else
                value = strNewPwd;
        } else if (indexPath.row == 2) {
            NSString *strNewPwd = [pwdDict objectForKey:@"Lname"];
            if (strNewPwd == nil)
                value = [defaults objectForKey:@"lname"];
            else
                value = strNewPwd;
            
        } else if (indexPath.row == 3) {
            value = [defaults objectForKey:@"email"];
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            NSString *strNewPwd = [pwdDict objectForKey:@"New_Password"];
            if ([strNewPwd isEqualToString:@""] || strNewPwd == nil)
                value = @"";
            else
                value = strNewPwd;
        } else if (indexPath.row == 1) {
            NSString *strNewPwd = [pwdDict objectForKey:@"Confirm_Password"];
            if ([strNewPwd isEqualToString:@""] || strNewPwd == nil)
                value = @"";
            else
                value = strNewPwd;
        } else {
        }
    }
    return value;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell =
    [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    if (cell != nil) {
        NSArray *subviews = [cell.contentView subviews];
        for (UIView *view in subviews) {
            [view removeFromSuperview];
        }
    }
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Username";
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"First Name";
        } else if (indexPath.row == 2) {
            cell.textLabel.text = @"Last Name";
        } else if (indexPath.row == 3) {
            cell.textLabel.text = @"Email";
        }
    } else if (indexPath.section == 1) {
        
        if (indexPath.row == 0) {
            cell.textLabel.text = @"New Password";
        } else {
            cell.textLabel.text = @"Confirm New Password";
        }
        
    } else if (indexPath.section == 2) {
        
        cell.textLabel.text = @"Save Photo to Camera Roll";
    }
    cell.textLabel.textColor = [UIColor grayColor];
    [cell.textLabel setFont:[UIFont fontWithName:kAppSupportedFontNormal size:15.f]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.section == 0 ||
        indexPath.section == 1) { // Add textfields for non profile image cells
        
        UITextField *textField = [[UITextField alloc]
                                  initWithFrame:CGRectMake(170, 0, 145, cell.frame.size.height)];
        textField.delegate = self;
        textField.tag = [self tagForIndexPath:indexPath];
        
        [textField setFont:[UIFont fontWithName:kAppSupportedFontNormal size:15.f]];
        textField.textAlignment = NSTextAlignmentLeft;
        textField.text = [self getValueForIndexPath:indexPath];
        if (indexPath.section == 0 && (indexPath.row == 3)) {
            
            textField.userInteractionEnabled = NO;
        } else if (indexPath.section == 1) {
            textField.spellCheckingType = UITextSpellCheckingTypeNo;
            textField.autocorrectionType = UITextAutocorrectionTypeNo;
            textField.secureTextEntry = YES;
        }
        
        [cell.contentView addSubview:textField];
    } else {
        
        UISwitch *switchPhoto =
        [[UISwitch alloc] initWithFrame:CGRectMake(250.0, 18.0, 51.0, 31.0)];
        [switchPhoto addTarget:self
                        action:@selector(btnSavePhotoToCameraRoll:)
              forControlEvents:UIControlEventValueChanged];
        [cell.contentView addSubview:switchPhoto];
        if ([[default1 valueForKey:@"savephoto"] isEqualToString:@"1"]) {
            
            switchPhoto.on = YES;
        } else {
            
            switchPhoto.on = NO;
        }
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView
viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    view.backgroundColor = UIColorFromRGB(TABLE_SECTION_HEADER_BACKGROUND_COLOR);
    
    NSString *title = @"PROFILE DETAILS";
    
    if (section == 1) {
        title = @"UPDATE PASSWORD";
    } else if (section == 2) {
        
        title = @"SETTINGS";
    }
    UILabel *label = [[UILabel alloc]
                      initWithFrame:CGRectMake(0, 3, self.view.frame.size.width, 20)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = title;
    [label setFont:[UIFont fontWithName:kAppSupportedFontNormal size:14]];
    label.textColor = [UIColor whiteColor];
    [label
     setBackgroundColor:UIColorFromRGB(TABLE_SECTION_HEADER_BACKGROUND_COLOR)];
    
    [view addSubview:label];
    
    return view;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex {
    UIButton *button = [[UIButton alloc] init];
    button.tag = buttonIndex;
    
    [self takePhoto:button];
}

#pragma mark - UIImagePickerViewControllerDelegate methods
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    isImagePicked = YES;
    UIImage *originalImage =
    [info objectForKey:UIImagePickerControllerOriginalImage];
    float y = originalImage.size.height / 2.0 - originalImage.size.width / 2.0;
    CGRect cropRect =
    CGRectMake(0, y, originalImage.size.width, originalImage.size.width);
    UIImage *croppedImage = [originalImage crop:cropRect];
    UIImage *resizedImage =
    [croppedImage imageCroppedToFitSize:CGSizeMake(100, 100)];
    _imgProfile.image = resizedImage;
    [_activityIndicator stopAnimating];
    if ([[default1 valueForKey:@"savephoto"] isEqualToString:@"1"] &&
        ![info valueForKey:@"UIImagePickerControllerReferenceURL"]) {
        
        // UIImageWriteToSavedPhotosAlbum(originalImage, nil, nil, nil);
        
        [_library saveImage:originalImage
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
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self.tableView setContentInset:UIEdgeInsetsMake(-64, 0, 270, 0)];
    [self.tableView setScrollIndicatorInsets:UIEdgeInsetsMake(64, 0, 270, 0)];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.tableView setScrollIndicatorInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    if (textField.tag == TEXTFIELD_TAG_NEW_PASSWORD) {
        if (![textField.text isEqualToString:@""])
            [pwdDict setObject:textField.text forKey:@"New_Password"];
        else
            [pwdDict setObject:@"" forKey:@"New_Password"];
    } else if (textField.tag == TEXTFIELD_TAG_CONFIRM_PASSWORD) {
        if (![textField.text isEqualToString:@""])
            [pwdDict setObject:textField.text forKey:@"Confirm_Password"];
        else
            [pwdDict setObject:@"" forKey:@"Confirm_Password"];
    } else if (textField.tag == TEXTFIELD_TAG_FNAME) {
        if (![textField.text isEqualToString:@""])
            [pwdDict setObject:textField.text forKey:@"Fname"];
        else
            [pwdDict setObject:@"" forKey:@"Fname"];
    } else if (textField.tag == TEXTFIELD_TAG_LNAME) {
        if (![textField.text isEqualToString:@""])
            [pwdDict setObject:textField.text forKey:@"Lname"];
        else
            [pwdDict setObject:@"" forKey:@"Lname"];
    } else if (textField.tag == TEXTFIELD_TAG_USERNAME) {
        if (![textField.text isEqualToString:@""])
            [pwdDict setObject:textField.text forKey:@"Username"];
        else
            [pwdDict setObject:@"" forKey:@"Username"];
    }
}

- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string {
    NSString *currentString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (textField.tag == TEXTFIELD_TAG_FNAME ||
        textField.tag == TEXTFIELD_TAG_LNAME) {
        
        if ([textField.text length] >= 20 && range.length == 0)
            return NO;
        
        NSCharacterSet *nonNumberSet =
        [[NSCharacterSet characterSetWithCharactersInString:
          ACCEPTABLE_CHARECTERS_FOR_NAME] invertedSet];
        if ([currentString rangeOfCharacterFromSet:nonNumberSet].location !=
            NSNotFound) {
            return NO;
        }
        
        if(range.location == 0)
        {
            if([string isEqualToString:@"'"])
                return NO;
        }
        else if([string isEqualToString:@"'"] && [textField.text containsString:@"'"])
        {
            return NO;

        }
        
    } else if (textField.tag == TEXTFIELD_TAG_USERNAME) {
        NSCharacterSet *nonNumberSet =
        [[NSCharacterSet characterSetWithCharactersInString:
          ACCEPTABLE_CHAR_USERNAME] invertedSet];
        if ([currentString rangeOfCharacterFromSet:nonNumberSet].location !=
            NSNotFound) {
            return NO;
        }
    } else {
        NSCharacterSet *nonNumberSet =
        [[NSCharacterSet alphanumericCharacterSet] invertedSet];
        if ([currentString rangeOfCharacterFromSet:nonNumberSet].location !=
            NSNotFound) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - API Call

- (void)saveProfile:(id)sender {
    if (!_hud) {
        
        _hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    }
    
    [self.view addSubview:_hud];
    _hud.labelText = @"Loading...";
    [_hud show:YES];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [defaults objectForKey:@"token"];
    NSString *user_id = [defaults objectForKey:@"user_id"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:token forKey:@"token"];
    [params setObject:user_id forKey:@"user_id"];
    
    NSString *fname = [self
                       valueForCellAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    [params setObject:fname forKey:@"User[fname]"];
    
    NSString *lname = [self
                       valueForCellAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    [params setObject:lname forKey:@"User[lname]"];
    
    NSString *username = [self
                          valueForCellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [params setObject:username forKey:@"User[uname]"];
    
    NSString *password = [self
                          valueForCellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    NSString *confirm_pass = [self
                              valueForCellAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
    
    if (![password isEqualToString:@""] && ![confirm_pass isEqualToString:@""]) {
        if ([password isEqualToString:confirm_pass]) {
            [params setObject:password forKey:@"User[password]"];
        }
    }
    
    SnapprintsClient *client = [SnapprintsClient sharedSnapprintsClient];
    BOOL hasImage = NO;
    
    NSData *oldImgData =
    UIImageJPEGRepresentation([UIImage imageNamed:@"default-human-img"], 0.5);
    NSData *newImgData = UIImageJPEGRepresentation(_imgProfile.image, 0.5);
    if (isImagePicked) {
        if (_imgProfile.image && newImgData != oldImgData) {
            
            [params setObject:newImgData forKey:@"User[profileImage]"];
            hasImage = YES;
        }
    }
    
    NSMutableURLRequest *request = [client
                                    multipartFormRequestWithMethod:@"POST"
                                    path:@"/users/edit.json"
                                    parameters:params
                                    constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                        if (hasImage) {
                                            
                                            [formData appendPartWithFileData:newImgData
                                                                        name:@"User[profileImage]"
                                                                    fileName:@"temp.png"
                                                                    mimeType:@"image/png"];
                                        }
                                    }];
    
    AFHTTPRequestOperation *operation =
    [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation,
                                               id responseObject) {
        NSLog(@"Profile Update responseObject = %@",responseObject);

        NSError *error;
        id JSON = [NSJSONSerialization JSONObjectWithData:responseObject
                                                  options:0
                                                    error:&error];
        
        NSString *message = [JSON objectForKey:@"message"];
        if ([[JSON objectForKey:@"status"] isEqualToString:@"success"]) {
            
            [defaults setObject:fname forKey:@"fname"];
            [defaults setObject:lname forKey:@"lname"];
            [defaults setObject:username forKey:@"username"];
            
            if ([JSON objectForKey:@"profile_image"]) {
                [defaults setObject:[JSON objectForKey:@"profile_image"]
                             forKey:@"profile_image"];
            }
            
            [defaults synchronize];
            [TSMessage setDefaultViewController:self.navigationController];
            [TSMessage showNotificationWithTitle:@"Successfully Updated Profile"
                                        subtitle:message
                                            type:TSMessageNotificationTypeSuccess];
            [_hud removeFromSuperview];
        } else {
            
            NSString *message = [JSON objectForKey:@"message"];
            [TSMessage setDefaultViewController:self.navigationController];
            [TSMessage showNotificationWithTitle:@"Error Updating Profile"
                                        subtitle:message
                                            type:TSMessageNotificationTypeError];
            [_hud removeFromSuperview];
            if ([message isEqualToString:@"This username already exists."]) {
                UITableViewCell *cell = (UITableViewCell *)[_tableView
                                                            cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0
                                                                                                     inSection:0]];
                UITextField *txtUserName =
                (UITextField *)[cell viewWithTag:TEXTFIELD_TAG_USERNAME];
                txtUserName.text = [defaults objectForKey:@"username"];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [TSMessage setDefaultViewController:self.navigationController];
        [TSMessage showNotificationWithTitle:@"Error Updating Profile"
                                    subtitle:@""
                                        type:TSMessageNotificationTypeError];
        [_hud removeFromSuperview];
    }];
    [operation start];
}

#pragma mark - UIAlertview Delegate
- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 2001) {
        if (buttonIndex == 0) {
            [FBSession.activeSession closeAndClearTokenInformation];
            
            NSDictionary *parameters =
            [NSDictionary dictionaryWithObject:@"mobile" forKey:@"source"];
            
            [[SnapprintsClient sharedSnapprintsClient] postPath:@"/users/logout.json"
                                                     parameters:parameters
                                                        success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                            
                                                            NSString *status = [[responseObject objectForKey:@"result"]
                                                                                objectForKey:@"status"];
                                                            
                                                            if ([status isEqualToString:@"failed"]) {
                                                                
                                                            } else {
                                                                NSUserDefaults *defaults =
                                                                [NSUserDefaults standardUserDefaults];
                                                                [defaults removeObjectForKey:@"user_id"];
                                                                [defaults removeObjectForKey:@"email"];
                                                                [defaults removeObjectForKey:@"facebook_id"];
                                                                [defaults removeObjectForKey:@"facebook_token"];
                                                                [defaults removeObjectForKey:@"profile_image"];
                                                                [defaults removeObjectForKey:@"token"];
                                                                [defaults removeObjectForKey:@"username"];
                                                                
                                                                [defaults removeObjectForKey:@"cat_ID"];
                                                                [defaults removeObjectForKey:@"cat_Name"];
                                                                [defaults removeObjectForKey:@"zipcode"];
                                                                [defaults removeObjectForKey:@"city"];
                                                                [defaults removeObjectForKey:@"eventName"];
                                                                [defaults removeObjectForKey:@"latittude"];
                                                                [defaults removeObjectForKey:@"longitude"];
                                                                [defaults removeObjectForKey:@"distance"];
                                                                
                                                                [defaults synchronize];
                                                                
                                                                FirstScreenViewController *viewController =
                                                                [[FirstScreenViewController alloc]
                                                                 initWithNibName:@"FirstScreenViewController"
                                                                 bundle:[NSBundle mainBundle]];
                                                                
                                                                UINavigationController *navBar = [[UINavigationController alloc]
                                                                                                  initWithRootViewController:viewController];
                                                                
                                                                if ([[[UIDevice currentDevice] systemVersion] floatValue] >=
                                                                    7.0) {
                                                                    navBar.navigationBar.barTintColor =
                                                                    UIColorFromRGB(COLOR_LIGHT_BLUE);
                                                                    [navBar.navigationBar setTintColor:[UIColor whiteColor]];
                                                                    navBar.navigationBar.translucent = NO;
                                                                } else {
                                                                    navBar.navigationBar.tintColor = [UIColor blackColor];
                                                                }
                                                                
                                                                [self.menuContainerViewController
                                                                 presentViewController:navBar
                                                                 animated:YES
                                                                 completion:^{
                                                                     [self.menuContainerViewController
                                                                      toggleLeftSideMenuCompletion:nil];
                                                                 }];
                                                            }
                                                        }
                                                        failure:^(AFHTTPRequestOperation *operation, NSError *error) {}];
        }
    }
}

#pragma mark - UINavigation controller delegate

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault
                                                animated:NO];
}
@end
