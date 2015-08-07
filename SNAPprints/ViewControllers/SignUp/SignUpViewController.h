//
//  SignUpViewController.h
//  SNAPprints
//
//  Created by Etay Luz on 9/16/13.
//  Copyright (c) 2013 Etay Luz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"

@interface SignUpViewController
    : UIViewController <UIImagePickerControllerDelegate, UITextFieldDelegate,
                        UIActionSheetDelegate> {

  MBProgressHUD *hud;
  ALAssetsLibrary *library;
}
@property(nonatomic, retain) IBOutlet UIButton *btnGetStarted;
@property(nonatomic, retain) IBOutlet UILabel *lblCreateAccount;
@property(nonatomic, retain) IBOutlet UITextField *usernameTextField;
@property(nonatomic, retain) IBOutlet UITextField *emailTextField;
@property(nonatomic, retain) IBOutlet UITextField *passwordTextField;
@property(nonatomic, retain) IBOutlet UITextField *confirmPasswordTextField;

@property(nonatomic, retain) IBOutlet UIButton *cameraRollButton;
@property(nonatomic, retain) IBOutlet UIButton *takePhotoButton;
@property(nonatomic, retain) IBOutlet UIImageView *profileThumbnailView;

@property(nonatomic, retain) IBOutlet UIButton *getStartedButton;
@property(nonatomic, retain) IBOutlet UILabel *lblTerms;

@property(nonatomic, retain) IBOutlet UIButton *termsButton;
@property(nonatomic, retain) IBOutlet UIButton *termsDetailButton;

- (IBAction)getStartedButtonTapped:(id)sender;
- (IBAction)tappedTerms:(id)sender;
- (IBAction)tappedTermsDetail:(id)sender;

@end
