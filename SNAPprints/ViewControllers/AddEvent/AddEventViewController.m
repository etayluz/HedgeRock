
//
//  AddEventViewController.m
//  SNAPprints
//
//  Created by Etay Luz on 1/13/14.
//  Copyright (c) 2014 Etay Luz. All rights reserved.
//

#import "AddEventViewController.h"
#import "EventListViewController.h"
#import "MBProgressHUD.h"
#import "MFSideMenu.h"
#import "LocationManagerSingleton.h"
#import "TSMessage.h"
#import "AMTextFieldNumberPad.h"
#import "SqliteDBClass.h"
#import "Categories.h"
#import "InviteVC.h"
#import "ConstantFlags.h"
#import "ChooseContactViewController.h"
#import "NSString+CFT.h"
#import "SqliteDBClass.h"
//#import "FDStatusBarNotifierView.h"

#define TEXTFIELD_TAG_TITLE 100
#define TEXTFIELD_TAG_EVENT_START_TIME 107
#define TEXTFIELD_TAG_EVENT_END_TIME 108
#define TEXTFIELD_TAG_PRICE 101
#define TEXTFIELD_TAG_ADDRESS_1 102
#define TEXTFIELD_TAG_ADDRESS_2 103
#define TEXTFIELD_TAG_CITY 104
#define TEXTFIELD_TAG_STATE 105
#define TEXTFIELD_TAG_ZIP 106
#define TEXTFIELD_TAG_PHOTO_LIMIT 111
#define TEXTFIELD_TAG_DESCRIPTION 112
#define TEXTFIELD_TAG_GEORADIUS 113
#define TEXTFIELD_TAG_CATEGORY 114

#define IMAGEVIEW_TAG_HEARDER_PHOTO 115

#define SWITCH_CURRENT_LOCATION 90
#define SWITCH_PRIVATE_EVENT 91

#define DONE_DATE_VIEW 201
#define DONE_RANGE_VIEW 202
#define DONE_CATEGORY_VIEW 203

#define CATEGORY_PICKER 301
#define RANGE_PICKER 302

#define ACTIVITY_LOCATION 20
#define ACTIVITY_ZIP 21

#define ACTIONSHEET_ADD_PHOTOS_TAG 1
#define IMAGE_ALERTVIEW_TAG

@interface AddEventViewController () {
    UIActivityIndicatorView *currActivity;
    Event *savedEvent;
    SqliteDBClass *dbClass;
}
@property(weak, nonatomic) IBOutlet UILabel *headerTitle;

@property(strong, nonatomic) IBOutlet UIView *footerView;

@property(strong, nonatomic) IBOutlet UIView *headerView;

@property(weak, nonatomic) IBOutlet UIButton *btnSaveEvent;

- (IBAction)btnSaveClicked:(id)sender;

@end

@implementation AddEventViewController

@synthesize tableView = _tableView;
@synthesize event = _event;
@synthesize buttonItem;

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"";
    }
    return self;
}

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    isFromAddEvent = YES;
    if (!isEditEvent) {
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
        
        UILabel *lable = [[UILabel alloc] init];
        lable.frame = self.navigationController.navigationBar.frame;
        lable.numberOfLines = 2;
        lable.text = @"Add New Event";
        [lable sizeToFit];
        lable.textColor = [UIColor grayColor];
        lable.font = [UIFont fontWithName:kAppSupportedFontBold size:16.0f];
        self.navigationItem.titleView = lable;
        
    } else {
        //[_headerTitle setText:@"Edit Event"];
        UILabel *lable = [[UILabel alloc] init];
        lable.frame = self.navigationController.navigationBar.frame;
        lable.numberOfLines = 2;
        lable.text = @"Edit Event";
        [lable sizeToFit];
        lable.textColor = [UIColor grayColor];
        lable.font = [UIFont fontWithName:kAppSupportedFontBold size:16.0f];
        self.navigationItem.titleView = lable;
    }
    _tableView.tableHeaderView = _headerView;
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    _tableView.tableFooterView = _footerView;
    _btnSaveEvent.layer.cornerRadius = 5.0f;
    _btnSaveEvent.titleLabel.font = [UIFont fontWithName:kAppSupportedFontNormal size:20.0f];
    
    arrRange =
    [[NSMutableArray alloc] initWithObjects:@"5", @"10", @"20", @"30", nil];
    strgeoRange = [arrRange objectAtIndex:0];
    
    arrCategory = [[NSMutableArray alloc] init];
    id data = [[NSUserDefaults standardUserDefaults] objectForKey:@"Categories"];
    arrCategory = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    NSLog(@"Event:%@", _event);
    if (_event) {
        
        BOOL isNotCategory = YES; // YES because initially there is no category.
        for (int i = 0; i < [arrCategory count]; i++) {
            Categories *info = [arrCategory objectAtIndex:i];
            NSString *StrCat_ID =
            [NSString stringWithFormat:@"%ld", (long)info.cat_id];
            
            if ([_event.category_Id isEqualToString:StrCat_ID]) {
                category_id = StrCat_ID;
                strCategory = info.cat_name;
                isNotCategory = NO;
                break;
            }
        }
        if (isNotCategory)
            [self getCategory];
    } else {
        _event = [[Event alloc] init];
        _event.company = [[Company alloc] init];
        _event.address = [[Address alloc] init];
        _event.eventUser = [[User alloc] init];
        [self getCategory];
    }
    dbClass = [[SqliteDBClass alloc]init];
}

- (void)viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self] ==
        NSNotFound) {
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack.
    }
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action Events

- (IBAction)btnChooseContacts:(id)sender {
    
    ChooseContactViewController *chooseContactVC =
    [[ChooseContactViewController alloc]
     initWithNibName:@"ChooseContactViewController"
     bundle:nil];
    [self.navigationController pushViewController:chooseContactVC animated:YES];
}

- (IBAction)btnSaveClicked:(id)sender {
    [self saveEvent:sender];
}

- (IBAction)cancelPickerView:(id)sender {
    [self.datePickerView setHidden:YES];
    [self.radiusPickerView setHidden:YES];
    [self.categoryPickerView setHidden:YES];
}

