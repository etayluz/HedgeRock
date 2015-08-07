//
//  SearchViewController.h
//  SNAPprints
//
//  Created by Etay Luz on 01/07/14.
//  Copyright (c) 2014 Etay Luz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Categories.h"
#import "Constants.h"
#import "UITextField+Placeholder.h"
#import "AFNetworking.h"
#import "Region.h"
#import "NSString+CFT.h"
#import "AFHTTPClient.h"
#import "LocationManagerSingleton.h"
#import "Event.h"
#import "Company.h"
#import "User.h"
#import "Photo.h"
#import "MBProgressHUD.h"
#import "LocationManagerSingleton.h"
#import "TSMessage.h"
#import "ConstantFlags.h"
#import "AppDelegate.h"

@protocol SearchVCDelegate <NSObject>

- (void)advancedSearchData:(NSMutableArray *)arr;

@end

@interface SearchViewController : UIViewController {
  NSMutableArray *arrCategory;
  NSString *strCategory;
  NSString *category_id;
  Region *cityRegion;
  NSMutableArray *arrEvents;
  MBProgressHUD *hud;
  NSString *latString;
  NSString *lngString;
  AppDelegate *appdelegate;
}
@property(weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property(nonatomic, retain) AFJSONRequestOperation *operation;

@property(nonatomic, retain) NSMutableArray *resultTableData;

@property(weak, nonatomic) IBOutlet UITextField *txtEventName;

@property(weak, nonatomic) IBOutlet UITextField *txtCity;

@property(weak, nonatomic) IBOutlet UITextField *txtZipcode;

@property(weak, nonatomic) IBOutlet UITextField *txtCategory;

@property(weak, nonatomic) IBOutlet UIButton *btnSearch;

@property(weak, nonatomic) IBOutlet UIView *categoryPickerView;

@property(weak, nonatomic) IBOutlet UIPickerView *categoryPicker;

@property(weak, nonatomic) IBOutlet UIButton *btnDropDown;

@property(weak, nonatomic) IBOutlet UITableView *tblCities;

@property(weak, nonatomic) IBOutlet UITextField *txtSearchCity;

@property(weak, nonatomic) IBOutlet UIButton *btnClose;

@property(weak, nonatomic) IBOutlet UIButton *btnCat_Clear;

@property(weak, nonatomic) IBOutlet UIButton *btnClear;

@property(strong, nonatomic) IBOutlet UIView *cityView;

@property(weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property(weak, nonatomic) IBOutlet UIImageView *imgDropDown;

@property(weak, nonatomic) id<SearchVCDelegate> delegate;

@property(weak, nonatomic) IBOutlet UILabel *lblTitle;

@property(weak, nonatomic) IBOutlet UIButton *btnLocation;

@property(weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;

@property(weak, nonatomic) IBOutlet UIButton *btnsaveSearch;

@property(weak, nonatomic) IBOutlet UILabel *lblDistance;

@property(weak, nonatomic) IBOutlet UISlider *distanceSlider;

- (IBAction)btnClearClicked:(id)sender;

- (IBAction)cancelPicker:(id)sender;

- (IBAction)donePicker:(id)sender;

- (IBAction)btnSearchClicked:(id)sender;

- (IBAction)btnDropdownClicked:(id)sender;

- (IBAction)btnCloseClicked:(id)sender;

- (IBAction)btnCityClicked:(id)sender;

- (IBAction)btnLocationClicked:(id)sender;

- (IBAction)btnSaveSearchClicked:(id)sender;

- (IBAction)distanceValueChanged:(id)sender;

@end
