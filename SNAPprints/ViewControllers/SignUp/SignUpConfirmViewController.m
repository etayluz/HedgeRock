//
//  SignUpConfirmViewController.m
//  SNAPprints
//
//  Created by Etay Luz on 9/16/13.
//  Copyright (c) 2013 Etay Luz. All rights reserved.
//

#import "SignUpConfirmViewController.h"

@interface SignUpConfirmViewController ()

@end

@implementation SignUpConfirmViewController

@synthesize doneButton;

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}
#pragma mark - View Life cycle

- (void)viewDidLoad {
  [super viewDidLoad];

  //[self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage
  //imageNamed:@"sign-up-background"]]];
  doneButton.layer.cornerRadius = 5.0f;
    UILabel *lable = [[UILabel alloc] init];
    lable.frame = self.navigationController.navigationBar.frame;
    lable.numberOfLines = 2;
    lable.text = @"Thank you";
    [lable sizeToFit];
    lable.textColor = [UIColor grayColor];
    lable.font = [UIFont fontWithName:kAppSupportedFontBold size:16.0f];
    self.navigationItem.titleView = lable;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark IBAction Methods
- (void)doneButtonTapped:(id)sender {
  [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