- (IBAction)donePickerView:(id)sender {
    if ([sender tag] == DONE_DATE_VIEW) {
        NSIndexPath *indexPath = [_tableView indexPathForSelectedRow];
        
        NSInteger tag;
        
        tag = TEXTFIELD_TAG_EVENT_START_TIME + indexPath.row;
        
        UITableViewCell *cell =
        (UITableViewCell *)[_tableView cellForRowAtIndexPath:indexPath];
        UILabel *label = (UILabel *)[cell viewWithTag:tag];
        
        NSDate *date = _datePicker.date;
        
        //      // Display end date after 7 days of event start datetime.
        //      NSDate *startDate = nil;
        //      if(_event.eventStartDateTime!=nil)
        //          startDate = _event.eventStartDateTime;
        //      else
        //          startDate = date;
        //
        //      NSCalendar *gregorian = [[NSCalendar alloc]
        //      initWithCalendarIdentifier:NSGregorianCalendar];
        //      NSDateComponents *comps = [[NSDateComponents alloc] init];
        //      [comps setDay:7];
        //      NSDate *maxDate = [gregorian dateByAddingComponents:comps
        //      toDate:startDate  options:0];
        //      _event.eventEndDateTime = maxDate;
        //      UITableViewCell *cellEndDate = [_tableView
        //      cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
        //      UILabel *lblEndDate = (UILabel*)[cellEndDate
        //      viewWithTag:TEXTFIELD_TAG_EVENT_END_TIME];
        //      lblEndDate.text = [self getTextForDate:maxDate];
        
        if (indexPath.section == 1) {
            if (indexPath.row == 0) {
                _event.eventStartDateTime = date;
                NSCalendar *gregorian =
                [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                NSDateComponents *comps = [[NSDateComponents alloc] init];
                [comps setDay:7];
                NSDate *maxDate =
                [gregorian dateByAddingComponents:comps
                                           toDate:_event.eventStartDateTime
                                          options:0];
                _event.eventEndDateTime = maxDate;
                UITableViewCell *cellEndDate = [_tableView
                                                cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
                UILabel *lblEndDate =
                (UILabel *)[cellEndDate viewWithTag:TEXTFIELD_TAG_EVENT_END_TIME];
                lblEndDate.text = [self getTextForDate:maxDate];
                
            } else {
                _event.eventEndDateTime = date;
            }
        }
        
        label.text = [self getTextForDate:date];
        [self.datePickerView setHidden:YES];
    } else if ([sender tag] == DONE_RANGE_VIEW) {
        NSIndexPath *indexPath = [_tableView indexPathForSelectedRow];
        
        NSInteger tag;
        tag = TEXTFIELD_TAG_GEORADIUS + indexPath.row;
        
        UITableViewCell *cell =
        (UITableViewCell *)[_tableView cellForRowAtIndexPath:indexPath];
        UILabel *label = (UILabel *)[cell viewWithTag:tag];
        label.text = [NSString stringWithFormat:@"%@ km", strgeoRange];
        //_event.geoRange = [strgeoRange integerValue];
        [self.radiusPickerView setHidden:YES];
    } else if ([sender tag] == DONE_CATEGORY_VIEW) {
        NSIndexPath *indexPath = [_tableView indexPathForSelectedRow];
        
        NSInteger tag;
        tag = TEXTFIELD_TAG_CATEGORY + indexPath.row;
        
        UITableViewCell *cell =
        (UITableViewCell *)[_tableView cellForRowAtIndexPath:indexPath];
        UILabel *label = (UILabel *)[cell viewWithTag:tag];
        label.text = [NSString stringWithFormat:@"%@", strCategory];
        _event.category_Id = category_id;
        [self.categoryPickerView setHidden:YES];
    }
}

- (void)switchValueChanged:(UISwitch *)sender {
    if (sender.tag == SWITCH_CURRENT_LOCATION) {
        UISwitch *locationSwitch = (UISwitch *)sender;
        if (sender.on) {
            if ([LocationManagerSingleton locationServicesEnabled]) {
                NSLog(@"Allowed Location");
                CGPoint center = sender.center;
                CGPoint rootViewPoint =
                [sender.superview convertPoint:center toView:_tableView];
                NSIndexPath *indexpath =
                [_tableView indexPathForRowAtPoint:rootViewPoint];
                UITableViewCell *switchCell =
                [_tableView cellForRowAtIndexPath:indexpath];
                UIActivityIndicatorView *activity = (UIActivityIndicatorView *)
                [switchCell viewWithTag:ACTIVITY_LOCATION];
                [activity startAnimating];
                CLGeocoder *geocoder = [[CLGeocoder alloc] init];
                [geocoder
                 reverseGeocodeLocation:[LocationManagerSingleton sharedSingleton]
                 .locationManager.location
                 completionHandler:^(NSArray *placemarks, NSError *error) {
                     if (error) {
                         [locationSwitch setOn:NO];
                         [TSMessage
                          setDefaultViewController:self.navigationController];
                         [TSMessage
                          showNotificationWithTitle:@"Error"
                          subtitle:@"Unable to get current "
                          @"location."
                          type:
                          TSMessageNotificationTypeError];
                     } else {
                         if ([placemarks count] > 0) {
                             CLPlacemark *placemark = [placemarks objectAtIndex:0];
                             
                             UITableViewCell *address1Cell = [_tableView
                                                              cellForRowAtIndexPath:
                                                              [NSIndexPath indexPathForRow:1 inSection:3]];
                             UITableViewCell *zipCell = [_tableView
                                                         cellForRowAtIndexPath:
                                                         [NSIndexPath indexPathForRow:3 inSection:3]];
                             UITableViewCell *cityCell = [_tableView
                                                          cellForRowAtIndexPath:
                                                          [NSIndexPath indexPathForRow:4 inSection:3]];
                             UITableViewCell *stateCell = [_tableView
                                                           cellForRowAtIndexPath:
                                                           [NSIndexPath indexPathForRow:5 inSection:3]];
                             
                             UITextField *address1TextField = (UITextField *)
                             [address1Cell viewWithTag:TEXTFIELD_TAG_ADDRESS_1];
                             AMTextFieldNumberPad *zipTextField =
                             (AMTextFieldNumberPad *)
                             [zipCell viewWithTag:TEXTFIELD_TAG_ZIP];
                             UITextField *cityTextField = (UITextField *)
                             [cityCell viewWithTag:TEXTFIELD_TAG_CITY];
                             UITextField *stateTextField = (UITextField *)
                             [stateCell viewWithTag:TEXTFIELD_TAG_STATE];
                             
                             NSString *strCountry = [placemark.addressDictionary
                                                     objectForKey:@"Country"];
                             if ([strCountry isEqualToString:@"United States"]) {
                                 address1TextField.text = [placemark.addressDictionary
                                                           objectForKey:@"Name"];
                                 zipTextField.text = [placemark.addressDictionary
                                                      objectForKey:@"ZIP"];
                                 cityTextField.text = [placemark.addressDictionary
                                                       objectForKey:@"City"];
                                 stateTextField.text = [placemark.addressDictionary
                                                        objectForKey:@"State"];
                                 
                                 _event.address.address1 =
                                 [placemark.addressDictionary
                                  objectForKey:@"Name"];
                                 _event.address.zip = [placemark.addressDictionary
                                                       objectForKey:@"ZIP"];
                                 _event.address.city = [placemark.addressDictionary
                                                        objectForKey:@"City"];
                                 _event.address.state = [placemark.addressDictionary
                                                         objectForKey:@"State"];
                             } else {
                                 [locationSwitch setOn:NO];
                                 [TSMessage setDefaultViewController:
                                  self.navigationController];
                                 [TSMessage
                                  showNotificationWithTitle:
                                  @"Error" subtitle:@"This facility is not "
                                  @"provided for your " @"region."
                                  type:
                                  TSMessageNotificationTypeError];
                             }
                             
                         } else {
                             [TSMessage setDefaultViewController:
                              self.navigationController];
                             [TSMessage
                              showNotificationWithTitle:@"Error"
                              subtitle:@"No place found."
                              type:
                              TSMessageNotificationTypeError];
                         }
                     }
                     
                     [activity stopAnimating];
                 }];
                
            } else {
                [locationSwitch setOn:NO];
                [TSMessage setDefaultViewController:self.navigationController];
                [TSMessage
                 showNotificationWithTitle:@"Location Services Denied"
                 subtitle:@"SNAPprints requires access to your "
                 @"device's location services.\n\nPlease "
                 @"enable location services access for "
                 @"this app in Settings / Privacy / "
                 @"Location Services."
                 type:TSMessageNotificationTypeWarning];
            }
            
        } else {
            UITableViewCell *address1Cell = [_tableView
                                             cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:3]];
            UITableViewCell *zipCell = [_tableView
                                        cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:3]];
            UITableViewCell *cityCell = [_tableView
                                         cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:3]];
            UITableViewCell *stateCell = [_tableView
                                          cellForRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:3]];
            
            UITextField *address1TextField =
            (UITextField *)[address1Cell viewWithTag:TEXTFIELD_TAG_ADDRESS_1];
            AMTextFieldNumberPad *zipTextField =
            (AMTextFieldNumberPad *)[zipCell viewWithTag:TEXTFIELD_TAG_ZIP];
            UITextField *cityTextField =
            (UITextField *)[cityCell viewWithTag:TEXTFIELD_TAG_CITY];
            UITextField *stateTextField =
            (UITextField *)[stateCell viewWithTag:TEXTFIELD_TAG_STATE];
            
            address1TextField.text = @"";
            zipTextField.text = @"";
            cityTextField.text = @"";
            stateTextField.text = @"";
            
            _event.address.address1 = @"";
            _event.address.zip = @"";
            _event.address.city = @"";
            _event.address.state = @"";
        }
    } else if (sender.tag == SWITCH_PRIVATE_EVENT) {
        _event.isPrivate = sender.on;
    }
}

- (void)setEventPrivacy:(UISwitch *)sender {
    _event.isPrivate = sender.on;
}

#pragma mark - Custom Methods

/*
 Function: getImageURLForEvent
 Decription: Creates image url for event.
 Return: NSString
 Param: Event
 */
-(NSString *)getImageURLForEvent {
    
    NSString *urlString;
    if (![_event.thumbnail isEqualToString:@""]) {
        urlString = [NSString stringWithFormat:@"%@uploads/events/%@",
                     [Constants retriveServerURL],
                     _event.thumbnail];
        return urlString;
    } /*else if ([event.photos count] == 0) {
       return @"";
       } else {
       Photo *photo = [event.photos objectAtIndex:0];
       urlString = [NSString stringWithFormat:@"%@/uploads/photos/%@",
       [Constants retriveServerURL],
       photo.thumbnail_filename];
       return urlString;
       }*/
    return @"";
}

/*
 Function: getCategory
 Decription: Get the categories.
 Return: void
 */
- (void)getCategory {
    if ([arrCategory count] > 0) {
        Categories *info = [arrCategory objectAtIndex:0];
        _event.category_Id = [NSString stringWithFormat:@"%ld", (long)info.cat_id];
        strCategory = info.cat_name;
        category_id = [NSString stringWithFormat:@"%ld", (long)info.cat_id];
    }
}

- (void)toggleLeft:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{}];
}

/*
 Function: showEventList
 Decription: Shows event list controller.
 Return: void
 */
- (void)showEventList {
    EventListViewController *eventVC = [[EventListViewController alloc]
                                        initWithNibName:@"EventListViewController"
                                        bundle:[NSBundle mainBundle]];
    
    NSInteger loggedUser_id = [[[NSUserDefaults standardUserDefaults]
                                objectForKey:@"user_id"] integerValue];
    if (isFromMyEvent) {
        [eventVC getEventsForMyEvents:loggedUser_id];
    } else
        [eventVC getEventsForUser:loggedUser_id];
    
    UINavigationController *eventNav =
    [[UINavigationController alloc] initWithRootViewController:eventVC];
    
//    UIImageView *headerLogoView =
//    [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"new-logo"]];
//    [eventNav.navigationBar addSubview:headerLogoView];
//    headerLogoView.center = eventNav.navigationBar.center;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        eventNav.navigationBar.barTintColor = [UIColor whiteColor];
        [eventNav.navigationBar setTintColor:[UIColor blackColor]];
        eventNav.navigationBar.translucent = NO;
    } else {
        eventNav.navigationBar.tintColor = [UIColor blackColor];
    }
    
    self.menuContainerViewController.centerViewController = eventNav;
}

/*
 Function: showInviteList
 Decription: Shows choose view controller for inviting guests for that
 particular event.
 Return: void
 */
- (void)showInviteList {
    
    ChooseContactViewController *chooseContactVC =
    [[ChooseContactViewController alloc]
     initWithNibName:@"ChooseContactViewController"
     bundle:nil];
    chooseContactVC.event = savedEvent;
    UINavigationController *inviteNav = [[UINavigationController alloc]
                                         initWithRootViewController:chooseContactVC];
    
//    UIImageView *headerLogoView =
//    [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"new-logo"]];
//    [inviteNav.navigationBar addSubview:headerLogoView];
//    headerLogoView.center = inviteNav.navigationBar.center;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        inviteNav.navigationBar.barTintColor = [UIColor whiteColor];
        [inviteNav.navigationBar setTintColor:[UIColor blackColor]];
        inviteNav.navigationBar.translucent = NO;
    } else {
        inviteNav.navigationBar.tintColor = [UIColor blackColor];
    }
    
    self.menuContainerViewController.centerViewController = inviteNav;
    [self.menuContainerViewController toggleLeftSideMenuCompletion:nil];
}

