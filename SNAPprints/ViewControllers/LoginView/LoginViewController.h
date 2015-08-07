//
//  LoginViewController.h
//  SNAPprints
//
//  Created by Etay Luz on 9/16/13.
//  Copyright (c) 2013 Etay Luz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SideMenuGridViewController.h"
@interface LoginViewController : UIViewController {

  SideMenuGridViewController *sideMenuVC;
  // MFSideMenuContainerViewController *sideMenuContainerVC;
}
@property(strong, nonatomic)
    MFSideMenuContainerViewController *sideMenuContainerVC;
@property(nonatomic, retain) IBOutlet UITextField *usernameTextField;
@property(nonatomic, retain) IBOutlet UITextField *passwordTextField;
@property(nonatomic, retain) IBOutlet UIButton *loginButton;
@property(nonatomic, retain) IBOutlet UIButton *forgotPasswordButton;
@property(nonatomic, retain) IBOutlet UILabel *errorMessage;
@property(weak, nonatomic) IBOutlet UILabel *lblTitle;

- (IBAction)loginButtonPressed:(id)sender;
- (IBAction)forgotPasswordPressed:(id)sender;

@end
