//
//  AddDescriptionViewController.m
//  SNAPprints
//
//  Created by Etay Luz on 1/27/14.
//  Copyright (c) 2014 Etay Luz. All rights reserved.
//

#import "AddDescriptionViewController.h"
#import "TSMessageView.h"

@interface AddDescriptionViewController ()

@property(weak, nonatomic) IBOutlet UILabel *lblTitle;

@end

@implementation AddDescriptionViewController

@synthesize delegate;
@synthesize textView = _textView;
@synthesize defaultText;

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
  self.navigationController.navigationBar.tintColor =
      UIColorFromRGB(COLOR_LIGHT_BLUE);
  UIBarButtonItem *rightBarButton =
      [[UIBarButtonItem alloc] initWithTitle:@"Save"
                                       style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(saveDescription:)];
  self.navigationItem.rightBarButtonItem = rightBarButton;
  [self.navigationItem.rightBarButtonItem
      setTintColor:UIColorFromRGB(COLOR_LIGHT_BLUE)];
    
    UILabel *lable = [[UILabel alloc] init];
    lable.frame = self.navigationController.navigationBar.frame;
    lable.numberOfLines = 2;
    lable.text = @"Add Description";
    [lable sizeToFit];
    lable.textColor = [UIColor grayColor];
    lable.font = [UIFont fontWithName:kAppSupportedFontBold size:16.0f];
    self.navigationItem.titleView = lable;
    
  if (defaultText && ![defaultText isEqualToString:@""]) {
    _textView.text = defaultText;
  }
    _textView.font = [UIFont fontWithName:kAppSupportedFontNormal size:14.0f];
  [_textView becomeFirstResponder];

  [_lblTitle setFont:[UIFont fontWithName:kAppSupportedFontLight size:17.f]];
  // Do any additional setup after loading the view from its nib.
}
- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - Action event for bar button item

- (void)saveDescription:(id)sender {
  if ([_textView.text isEqualToString:@""]) {
    [TSMessage showNotificationWithTitle:@"Error"
                                subtitle:@"Please enter event description."
                                    type:TSMessageNotificationTypeError];
  } else {
    if ([self.delegate
            respondsToSelector:@selector(addDescriptionController:
                                               didSaveDescription:)]) {
      [self.delegate addDescriptionController:self
                           didSaveDescription:_textView.text];
    }
  }
}

#pragma mark - UItextField delegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
  if ([textView.text isEqualToString:@"Add Description"]) {
    textView.text = @"";
  }
}

- (BOOL)textView:(UITextView *)textView
    shouldChangeTextInRange:(NSRange)range
            replacementText:(NSString *)text {
  if (range.location == 0 &&
      ([text isEqualToString:@" "] || [text isEqualToString:@"\n"])) {
    return NO;
  }
  return YES;
}

@end