/*
 Function: getTextForDate
 Decription: Returns date in string format.
 Return: NSString
 Param: NSDate
 */
- (NSString *)getTextForDate:(NSDate *)date {
    if (!date) {
        return @"";
    }
    NSLog(@"Date: %@", date);
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    
    [df setDateFormat:@"M/d/yyyy h:mm a"];
    
    NSString *dateString =
    [NSString stringWithFormat:@"%@", [df stringFromDate:date]];
    NSLog(@"After conversion Date: %@", dateString);
    return dateString;
}

/*
 Function: alertUserOfError
 Decription: Diplays error notification.
 Return: NSString
 */
- (void)alertUserOfError:(NSString *)message {
    
    [TSMessage setDefaultViewController:self.navigationController];
    [TSMessage showNotificationWithTitle:@"Missing Required Fields"
                                subtitle:message
                                    type:TSMessageNotificationTypeError];
}

/*
 Function: formIsValid
 Decription: Validation method for all fileds in Add event.
 Return: BOOL
 */
- (BOOL)formIsValid {
    
    BOOL isValid = YES;
    if (!_event.title || [self isEmpty:_event.title]) {
        [self showAlertMessage:@"Event title is required."];
        return NO;
    }
    
    if (!_event.description || [self isEmpty:_event.description]) {
        [self showAlertMessage:@"Event description is required."];
        return NO;
    }
    
    if (!_event.eventStartDateTime || !_event.eventEndDateTime) {
        [self showAlertMessage:@"Event start and end times are required."];
        return NO;
    }
    
    if ([_event.eventEndDateTime
         timeIntervalSinceDate:_event.eventStartDateTime] <= 0) {
        [self showAlertMessage:@"Event end time must be after start time."];
        return NO;
    }
    
    if (!_event.address.address1 || [self isEmpty:_event.address.address1]) {
        [self showAlertMessage:@"Event address is required."];
        return NO;
    }
    
    if (!_event.address.city || [self isEmpty:_event.address.city]) {
        [self showAlertMessage:@"Event city is required."];
        return NO;
    }
    
    if (!_event.address.state || [self isEmpty:_event.address.state]) {
        [self showAlertMessage:@"Event state is required."];
        return NO;
    }
    
    if (!_event.address.zip || [_event.address.zip isEqualToString:@""]) {
        [self showAlertMessage:@"Please enter valid zipcode."];
        return NO;
    }
    
    if (!_event.category_Id || [_event.category_Id isEqualToString:@""]) {
        [self showAlertMessage:@"Please select Category."];
        return NO;
    }
    if (_event.photoLimit == 0) {
        [self showAlertMessage:@"Please enter photo limit greater than zero."];
        return NO;
    }
    if (_event.photoLimit > [Photo_Limit integerValue]) {
        [self showAlertMessage:
         [NSString stringWithFormat:
          @"The photo limit should not be more than %lu.",
          (long)[Photo_Limit integerValue]]];
        return NO;
    }
    //BOOL ohoto = _event.headerThumbnail == nil;
    if (_event.thumbnailImage == nil) {
        NSLog(@"Inmage Not Present");
        [self showAlertMessage:
         [NSString stringWithFormat:
          @"Please add header photo."]];
        return NO;
    }
    return isValid;
}

/*
 Function: isEmpty
 Decription: Check whether the filed is empty or not.
 Return: BOOL
 Param: NSString
 */
- (BOOL)isEmpty:(NSString *)string {
    if ([string isEqualToString:@""]) {
        return YES;
    }
    
    return NO;
}

/*
 Function: showAlertMessage
 Decription: Diplays error message in alert box.
 Return: void
 Param: NSString
 */
- (void)showAlertMessage:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"SNAPprints"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 7;
    // return 5;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    if (section == 2 || section == 4) {
        return 1;
    } else if (section == 1 || section == 0) {
        return 2;
    } else if (section == 3) {
        return 6;
    } else if (section == 5) {
        return 2;
    } else if (section == 6){//event header photo
        return 1;
    }
    return 2;
}
/*

- (CGFloat)tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section {
    return 20;
}
*/
#pragma mark - UItableview delegates

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 6) {
        return 65;
    }
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = @"";
    if (indexPath.section == 0) {
        CellIdentifier = @"TextfieldCell";
    } else if ((indexPath.section == 3 && indexPath.row == 0) ||
               indexPath.section == 5) {
        CellIdentifier = @"SwitchCell";
    }
    
    CellIdentifier = [NSString
                      stringWithFormat:@"%ld%ld", (long)indexPath.section, (long)indexPath.row];
    
    UITableViewCell *cell =
    [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
        cell.textLabel.textColor = [UIColor grayColor];
        [cell.textLabel setFont:[UIFont fontWithName:kAppSupportedFontNormal size:15.f]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if ([self isTextFieldCell:indexPath]) {
            // UITextField *textField = [[UITextField alloc]
            // initWithFrame:CGRectMake(110, 0, 180, cell.frame.size.height)];
            UITextField *textField = [[UITextField alloc]
                                      initWithFrame:CGRectMake(90, 0, 200, cell.frame.size.height)];
            textField.tag = [self tagForIndexPath:indexPath];
            textField.delegate = self;
            // textField.font = [UIFont systemFontOfSize:14.0f];
            [textField setFont:[UIFont fontWithName:kAppSupportedFontNormal size:15.f]];
            textField.textAlignment = NSTextAlignmentRight;
            
            if (indexPath.section == 2) {
                textField.keyboardType = UIKeyboardTypeDecimalPad;
                textField.textColor = UIColorFromRGB(COLOR_LIGHT_BLUE);
            } else if ((indexPath.section == 3 && indexPath.row == 3) ||
                       (indexPath.section == 5 && indexPath.row == 1)) {
                textField = nil;
                AMTextFieldNumberPad *digitField = [[AMTextFieldNumberPad alloc]
                                                    initWithFrame:CGRectMake(90, 0, 200, cell.frame.size.height)];
                [digitField setTag:[self tagForIndexPath:indexPath]];
                [digitField setKeyboardType:UIKeyboardTypeNumberPad];
                [digitField setButtonIcon:ButtonIconKeyboard];
                [digitField setKeyboardAppearance:UIKeyboardAppearanceLight];
                [digitField setFont:[UIFont fontWithName:kAppSupportedFontNormal size:15.f]];
                digitField.textAlignment = NSTextAlignmentRight;
                digitField.delegate = self;
                textField = digitField;
                [[NSNotificationCenter defaultCenter]
                 addObserver:self
                 selector:@selector(textFieldDidChange:)
                 name:UITextFieldTextDidChangeNotification
                 object:textField];
                UIActivityIndicatorView *activityIndicator =
                [[UIActivityIndicatorView alloc]
                 initWithFrame:CGRectMake(155, 10, 20, 20)];
                [activityIndicator
                 setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
                [activityIndicator setHidesWhenStopped:YES];
                activityIndicator.tag = ACTIVITY_ZIP;
                [cell addSubview:activityIndicator];
                if (isFromMyEvent || isFromEventsNearMe) {
                    if ((indexPath.section == 5 && indexPath.row == 1)) {
                        [textField setUserInteractionEnabled:NO];
                    }
                }
            }
            
            [cell addSubview:textField];
            
            if (indexPath.section == 1 ||
                (indexPath.section == 0 && indexPath.row == 1) ||
                indexPath.section == 4) {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                textField.userInteractionEnabled = NO;
            }
            
        }
        else if ([self isSwitchCell:indexPath]) {
            UISwitch *privateSwitch = [[UISwitch alloc]
                                       initWithFrame:CGRectMake(cell.frame.size.width - 65, 5, 500, 44)];
            privateSwitch.tag = [self tagForIndexPath:indexPath];
            [privateSwitch addTarget:self
                              action:@selector(switchValueChanged:)
                    forControlEvents:UIControlEventValueChanged];
            [cell addSubview:privateSwitch];
            if ((indexPath.section == 3 && indexPath.row == 0)) {
                UIActivityIndicatorView *activityIndicator =
                [[UIActivityIndicatorView alloc]
                 initWithFrame:CGRectMake(155, 10, 20, 20)];
                [activityIndicator
                 setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
                [activityIndicator setHidesWhenStopped:YES];
                activityIndicator.tag = ACTIVITY_LOCATION;
                [cell addSubview:activityIndicator];
            } else if (indexPath.section == 5 && indexPath.row == 0) {
                NSString *strIsPrivate = [self getPropertyValueForIndexPath:indexPath];
                if ([strIsPrivate isEqualToString:@"0"])
                    [privateSwitch setOn:NO];
                else
                    [privateSwitch setOn:YES];
            }
        }
        else if ([self isDescriptionCell:indexPath]) {
            
        }else if ([self isHeaderPhotoCell:indexPath]){
            BOOL isPlaceHolder = YES;
            UIImageView *headerPhoto = [[UIImageView alloc] initWithImage:[self getPropertyForImage:indexPath withPlaceHoder: isPlaceHolder]];
            [headerPhoto setFrame:CGRectMake(cell.frame.size.width - 65.0, 5, 60, 60)];
            [headerPhoto setTag:IMAGEVIEW_TAG_HEARDER_PHOTO];
            [cell addSubview:headerPhoto];
        }
    } else {
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    cell.textLabel.text = [self getTitleForCellAtIndexPath:indexPath];
    
    cell.textLabel.numberOfLines = 2.0;
    [cell.textLabel setFont:[UIFont fontWithName:kAppSupportedFontNormal size:15.f]];
    if ([self isTextFieldCell:indexPath]) {
        int tag = [self tagForIndexPath:indexPath];
        UITextField *textField = (UITextField *)[cell viewWithTag:tag];
        textField.text = [self getPropertyValueForIndexPath:indexPath];
        
        if (indexPath.section == 2 && indexPath.section == 0) {
            if ([textField.text isEqualToString:@"0.00"]) {
                textField.text = @"Price";
            }
        }
    }
    if (indexPath.section == 5) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        if (indexPath.row == 1) {
            NSMutableString *strLabel = [NSMutableString
                                         stringWithString:[self getTitleForCellAtIndexPath:indexPath]];
            NSMutableAttributedString *attrStr =
            [[NSMutableAttributedString alloc] initWithString:strLabel];
            NSString *strRange = [strLabel substringFromIndex:21];
            NSRange range = NSMakeRange(([strLabel length] - [strRange length]),
                                        [strRange length]);
            [attrStr addAttribute:NSForegroundColorAttributeName
                            value:[UIColor lightGrayColor]
                            range:range];
            [attrStr addAttribute:NSFontAttributeName
                            value:[UIFont fontWithName:kAppSupportedFontNormal size:14.0]
                            range:range];
            cell.textLabel.attributedText = attrStr;
        }
    }
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        if (isFromMyEvent || isFromEventsNearMe) {
            NSDate *currentDate = [NSDate date];
            if (indexPath.section == 1 && indexPath.row == 0) {
                if ([_event.eventStartDateTime timeIntervalSinceDate:currentDate] > 0)
                    [self showDatePicker:indexPath];
                
            } else if (indexPath.section == 1 && indexPath.row == 1) {
                if ([_event.eventEndDateTime timeIntervalSinceDate:currentDate] > 0)
                    [self showDatePicker:indexPath];
            }
        } else {
            [self showDatePicker:indexPath];
        }
    }
    
    // Set up description
    else if (indexPath.section == 0 && indexPath.row == 1) {
        AddDescriptionViewController *addDescVC =
        [[AddDescriptionViewController alloc]
         initWithNibName:@"AddDescriptionViewController"
         bundle:[NSBundle mainBundle]];
        addDescVC.delegate = self;
        addDescVC.defaultText = _event.description;
        
        [self.navigationController pushViewController:addDescVC animated:YES];
    }
    //    else if(indexPath.section == 4)
    //    {
    //        [_radiusPickerView setHidden:NO];
    //    }
    else if (indexPath.section == 4) {
        [_categoryPickerView setHidden:NO];
    }
    else if (indexPath.section == 6){
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:Nil
                                      delegate:self
                                      cancelButtonTitle:@"Cancel"
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:@"Choose from Camera Roll", @"Take Photo", nil];
        actionSheet.tag = 1;
        [actionSheet showInView:self.view];
    }
    [self.view endEditing:YES];
}

