//
//  ForgotPasswordViewController.h
//  SNAPprints
//
//  Created by Etay Luz on 2/12/14.
//  Copyright (c) 2014 Etay Luz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForgotPasswordViewController : UIViewController <UITextFieldDelegate>

@property(nonatomic, retain) IBOutlet UITextField *emailTextField;
@property(nonatomic, retain) IBOutlet UILabel *noticeLabel;
@property(nonatomic, retain) IBOutlet UIButton *resetButton;
@property(weak, nonatomic) IBOutlet UILabel *lblTitle;

- (IBAction)resetPressed:(id)sender;

@end
