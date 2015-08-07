//
//  FirstScreenViewController.h
//  SNAPprints
//
//  Created by Etay Luz on 9/16/13.
//  Copyright (c) 2013 Etay Luz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "MBProgressHUD.h"
#import "ConstantFlags.h"
@class FirstScreenViewController;

@protocol FirstScreenViewControllerDelegate <NSObject>

- (void)firstScreenViewController:(FirstScreenViewController *)controller
                         didLogin:(NSString *)status;

@end

@interface FirstScreenViewController : UIViewController <FBLoginViewDelegate> {

  MBProgressHUD *hud;
}
@property(nonatomic, retain) IBOutlet UIButton *createAccountButton;
@property(nonatomic, retain) IBOutlet UIButton *facebookButton;
@property(nonatomic, retain) IBOutlet UIButton *snapprintsButton;
@property(nonatomic, retain) id delegate;

- (IBAction)signupTapped:(id)sender;
- (IBAction)loginSnapprintsButtonPressed:(id)sender;
- (IBAction)facebookButtonTapped:(id)sender;
//- (void)loginFailed;

@end