#pragma mark - UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (actionSheet.tag == ACTIONSHEET_ADD_PHOTOS_TAG) {
        UIImagePickerController *imagePicker =
        [[UIImagePickerController alloc] init];
        _pickerController = imagePicker;
        
        if (buttonIndex == 1) {
            if ([UIImagePickerController
                 isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                _pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                _pickerController.delegate = self;
                _pickerController.videoQuality =
                UIImagePickerControllerQualityTypeMedium;
                [self presentViewController:_pickerController
                                   animated:YES
                                 completion:^{}];
            } else {
                UIAlertView *alertView = [[UIAlertView alloc]
                                          initWithTitle:@"Error"
                                          message:@"Your device does not have a camera"
                                          delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"OK", nil];
                alertView.tag = 123;
                [alertView show];
            }
        } else if (buttonIndex == 0) {
            if ([UIImagePickerController
                 isSourceTypeAvailable:
                 UIImagePickerControllerSourceTypePhotoLibrary]) {
                _pickerController.sourceType =
                UIImagePickerControllerSourceTypePhotoLibrary;
                _pickerController.delegate = self;
                [self presentViewController:_pickerController
                                   animated:YES
                                 completion:^{}];
            } else {
                UIAlertView *alertView = [[UIAlertView alloc]
                                          initWithTitle:@"Error"
                                          message:@"Your device does not have a camera roll"
                                          delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"OK", nil];
                [alertView show];
            }
        }
        //imagePicker = nil;
    }
}

#pragma mark - UINavigation Controller delegate

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault
                                                animated:NO];
}

#pragma mark - UIImagePickerController Delegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
//    UIImage *originalImage =[info objectForKey:UIImagePickerControllerOriginalImage];
    //Changes by mohsinali on 03 june 2015
    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    UIImage *originalImage = [appDel scaleAndRotateImage:[info objectForKey:UIImagePickerControllerOriginalImage]];

    _event.thumbnailImage =originalImage;
    
    UITableViewCell *headerImageCell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:6]];
    UIImageView *headerImageView = (UIImageView*)[headerImageCell viewWithTag:IMAGEVIEW_TAG_HEARDER_PHOTO];
    headerImageView.image = _event.thumbnailImage;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Custom methods for tableview

/*
 Function: getPropertyValueForIndexPath
 Decription: Diplays value entered in cell.
 Return: NSString
 Param: NSIndexPath
 */
- (NSString *)getPropertyValueForIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return _event.title;
        } else if (indexPath.row == 1) {
            return _event.description;
        }
    }
    
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            return [self getTextForDate:_event.eventStartDateTime];
        } else if (indexPath.row == 1) {
            return [self getTextForDate:_event.eventEndDateTime];
        }
    }
    
    if (indexPath.section == 2 && indexPath.row == 0) {
        if ([_event.price floatValue] == 0) {
            return @"Free";
        }
        
        return [NSString stringWithFormat:@"%.02f", [_event.price floatValue]];
    }
    
    if (indexPath.section == 3) {
        if (indexPath.row == 1) {
            return _event.address.address1;
        } else if (indexPath.row == 2) {
            return _event.address.address2;
        } else if (indexPath.row == 3) {
            return _event.address.zip;
        } else if (indexPath.row == 4) {
            return _event.address.city;
        } else if (indexPath.row == 5) {
            return _event.address.state;
        }
    }
    //    if(indexPath.section == 4)
    //    {
    //        if (_event.geoRange == 0) {
    //            return @"";
    //        }
    //        return [NSString stringWithFormat:@"%d",_event.geoRange];
    //    }
    if (indexPath.section == 4) {
        return strCategory;
    }
    if (indexPath.section == 5) {
        if (indexPath.row == 1) {
            if (_event.photoLimit == 0) {
                return @"";
            }
            
            return [NSString stringWithFormat:@"%ld", (long)_event.photoLimit];
        } else if (indexPath.row == 0) {
            return [NSString stringWithFormat:@"%d", _event.isPrivate];
        }
    }
    
    return @"";
}
-(UIImage *)getPropertyForImage:(NSIndexPath*)indexPath withPlaceHoder:(BOOL)isPlaceHolder
{
    if (indexPath.section == 6) {
        if (!isEditEvent) {
            UIImage *placeHolder = [UIImage imageNamed:@"placeholder.png"];
            return placeHolder;
        }else{
            if(_event.thumbnailImage)
            {
                return _event.thumbnailImage;
            }
            else
            {
                NSString *urlString = [self getImageURLForEvent];
                NSLog(@"URL String = %@",urlString);
                if([urlString isEqualToString:@""])
                {
                    UIImage *placeHolder = [UIImage imageNamed:@"placeholder.png"];
                    return placeHolder;
                }
                else
                {
                    NSURL *url = [NSURL URLWithString:urlString];
                    UIImageView *view = [[UIImageView alloc] init];
                    [view setImageWithURL:url];
                    _event.thumbnailImage = view.image;
                    return _event.thumbnailImage;
                }
            }
        }
    }
    return nil;
}

/*
 Function: isSwitchCell
 Decription: Checks whether cell contains USwitch or not at particular
 indexPath.
 Return: BOOL
 Param: NSIndexPath
 */
- (BOOL)isSwitchCell:(NSIndexPath *)indexPath {
    if ((indexPath.section == 5 && indexPath.row == 0) ||
        (indexPath.section == 3 && indexPath.row == 0)) {
        return YES;
    }
    return NO;
}

/*
 Function: isDescriptionCell
 Decription: Checks whether cell is description cell or not.
 Return: BOOL
 Param: NSIndexPath
 */
- (BOOL)isDescriptionCell:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 1) {
        return YES;
    } else if (indexPath.section == 4)
        return YES;
    
    return NO;
}

-(BOOL)isHeaderPhotoCell:(NSIndexPath *)indexPath{
    if (indexPath.section == 6) {
        return YES;
    }
    return NO;
}

/*
 Function: isTextFieldCell
 Decription: Checks whether cell contains UITextField or not at particular
 indexPath.
 Return: BOOL
 Param: NSIndexPath
 */
- (BOOL)isTextFieldCell:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return YES;
    }
    
    if (indexPath.section == 1) {
        return YES;
    }
    
    if (indexPath.section == 2 && indexPath.row == 0) {
        return YES;
    }
    
    if (indexPath.section == 3) {
        return indexPath.row != 0;
    }
    //    if (indexPath.section == 4) {
    //        return YES;
    //    }
    if (indexPath.section == 4) {
        return YES;
    }
    if (indexPath.section == 5) {
        if (indexPath.row == 1) {
            return YES;
        }
    }
    return NO;
}

/*
 Function: tagForIndexPath
 Decription: Gives tag for each object in cell at particular indexpath.
 Return: int
 Param: NSIndexPath
 */
