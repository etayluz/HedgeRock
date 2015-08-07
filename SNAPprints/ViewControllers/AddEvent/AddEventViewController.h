//
//  AddEventViewController.h
//  SNAPprints
//
//  Created by Etay Luz on 1/13/14.
//  Copyright (c) 2014 Etay Luz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"
#import "AddDescriptionViewController.h"
#import "MBProgressHUD.h"
#import <EventKit/EventKit.h>
@interface AddEventViewController
    : UIViewController <
          UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate,
          AddDescriptionViewControllerDelegate, UIAlertViewDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
  NSMutableArray *arrRange;
  NSMutableArray *arrCategory;
  NSString *strgeoRange;
  NSString *strCategory;
  NSString *category_id;
  MBProgressHUD *hud;
}

@property(nonatomic, retain) EKEventStore *eventStore;
@property(nonatomic, retain) IBOutlet UITableView *tableView;
@property(nonatomic, retain) Event *event;
@property(nonatomic, retain) UIBarButtonItem *buttonItem;
@property(nonatomic, retain) UITextField *activeTextField;
@property(weak, nonatomic) IBOutlet UIView *datePickerView;

@property(weak, nonatomic) IBOutlet UIView *radiusPickerView;

@property(weak, nonatomic) IBOutlet UIPickerView *radiusPicker;

@property(weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@property(strong, nonatomic) IBOutlet UIView *categoryPickerView;

@property(weak, nonatomic) IBOutlet UIPickerView *categoryPicker;

@property (strong, nonatomic) UIImagePickerController *pickerController;

@end