- (int)tagForIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return TEXTFIELD_TAG_TITLE;
        } else {
            return TEXTFIELD_TAG_DESCRIPTION;
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            return TEXTFIELD_TAG_EVENT_START_TIME;
        } else {
            return TEXTFIELD_TAG_EVENT_END_TIME;
        }
    } else if (indexPath.section == 2) {
        return TEXTFIELD_TAG_PRICE;
    } else if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            return SWITCH_CURRENT_LOCATION;
        } else if (indexPath.row == 1) {
            return TEXTFIELD_TAG_ADDRESS_1;
        } else if (indexPath.row == 2) {
            return TEXTFIELD_TAG_ADDRESS_2;
        } else if (indexPath.row == 3) {
            return TEXTFIELD_TAG_ZIP;
        } else if (indexPath.row == 4) {
            return TEXTFIELD_TAG_CITY;
        } else if (indexPath.row == 5) {
            return TEXTFIELD_TAG_STATE;
        }
    }
    
    //    else if (indexPath.section == 4) {3
    //        return TEXTFIELD_TAG_GEORADIUS;
    //    }
    else if (indexPath.section == 4) {
        return TEXTFIELD_TAG_CATEGORY;
    } else if (indexPath.section == 5) {
        if (indexPath.row == 0) {
            return SWITCH_PRIVATE_EVENT;
        }
        if (indexPath.row == 1) {
            return TEXTFIELD_TAG_PHOTO_LIMIT;
        }
    } else if (indexPath.section == 6){
        return IMAGEVIEW_TAG_HEARDER_PHOTO;
    }
    
    return 1;
}

/*
 Function: showDatePicker
 Decription: Shows UIDatePicker for particular indexpath.
 Return: void
 Param: NSIndexPath
 */
- (void)showDatePicker:(NSIndexPath *)indexPath {
    [_datePickerView setHidden:NO];
    
    NSDate *selectedDate;
    NSDate *minimumDate = [NSDate date];
    NSCalendar *gregorian =
    [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    
    if (indexPath.section == 1 && indexPath.row == 0) {
        selectedDate = _event.eventStartDateTime;
        [comps setYear:2];
        NSDate *maxDate =
        [gregorian dateByAddingComponents:comps toDate:minimumDate options:0];
        _datePicker.maximumDate = maxDate;
    } else if (indexPath.section == 1 && indexPath.row == 1) {
        selectedDate = _event.eventEndDateTime;
        
        if (_event.eventStartDateTime) {
            NSDate *date = _event.eventStartDateTime;
            if (isFromMyEvent || isFromEventsNearMe) {
                if ([_event.eventStartDateTime timeIntervalSinceDate:[NSDate date]] > 0)
                    minimumDate = [date initWithTimeInterval:(NSTimeInterval)60
                                                   sinceDate:_event.eventStartDateTime];
                else
                    minimumDate = [NSDate date];
            } else
                minimumDate = [date initWithTimeInterval:(NSTimeInterval)60
                                               sinceDate:_event.eventStartDateTime];
            [comps setDay:7];
            NSDate *maxDate =
            [gregorian dateByAddingComponents:comps toDate:date options:0];
            _datePicker.maximumDate = maxDate;
        }
    }
    if (selectedDate && selectedDate != nil)
        [_datePicker setDate:selectedDate];
    else
        [_datePicker setDate:minimumDate];
    _datePicker.minimumDate = minimumDate;
}

/*
 Function: getTitleForCellAtIndexPath
 Decription: Gives title label to each cell.
 Return: NSString
 Param: NSIndexPath
 */
- (NSString *)getTitleForCellAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return @"Title";
        } else {
            return @"Description";
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            return @"Event Start Time";
        } else if (indexPath.row == 1) {
            return @"Event End Time";
        }
    } else if (indexPath.section == 2) {
        return @"Price (In Dollars)";
    } else if (indexPath.section == 3) {
        switch (indexPath.row) {
            case 0:
                return @"Use Current Location";
                break;
            case 1:
                return @"Address 1";
                break;
            case 2:
                return @"Address 2";
                break;
            case 3:
                return @"Zip";
                break;
            case 4:
                return @"City";
                break;
            case 5:
                return @"State";
                break;
            default:
                return @"";
        }
    }
    //    else if (indexPath.section == 4) {
    //        return @"Geo Fencing Range:";
    //    }
    else if (indexPath.section == 4) {
        return @"Category:";
    } else if (indexPath.section == 5) {
        if (indexPath.row == 0) {
            return @"Private";
        } else if (indexPath.row == 1) {
            NSString *str =
            [NSString stringWithFormat:
             @"Photo Limit Per User\n(Maximum photos per event %ld)",
             (long)[Photo_Limit integerValue]];
            return str;
        }
    } else if (indexPath.section == 6){
        return @"Header Photo";
    }
    
    return @"";
}

- (void)highlightCellAtIndexPath:(NSIndexPath *)indexPath hasError:(BOOL)error {
    UITableViewCell *cell =
    (UITableViewCell *)[_tableView cellForRowAtIndexPath:indexPath];
    
    cell.textLabel.backgroundColor =
    (error ? ERROR_COLOR
     : [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:1]);
}

#pragma mark - UITextfieldDelegate methods

- (void)textFieldDidChange:(NSNotification *)notif {
    
    UITextField *textField = (UITextField *)[notif object];
    if ([textField isKindOfClass:[AMTextFieldNumberPad class]]) {
        AMTextFieldNumberPad *numTextField = (AMTextFieldNumberPad *)textField;
        if (numTextField.tag == TEXTFIELD_TAG_ZIP) {
            if (numTextField.text.length == 5) {
                CGPoint point = textField.frame.origin;
                CGPoint rootViewPoint =
                [textField.superview convertPoint:point toView:_tableView];
                NSIndexPath *indexpath =
                [_tableView indexPathForRowAtPoint:rootViewPoint];
                UITableViewCell *cell = [_tableView cellForRowAtIndexPath:indexpath];
                UIActivityIndicatorView *activity =
                (UIActivityIndicatorView *)[cell viewWithTag:ACTIVITY_ZIP];
                currActivity = activity;
                [activity startAnimating];
                [self setCityAndStateForZip:numTextField.text];
            } else {
                UITableViewCell *cityCell = [_tableView
                                             cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:3]];
                UITableViewCell *stateCell = [_tableView
                                              cellForRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:3]];
                UITextField *cityTextField =
                (UITextField *)[cityCell viewWithTag:TEXTFIELD_TAG_CITY];
                UITextField *stateTextField =
                (UITextField *)[stateCell viewWithTag:TEXTFIELD_TAG_STATE];
                cityTextField.text = @"";
                stateTextField.text = @"";
            }
        }
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    _activeTextField = textField;
    [self cancelPickerView:nil];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 220)];
    _tableView.tableFooterView = view;
    UIView *superview = textField;
    while (superview != nil && ![superview isKindOfClass:[UITableViewCell class]]) {
        superview = [superview superview];
    }
//    UITableViewCell *cell = (UITableViewCell *)[[textField superview] superview];
    UITableViewCell *cell = (UITableViewCell *)superview;
    [_tableView scrollToRowAtIndexPath:[_tableView indexPathForCell:cell]
                      atScrollPosition:UITableViewScrollPositionTop
                              animated:YES];
    
    if (textField.tag == TEXTFIELD_TAG_PRICE) {
        if ([textField.text isEqualToString:@"Free"]) {
            textField.text = @"";
        }
        if (_event.price == nil && [_event.price floatValue] == 0.00) {
            UITextField *textfield =
            (UITextField *)[cell viewWithTag:TEXTFIELD_TAG_PRICE];
            // textfield.text = @"0.00";
            textfield.text = @"";
        }
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([textField isKindOfClass:[AMTextFieldNumberPad class]]) {
        AMTextFieldNumberPad *numTextField = (AMTextFieldNumberPad *)textField;
        if (numTextField.tag == TEXTFIELD_TAG_ZIP) {
            if (numTextField.text.length > 0 && numTextField.text.length < 5) {
                CGPoint point = textField.frame.origin;
                CGPoint rootViewPoint =
                [textField.superview convertPoint:point toView:_tableView];
                NSIndexPath *indexpath =
                [_tableView indexPathForRowAtPoint:rootViewPoint];
                UITableViewCell *cell = [_tableView cellForRowAtIndexPath:indexpath];
                UIActivityIndicatorView *activity =
                (UIActivityIndicatorView *)[cell viewWithTag:ACTIVITY_ZIP];
                currActivity = activity;
                [activity startAnimating];
                [self setCityAndStateForZip:numTextField.text];
            }
        }
        
        if (textField.tag == TEXTFIELD_TAG_PHOTO_LIMIT) {
            AMTextFieldNumberPad *numTextField = (AMTextFieldNumberPad *)textField;
            _event.photoLimit = [numTextField.text integerValue];
        }
    } else {
        if (textField.tag == TEXTFIELD_TAG_TITLE) {
            _event.title = textField.text;
        } else if (textField.tag == TEXTFIELD_TAG_PRICE) {
            _event.price = [NSNumber numberWithFloat:[textField.text floatValue]];
            
            if ([_event.price floatValue] == 0.00) {
                textField.text = @"Free";
            }
        } else if (textField.tag == TEXTFIELD_TAG_ADDRESS_1) {
            _event.address.address1 = textField.text;
        } else if (textField.tag == TEXTFIELD_TAG_ADDRESS_2) {
            _event.address.address2 = textField.text;
        } else if (textField.tag == TEXTFIELD_TAG_ZIP) {
            _event.address.zip = textField.text;
        } else if (textField.tag == TEXTFIELD_TAG_CITY) {
            _event.address.city = textField.text;
        } else if (textField.tag == TEXTFIELD_TAG_STATE) {
            _event.address.state = textField.text;
        }
    }
    
    [textField resignFirstResponder];
    _tableView.tableFooterView = _footerView;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string {
    if (textField.tag == TEXTFIELD_TAG_PHOTO_LIMIT) {
        if ([textField.text length] >= 3 && range.length == 0)
            return NO;
        return YES;
    } else if (textField.tag == TEXTFIELD_TAG_ZIP) {
        if ([textField.text length] >= 5 && range.length == 0)
            return NO;
        return YES;
    } else if (textField.tag == TEXTFIELD_TAG_ADDRESS_1 ||
               textField.tag == TEXTFIELD_TAG_ADDRESS_2) {
        if ([textField.text isEqualToString:@""]) {
            if ([string isEqualToString:@" "])
                return NO;
        } else if ([textField.text length] >= 100 && range.length == 0)
            return NO;
        
        return YES;
    } else {
        if ([textField.text isEqualToString:@""]) {
            if ([string isEqualToString:@" "])
                return NO;
        }
        return YES;
    }
}

#pragma mark - Custom geocoding methods

/*
 Function: setCityAndStateForZip
 Decription: Sets city and state automatically when we entered 5 didit zipcode.
 Return: void
 Param: NSString
 */
- (void)setCityAndStateForZip:(NSString *)zip {
    NSString *pathString =
    [NSString stringWithFormat:@"zipcode/index/%@.json", zip];
    [[SnapprintsClient sharedSnapprintsClient] getPath:pathString
                                            parameters:nil
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   if ([responseObject respondsToSelector:@selector(objectForKey:)]) {
                                                       
                                                       if ([[responseObject objectForKey:@"zipcode"]
                                                            respondsToSelector:@selector(objectForKey:)]) {
                                                           NSDictionary *zipcode = [[responseObject objectForKey:@"zipcode"]
                                                                                    objectForKey:@"Zipcode"];
                                                           
                                                           _event.address.zip = [zipcode objectForKey:@"zipcode"];
                                                           _event.address.city = [zipcode objectForKey:@"city"];
                                                           _event.address.state = [zipcode objectForKey:@"state"];
                                                           _event.address.coordinate = CLLocationCoordinate2DMake(
                                                                                                                  [[zipcode objectForKey:@"latitude"] floatValue],
                                                                                                                  [[zipcode objectForKey:@"longitude"] floatValue]);
                                                           
                                                           NSIndexPath *cityIndexPath =
                                                           [NSIndexPath indexPathForRow:4 inSection:3];
                                                           UITableViewCell *cityCell =
                                                           [_tableView cellForRowAtIndexPath:cityIndexPath];
                                                           UITableViewCell *stateCell = [_tableView
                                                                                         cellForRowAtIndexPath:[NSIndexPath indexPathForRow:5
                                                                                                                                  inSection:3]];
                                                           
                                                           UITextField *cityTextField =
                                                           (UITextField *)[cityCell viewWithTag:TEXTFIELD_TAG_CITY];
                                                           UITextField *stateTextField =
                                                           (UITextField *)[stateCell viewWithTag:TEXTFIELD_TAG_STATE];
                                                           
                                                           cityTextField.text = _event.address.city;
                                                           stateTextField.text = _event.address.state;
                                                           [currActivity stopAnimating];
                                                           currActivity = nil;
                                                       } else {
                                                           NSString *message =
                                                           [NSString stringWithFormat:@"%@ is not a valid zipcode", zip];
                                                           UIAlertView *alertView =
                                                           [[UIAlertView alloc] initWithTitle:@"SNAPprints"
                                                                                      message:message
                                                                                     delegate:nil
                                                                            cancelButtonTitle:@"OK"
                                                                            otherButtonTitles:nil, nil];
                                                           [alertView show];
                                                           NSIndexPath *cityIndexPath =
                                                           [NSIndexPath indexPathForRow:4 inSection:3];
                                                           UITableViewCell *cityCell =
                                                           [_tableView cellForRowAtIndexPath:cityIndexPath];
                                                           UITableViewCell *stateCell = [_tableView
                                                                                         cellForRowAtIndexPath:[NSIndexPath indexPathForRow:5
                                                                                                                                  inSection:3]];
                                                           
                                                           UITextField *cityTextField =
                                                           (UITextField *)[cityCell viewWithTag:TEXTFIELD_TAG_CITY];
                                                           UITextField *stateTextField =
                                                           (UITextField *)[stateCell viewWithTag:TEXTFIELD_TAG_STATE];
                                                           
                                                           cityTextField.text = @"";
                                                           stateTextField.text = @"";
                                                           
                                                           [currActivity stopAnimating];
                                                           currActivity = nil;
                                                       }
                                                   }
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   [currActivity stopAnimating];
                                                   currActivity = nil;
                                               }];
}

#pragma mark - AddDescriptionViewControllerDelegate Methods
- (void)addDescriptionController:(AddDescriptionViewController *)controller
              didSaveDescription:(NSString *)description {
    _event.description = description;
    
    NSIndexPath *indexPath = [_tableView indexPathForSelectedRow];
    UITableViewCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
    UITextField *textfield =
    (UITextField *)[cell viewWithTag:TEXTFIELD_TAG_DESCRIPTION];
    textfield.text = description;
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - API Call

/*
 Function: saveEvent
 Decription: Saves newly created event on click od save event button.
 Return: void
 Param: id
 */
- (void)saveEvent:(id)sender {
    
    [_activeTextField resignFirstResponder];
    
    buttonItem.enabled = NO;
    
    if ([self formIsValid]) {
        
        hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:hud];
        [hud show:YES];
        hud.labelText = @"Saving Event...";
        
        NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
        [parameters setObject:_event.title forKey:@"Event[title]"];
        [parameters setObject:_event.description forKey:@"Event[description]"];
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        //[df setDateFormat:@"yyyy-MM-d H:mm"];
        [df setDateFormat:@"M/d/yyyy h:mm a"];
        //        [df setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        
        [parameters setObject:[df stringFromDate:_event.eventStartDateTime]
                       forKey:@"Event[event_start_time]"];
        [parameters setObject:[df stringFromDate:_event.eventEndDateTime]
                       forKey:@"Event[event_end_time]"];
        [parameters setObject:[df stringFromDate:_event.eventStartDateTime]
                       forKey:@"Event[upload_start_time]"];
        [parameters setObject:[df stringFromDate:_event.eventEndDateTime]
                       forKey:@"Event[upload_end_time]"];
        if (_event.price) {
            [parameters setObject:[NSNumber numberWithFloat:[_event.price floatValue]]
                           forKey:@"Event[price]"];
        }
        
        [parameters setObject:_event.address.address1 forKey:@"Event[address1]"];
        
        if (_event.address.address2) {
            [parameters setObject:_event.address.address2 forKey:@"Event[address2]"];
        }
        
        [parameters setObject:_event.address.zip forKey:@"Event[zip]"];
        [parameters setObject:_event.address.city forKey:@"Event[city]"];
        [parameters setObject:_event.address.state forKey:@"Event[state]"];
        [parameters setObject:_event.category_Id forKey:@"Event[category_id]"];
        
        if (_event.isPrivate) {
            [parameters setObject:@"1" forKey:@"Event[private]"];
        } else {
            [parameters setObject:@"0" forKey:@"Event[private]"];
        }
        
        if (_event.photoLimit) {    
            [parameters setObject:[NSNumber numberWithInteger:_event.photoLimit]
                           forKey:@"Event[photo_limit]"];
        }
        
        NSString *userID =
        [[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"];
        NSString *token =
        [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
        NSString *strUsername = nil;
        NSString *strFname =
        [[NSUserDefaults standardUserDefaults] objectForKey:@"fname"];
        NSString *strLname =
        [[NSUserDefaults standardUserDefaults] objectForKey:@"lname"];
        if (strFname && strLname)
            strUsername = [NSString stringWithFormat:@"%@ %@", strFname, strLname];
        else
            strUsername =
            [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
        
        if (userID) {
            [parameters setObject:userID forKey:@"Event[user_id]"];
            [parameters setObject:userID forKey:@"user_id"];
            [parameters setObject:strUsername forKey:@"Event[created_by]"];
        }
        
        if (token) {
            [parameters setObject:token forKey:@"token"];
        }
        UIImage *image = _event.thumbnailImage;
        NSData *data =UIImageJPEGRepresentation(image, 0.6);
        [parameters setObject:data forKey:@"Event[thumbnail]"];
        NSLog(@"parameters = %@",parameters);
        if (isEditEvent) {
            hud.labelText = @"Updating Event...";
            [self editEvent:parameters withData:data];
        } else {

            SnapprintsClient *client = [SnapprintsClient sharedSnapprintsClient];
            NSMutableURLRequest *request = [client
                                            multipartFormRequestWithMethod:@"POST"
                                            path:@"/events/add.json"
                                            parameters:parameters
                                            constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                [formData appendPartWithFileData:data
                                                                            name:@"Event[thumbnail]"
                                                                        fileName:@"temp.png"
                                                                        mimeType:@"image/png"];
                                            }];            
            
            AFHTTPRequestOperation *operation =
            [[AFHTTPRequestOperation alloc] initWithRequest:request];
            
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSError *error =nil;
                id JSON = [NSJSONSerialization JSONObjectWithData:responseObject
                                                          options:0
                                                            error:&error];
                
                NSLog(@"Add New Event responseObject = %@",JSON);
                [hud hide:YES];
                NSDictionary *events = [JSON objectForKey:@"event"];
                if ([[JSON valueForKeyPath:@"status"]
                     isEqualToString:@"success"]) {
                    
                    savedEvent = [[Event alloc] init];
                    NSDateFormatter *df = [[NSDateFormatter alloc] init];
                    [df setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
                    NSMutableDictionary *eventDict = [events objectForKey:@"Event"];
                    Event *event = [[Event alloc] init];
                    event.type = @"E";
                    Company *company = [[Company alloc] init];
                    Address *address = [[Address alloc] init];
                    User *user = [[User alloc] init];
                    
                    address.address1 = [eventDict objectForKey:@"address1"];
                    address.address2 = [eventDict objectForKey:@"address2"];
                    address.city = [eventDict objectForKey:@"city"];
                    address.state = [eventDict objectForKey:@"state"];
                    address.zip = [eventDict objectForKey:@"zip"];
                    
                    if (![[eventDict objectForKey:@"price"]
                          isKindOfClass:[NSNull class]]) {
                        savedEvent.price = [NSNumber
                                            numberWithFloat:[[eventDict
                                                              objectForKey:@"price"] floatValue]];
                    } else {
                        savedEvent.price = [NSNumber numberWithFloat:0.00];
                    }
                    
                    if (![[eventDict objectForKey:@"lat"]
                          isKindOfClass:[NSNull class]]) {
                        float lat = [[eventDict objectForKey:@"lat"] floatValue];
                        float lng = [[eventDict objectForKey:@"lng"] floatValue];
                        address.coordinate = CLLocationCoordinate2DMake(lat, lng);
                    }
                    
                    savedEvent.isPrivate =
                    [[eventDict objectForKey:@"private"] boolValue];
                    
                    if (![[eventDict objectForKey:@"company_id"]
                          isKindOfClass:[NSNull class]])
                        company.companyId =
                        [[eventDict objectForKey:@"company_id"] integerValue];
                    
                    NSDictionary *userDict = [events objectForKey:@"User"];
                    if (![[userDict objectForKey:@"id"]
                          isKindOfClass:[NSNull class]])
                        user.userId = [[userDict objectForKey:@"id"] integerValue];
                    
                    // Get event creator name
                    if (![[eventDict objectForKey:@"created_by"]
                          isKindOfClass:[NSNull class]])
                        user.username = [eventDict objectForKey:@"created_by"];
                    else
                        user.username = @"";
                    
                    savedEvent.address = address;
                    savedEvent.company = company;
                    // savedEvent.user = user;
                    savedEvent.eventUser = user;
                    
                    if (![[eventDict objectForKey:@"photo_limit"]
                          isKindOfClass:[NSNull class]]) {
                        savedEvent.photoLimit =
                        [[eventDict objectForKey:@"photo_limit"] integerValue];
                    } else {
                        savedEvent.photoLimit = 10;
                    }
                    
                    savedEvent.eventId =
                    [[eventDict objectForKey:@"id"] integerValue];
                    
                    savedEvent.title = [eventDict objectForKey:@"title"];
                    savedEvent.description =
                    [eventDict objectForKey:@"description"];
                    
                    savedEvent.eventStartDateTime =
                    [df dateFromString:[eventDict
                                        objectForKey:@"event_start_time"]];
                    savedEvent.eventEndDateTime = [df
                                                   dateFromString:[eventDict objectForKey:@"event_end_time"]];
                    
                    savedEvent.created =
                    [df dateFromString:[eventDict objectForKey:@"created"]];
                    savedEvent.updated =
                    [df dateFromString:[eventDict objectForKey:@"updated"]];
                    
                    savedEvent.category_Id =
                    [eventDict objectForKey:@"category_id"];
                    
                    if ([[eventDict objectForKey:@"thumbnail"]
                         isKindOfClass:[NSNull class]]) {
                        savedEvent.thumbnail = @"";
                    } else {
                        savedEvent.thumbnail = [eventDict objectForKey:@"thumbnail"];
                    }
                    
                    // Add Event to calendar
                    [parameters setObject:[NSString stringWithFormat:@"%ld",(long)savedEvent.eventId] forKey:@"Event[id]"];
                    [self saveEventToCalendar:parameters];
                    
                    // ************
                    NSLog(@"Response after saving event :%@", responseObject);
                    UIAlertView *alertView = [[UIAlertView alloc]
                                              initWithTitle:@"SNAPprints"
                                              message:@"Your event added successfully.\nDo you "
                                              @"want to invite friends?"
                                              delegate:nil
                                              cancelButtonTitle:@"Yes"
                                              otherButtonTitles:@"Skip", nil];
                    alertView.tag = 100;
                    alertView.delegate = self;
                    [alertView show];
                    buttonItem.enabled = YES;
                    isFromEventsNearMe = YES;
                    
                } else {
                    
                    [TSMessage setDefaultViewController:self.navigationController];
                    [TSMessage
                     showNotificationWithTitle:@"Error"
                     subtitle:[responseObject
                               valueForKeyPath:@"message"]
                     type:TSMessageNotificationTypeError];
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                //
                [hud hide:YES];
                
                [TSMessage setDefaultViewController:self.navigationController];
                [TSMessage
                 showNotificationWithTitle:@"Error"
                 subtitle:@"Error from server. Please try "
                 @"again later."
                 type:TSMessageNotificationTypeError];
                buttonItem.enabled = YES;
            }];
            [operation start];
 
            /*
            [[SnapprintsClient sharedSnapprintsClient] postPath:@"/events/add.json"
                                                     parameters:parameters
                                                        success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                            
                                                            [hud hide:YES];
                                                            NSDictionary *events = [responseObject objectForKey:@"event"];
                                                            if ([[responseObject valueForKeyPath:@"status"]
                                                                 isEqualToString:@"success"]) {
                                                                
                                                                savedEvent = [[Event alloc] init];
                                                                NSDateFormatter *df = [[NSDateFormatter alloc] init];
                                                                [df setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
                                                                NSMutableDictionary *eventDict = [events objectForKey:@"Event"];
                                                                Event *event = [[Event alloc] init];
                                                                event.type = @"E";
                                                                Company *company = [[Company alloc] init];
                                                                Address *address = [[Address alloc] init];
                                                                User *user = [[User alloc] init];
                                                                
                                                                address.address1 = [eventDict objectForKey:@"address1"];
                                                                address.address2 = [eventDict objectForKey:@"address2"];
                                                                address.city = [eventDict objectForKey:@"city"];
                                                                address.state = [eventDict objectForKey:@"state"];
                                                                address.zip = [eventDict objectForKey:@"zip"];
                                                                
                                                                if (![[eventDict objectForKey:@"price"]
                                                                      isKindOfClass:[NSNull class]]) {
                                                                    savedEvent.price = [NSNumber
                                                                                        numberWithFloat:[[eventDict
                                                                                                          objectForKey:@"price"] floatValue]];
                                                                } else {
                                                                    savedEvent.price = [NSNumber numberWithFloat:0.00];
                                                                }
                                                                
                                                                if (![[eventDict objectForKey:@"lat"]
                                                                      isKindOfClass:[NSNull class]]) {
                                                                    float lat = [[eventDict objectForKey:@"lat"] floatValue];
                                                                    float lng = [[eventDict objectForKey:@"lng"] floatValue];
                                                                    address.coordinate = CLLocationCoordinate2DMake(lat, lng);
                                                                }
                                                                
                                                                savedEvent.isPrivate =
                                                                [[eventDict objectForKey:@"private"] boolValue];
                                                                
                                                                if (![[eventDict objectForKey:@"company_id"]
                                                                      isKindOfClass:[NSNull class]])
                                                                    company.companyId =
                                                                    [[eventDict objectForKey:@"company_id"] integerValue];
                                                                
                                                                NSDictionary *userDict = [events objectForKey:@"User"];
                                                                if (![[userDict objectForKey:@"id"]
                                                                      isKindOfClass:[NSNull class]])
                                                                    user.userId = [[userDict objectForKey:@"id"] integerValue];
                                                                
                                                                // Get event creator name
                                                                if (![[eventDict objectForKey:@"created_by"]
                                                                      isKindOfClass:[NSNull class]])
                                                                    user.username = [eventDict objectForKey:@"created_by"];
                                                                else
                                                                    user.username = @"";
                                                                
                                                                savedEvent.address = address;
                                                                savedEvent.company = company;
                                                                // savedEvent.user = user;
                                                                savedEvent.eventUser = user;
                                                                
                                                                if (![[eventDict objectForKey:@"photo_limit"]
                                                                      isKindOfClass:[NSNull class]]) {
                                                                    savedEvent.photoLimit =
                                                                    [[eventDict objectForKey:@"photo_limit"] integerValue];
                                                                } else {
                                                                    savedEvent.photoLimit = 10;
                                                                }
                                                                
                                                                savedEvent.eventId =
                                                                [[eventDict objectForKey:@"id"] integerValue];
                                                                
                                                                savedEvent.title = [eventDict objectForKey:@"title"];
                                                                savedEvent.description =
                                                                [eventDict objectForKey:@"description"];
                                                                
                                                                savedEvent.eventStartDateTime =
                                                                [df dateFromString:[eventDict
                                                                                    objectForKey:@"event_start_time"]];
                                                                savedEvent.eventEndDateTime = [df
                                                                                               dateFromString:[eventDict objectForKey:@"event_end_time"]];
                                                                
                                                                savedEvent.created =
                                                                [df dateFromString:[eventDict objectForKey:@"created"]];
                                                                savedEvent.updated =
                                                                [df dateFromString:[eventDict objectForKey:@"updated"]];
                                                                
                                                                savedEvent.category_Id =
                                                                [eventDict objectForKey:@"category_id"];
                                                                
                                                                if ([[eventDict objectForKey:@"thumbnail"]
                                                                     isKindOfClass:[NSNull class]]) {
                                                                    savedEvent.thumbnail = @"";
                                                                } else {
                                                                    savedEvent.thumbnail = [eventDict objectForKey:@"thumbnail"];
                                                                }
                                                                // Add Event to calendar
                                                                [parameters setObject:[NSString stringWithFormat:@"%ld",(long)savedEvent.eventId] forKey:@"Event[id]"];
                                                                [self saveEventToCalendar:parameters];
                                                                
                                                                // ************
                                                                NSLog(@"Response after saving event :%@", responseObject);
                                                                UIAlertView *alertView = [[UIAlertView alloc]
                                                                                          initWithTitle:@"SNAPprints"
                                                                                          message:@"Your event added successfully.\nDo you "
                                                                                          @"want to invite friends?"
                                                                                          delegate:nil
                                                                                          cancelButtonTitle:@"Yes"
                                                                                          otherButtonTitles:@"Skip", nil];
                                                                alertView.tag = 100;
                                                                alertView.delegate = self;
                                                                [alertView show];
                                                                buttonItem.enabled = YES;
                                                                isFromEventsNearMe = YES;
                                                                
                                                            } else {
                                                                
                                                                [TSMessage setDefaultViewController:self.navigationController];
                                                                [TSMessage
                                                                 showNotificationWithTitle:@"Error"
                                                                 subtitle:[responseObject
                                                                           valueForKeyPath:@"message"]
                                                                 type:TSMessageNotificationTypeError];
                                                            }
                                                        }
                                                        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                            [hud hide:YES];
                                                            
                                                            [TSMessage setDefaultViewController:self.navigationController];
                                                            [TSMessage
                                                             showNotificationWithTitle:@"Error"
                                                             subtitle:@"Error from server. Please try "
                                                             @"again later."
                                                             type:TSMessageNotificationTypeError];
                                                            buttonItem.enabled = YES;
                                                        }];
            */
        }
    } else {
        buttonItem.enabled = YES;
    }
}

/*
 Function: EditEvent
 Decription: Saves edited event on click od save event button.
 Return: void
 Param: NSMutableDictionary
 */
- (void)editEvent:(NSMutableDictionary *)parameters withData:(NSData*)data{
    
    [parameters setObject:[NSString stringWithFormat:@"%ld", (long)_event.eventId]
                   forKey:@"Event[id]"];
    
    SnapprintsClient *client = [SnapprintsClient sharedSnapprintsClient];
    NSMutableURLRequest *request = [client
                                    multipartFormRequestWithMethod:@"POST"
                                    path:@"/events/edit.json"
                                    parameters:parameters
                                    constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                        [formData appendPartWithFileData:data
                                                                    name:@"Event[thumbnail]"
                                                                fileName:@"temp.png"
                                                                mimeType:@"image/png"];
                                    }];
    
    AFHTTPRequestOperation *operation =
    [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        //
        NSError *error =nil;
        id JSON = [NSJSONSerialization JSONObjectWithData:responseObject
                                                  options:0
                                                    error:&error];
        if ([[JSON valueForKeyPath:@"status"]
             isEqualToString:@"success"]) {
            
            savedEvent = _event;
            [hud hide:YES];
            NSLog(@"Response after saving event :%@", responseObject);
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@"SNAPprints"
                                      message:@"Your event edited successfully.\nDo you "
                                      @"want to invite friends?"
                                      delegate:nil
                                      cancelButtonTitle:@"Yes"
                                      otherButtonTitles:@"Skip", nil];
            alertView.tag = 101;
            alertView.delegate = self;
            [alertView show];
            buttonItem.enabled = YES;
        } else {
            [hud hide:YES];
            [TSMessage setDefaultViewController:self.navigationController];
            [TSMessage
             showNotificationWithTitle:@"Error"
             subtitle:[responseObject
                       valueForKeyPath:@"message"]
             type:TSMessageNotificationTypeError];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [hud hide:YES];
        
        [TSMessage setDefaultViewController:self.navigationController];
        [TSMessage
         showNotificationWithTitle:@"Error"
         subtitle:
         @"Error from server. Please try again later."
         type:TSMessageNotificationTypeError];
        buttonItem.enabled = YES;

    }];
    [operation start];
}

#pragma mark - Save Event to Calendar

- (void)saveEventToCalendar:(NSMutableDictionary *)dict {
    
    self.eventStore = [[EKEventStore alloc] init];
    
    [self.eventStore
     requestAccessToEntityType:EKEntityTypeEvent
     completion:^(BOOL granted, NSError *error) {
         if (granted) {
             
             EKEvent *event =
             [EKEvent eventWithEventStore:self.eventStore];
             event.title = [dict valueForKey:@"Event[title]"];
             NSString *strAddress2 = nil;
             if([dict valueForKey:@"Event[address2]"]==nil || [[dict valueForKey:@"Event[address2]"]isKindOfClass:[NSNull class]])
             {
                 strAddress2 = @"";
             }
             else
                 strAddress2 = [dict valueForKey:@"Event[address2]"];
             if([strAddress2 isEqualToString:@""])
             {
                 event.location = [NSString
                                   stringWithFormat:
                                   @"%@, %@, %@, %@",
                                   [dict valueForKey:@"Event[address1]"],
                                   [dict valueForKey:@"Event[city]"],
                                   [dict valueForKey:@"Event[state]"],
                                   [dict valueForKey:@"Event[zip]"]];
             }
             else
             {
                 event.location = [NSString
                                   stringWithFormat:
                                   @"%@, %@, %@, %@, %@",
                                   [dict valueForKey:@"Event[address1]"],
                                   strAddress2,
                                   [dict valueForKey:@"Event[city]"],
                                   [dict valueForKey:@"Event[state]"],
                                   [dict valueForKey:@"Event[zip]"]];
             }
             
             NSString *strStart = [NSString
                                   stringWithFormat:
                                   @"%@",
                                   [dict
                                    valueForKey:@"Event[event_start_time]"]];
             NSString *strEnd = [NSString
                                 stringWithFormat:
                                 @"%@",
                                 [dict valueForKey:@"Event[event_end_time]"]];
             NSDateFormatter *dateFormat =
             [[NSDateFormatter alloc] init];
             [dateFormat setDateFormat:@"MM/dd/yyyy hh:mm a"];
             
             NSDate *startdate =
             [dateFormat dateFromString:strStart];
             NSDate *endDate = [dateFormat dateFromString:strEnd];
             
             event.startDate = startdate;
             ;
             event.endDate = endDate;
             event.notes =
             [dict valueForKey:@"Event[description]"];
             event.availability = EKEventAvailabilityFree;
             NSMutableArray *myAlarmsArray =
             [[NSMutableArray alloc] init];
             
             EKAlarm *alarm1 = [EKAlarm
                                alarmWithRelativeOffset:-3600]; // 1 Hour
             EKAlarm *alarm2 = [EKAlarm
                                alarmWithRelativeOffset:-86400]; // 1 Day
             
             [myAlarmsArray addObject:alarm1];
             [myAlarmsArray addObject:alarm2];
             event.alarms = myAlarmsArray;
             //[myAlarmsArray release];
             [event setCalendar:
              [self.eventStore
               defaultCalendarForNewEvents]];
             NSError *err;
             [self.eventStore saveEvent:event
                                   span:EKSpanThisEvent
                                  error:&err];
             
             if (err)
                 NSLog(@"unable to save event to the calendar!: "
                       @"Error= %@",
                       err);
             else
             {
                 
                 //                               [TSMessage setDefaultViewController:self.navigationController];
                 //                               [TSMessage
                 //                                showNotificationWithTitle:@"" subtitle:@"Event successfully saved to calendar."
                 //                                type:TSMessageNotificationTypeSuccess];
                 //                               FDStatusBarNotifierView *notifierView = [[FDStatusBarNotifierView alloc] initWithMessage:@"Event successfully saved to calendar." delegate:nil];
                 //                               notifierView.timeOnScreen = 3.0;
                 //                               [notifierView showAboveNavigationController:self.navigationController];
                 [dbClass insertEventCalendar:dict];
             }
         }
         else {
             
             dispatch_async(dispatch_get_main_queue(),
                            ^{
                                
                                
                                [TSMessage setDefaultViewController:self.navigationController];
                                [TSMessage
                                 showNotificationWithTitle:@"Calendar Access Denied!" subtitle:@"SNAPprints requires access to your device's calendar.\n\nPlease enable calendar access for SNAPprints. Go Settings -> Privacy -> Calendar"
                                 type:TSMessageNotificationTypeWarning];
                                
                            });
             
             
         }
     }];
}

#pragma mark - Picker Delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView
numberOfRowsInComponent:(NSInteger)component {
    //    if(thePickerView.tag == RANGE_PICKER)
    //        return [arrRange count];
    //    else  if(thePickerView.tag == CATEGORY_PICKER)
    //        return [arrCategory count];
    //    return 0 ;
    return [arrCategory count];
}

- (NSString *)pickerView:(UIPickerView *)thePickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component {
    //    if(thePickerView.tag == RANGE_PICKER)
    //        return [arrRange objectAtIndex:row];
    //    else if(thePickerView.tag == CATEGORY_PICKER)
    //    {
    //        Categories *cat_Info = [arrCategory objectAtIndex:row];
    //        return cat_Info.cat_name;
    //    }
    //    return @"";
    if (thePickerView.tag == CATEGORY_PICKER) {
        Categories *cat_Info = [arrCategory objectAtIndex:row];
        return cat_Info.cat_name;
    }
    return @"";
}

- (void)pickerView:(UIPickerView *)thePickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component {
    //    if(thePickerView.tag == RANGE_PICKER)
    //        strgeoRange =  [arrRange objectAtIndex:row];
    //    else
    if (thePickerView.tag == CATEGORY_PICKER) {
        Categories *cat_Info = [arrCategory objectAtIndex:row];
        strCategory = cat_Info.cat_name;
        category_id = [NSString stringWithFormat:@"%ld", (long)cat_Info.cat_id];
    }
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag != 123) { //camera alert view check
        if (buttonIndex == 0) {
            [self showInviteList];
        } else {
            [self showEventList];
        }
    }
    
}

@end
