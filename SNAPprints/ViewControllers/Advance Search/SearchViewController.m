//
//  SearchViewController.m
//  SNAPprints
//
//  Created by Etay Luz on 01/07/14.
//  Copyright (c) 2014 Etay Luz. All rights reserved.
//

#import "SearchViewController.h"
#import "Constants.h"
#import "LoginViewController.h"
#define TEXTFIELD_TAG_NAME 100
#define TEXTFIELD_TAG_CITY 101
#define TEXTFIELD_TAG_ZIP 102
#define TEXTFIELD_TAG_CATEGORY 103
#define TEXTFIELD_TAG_CITY_SEARCH 104
#define BUTTON_CITY_CLEAR 200
#define BUTTON_CATEGORY_CLEAR 201
#define ACCEPTABLE_CHARECTERS                                                  \
  @" ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

@interface SearchViewController () {
  CGRect keyboardFrameBeginRect;
  UITextField *activeTextField;
  NSUserDefaults *objDefaults;
  NSString *strDistance;
}
@end

@implementation SearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
    self.title = @"";
  }
  return self;
}

#pragma mark - Life cycle

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  self.navigationController.navigationBar.tintColor =
      UIColorFromRGB(COLOR_LIGHT_BLUE);
    
    UILabel *lable = [[UILabel alloc] init];
    lable.frame = self.navigationController.navigationBar.frame;
    lable.numberOfLines = 2;
    lable.text = @"Advanced Search";
    [lable sizeToFit];
    lable.textColor = [UIColor grayColor];
    lable.font = [UIFont fontWithName:kAppSupportedFontBold size:16.0f];
    self.navigationItem.titleView = lable;
    
  latString = @"";
  lngString = @"";
  arrCategory = [[NSMutableArray alloc] init];
  arrEvents = [[NSMutableArray alloc] init];
  id data = [[NSUserDefaults standardUserDefaults] objectForKey:@"Categories"];
  arrCategory = [NSKeyedUnarchiver unarchiveObjectWithData:data];
  if ([arrCategory count] > 0) {
    Categories *info = [arrCategory objectAtIndex:0];
    strCategory = info.cat_name;
    category_id = [NSString stringWithFormat:@"%ld", (long)info.cat_id];
  }

  [_lblTitle setFont:[UIFont fontWithName:kAppSupportedFontLight size:22.f]];
  [_txtCategory setPlaceholder:@"Category"];
  [_txtEventName setPlaceholder:@"Event Name"];
  [_txtCity setPlaceholder:@"City"];
  [_txtZipcode setPlaceholder:@"Zip Code"];

  [_txtCategory setFont:[UIFont fontWithName:kAppSupportedFontNormal size:16.f]];
  [_txtEventName setFont:[UIFont fontWithName:kAppSupportedFontNormal size:16.f]];
  [_txtCity setFont:[UIFont fontWithName:kAppSupportedFontNormal size:16.f]];
  [_txtZipcode setFont:[UIFont fontWithName:kAppSupportedFontNormal size:16.f]];
  [_txtSearchCity setFont:[UIFont fontWithName:kAppSupportedFontNormal size:16.f]];
  [_lblDistance setFont:[UIFont fontWithName:kAppSupportedFontNormal size:16.f]];

  [_txtCategory.layer setMasksToBounds:YES];
  [_txtCategory.layer setCornerRadius:5.0f];
  _txtCategory.backgroundColor = [UIColor colorWithRed:230.0f / 255.0f
                                                 green:230.0f / 255.0f
                                                  blue:230.0f / 255.0f
                                                 alpha:1.0];

  [_txtEventName.layer setMasksToBounds:YES];
  [_txtEventName.layer setCornerRadius:5.0f];
  _txtEventName.backgroundColor = [UIColor colorWithRed:230.0f / 255.0f
                                                  green:230.0f / 255.0f
                                                   blue:230.0f / 255.0f
                                                  alpha:1.0];

  [_txtCity.layer setMasksToBounds:YES];
  [_txtCity.layer setCornerRadius:5.0f];
  _txtCity.backgroundColor = [UIColor colorWithRed:230.0f / 255.0f
                                             green:230.0f / 255.0f
                                              blue:230.0f / 255.0f
                                             alpha:1.0];

  [_txtZipcode.layer setMasksToBounds:YES];
  [_txtZipcode.layer setCornerRadius:5.0f];
  _txtZipcode.backgroundColor = [UIColor colorWithRed:230.0f / 255.0f
                                                green:230.0f / 255.0f
                                                 blue:230.0f / 255.0f
                                                alpha:1.0];

  [_btnSearch.layer setCornerRadius:5.0f];
  [_btnSearch.layer setMasksToBounds:YES];
  [_btnSearch.titleLabel setFont:[UIFont fontWithName:kAppSupportedFontNormal size:22]];

  [_btnsaveSearch.layer setCornerRadius:5.0f];
  [_btnsaveSearch.layer setMasksToBounds:YES];
  [_btnsaveSearch.titleLabel setFont:[UIFont fontWithName:kAppSupportedFontNormal size:22]];

  _resultTableData = [[NSMutableArray alloc] init];
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(textFieldTextDidChange:)
             name:UITextFieldTextDidChangeNotification
           object:_txtSearchCity];
  _scrollView.contentSize = CGSizeMake(320, self.view.frame.size.height);

  [self registerForKeyboardNotifications];

  objDefaults = [NSUserDefaults standardUserDefaults];
  if (objDefaults) {
    NSString *strCatID = [objDefaults valueForKey:@"cat_ID"];
    if (strCatID && ![strCatID isEqualToString:@""]) {
      category_id = strCatID;
    }
    NSString *strCatName = [objDefaults valueForKey:@"cat_Name"];
    if (strCatName && ![strCatName isEqualToString:@""]) {
      strCategory = strCatName;
    }
    NSString *city = [objDefaults valueForKey:@"city"];
    NSString *eventName = [objDefaults valueForKey:@"eventName"];
    NSString *zipcode = [objDefaults valueForKey:@"zipcode"];
    latString = [objDefaults valueForKey:@"latittude"];
    lngString = [objDefaults valueForKey:@"longitude"];
    strDistance = [objDefaults valueForKey:@"distance"];
    if (strCatID.length > 0 || strCatName.length > 0 || city.length > 0 ||
        eventName.length > 0 || zipcode.length > 0 || strDistance != nil) {
      if (strCatID.length > 0 && strCatName.length > 0)
        _txtCategory.text = strCategory;
      _txtCity.text = city;
      _txtEventName.text = eventName;
      _txtZipcode.text = zipcode;
      [_btnsaveSearch setTitle:@"Reset Search" forState:UIControlStateNormal];
    }
    if (strDistance != nil && ![strDistance isEqualToString:@""])
      _distanceSlider.value = round([strDistance floatValue]);
    else
      _distanceSlider.value = 25;
  }

  strDistance =
      [NSString stringWithFormat:@"%0.f", round(_distanceSlider.value)];
  if ([strDistance isEqualToString:@"1"])
    _lblDistance.text = [NSString stringWithFormat:@"%@ mile", strDistance];
  else
    _lblDistance.text = [NSString stringWithFormat:@"%@ miles", strDistance];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  appdelegate.sideMenuContainerVC.panMode = MFSideMenuPanModeNone;
  appdelegate.sideMenuContainerForLogin.panMode = MFSideMenuPanModeNone;
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  appdelegate.sideMenuContainerVC.panMode = MFSideMenuPanModeDefault;
  appdelegate.sideMenuContainerForLogin.panMode = MFSideMenuPanModeDefault;
}
- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}
- (void)viewDidUnload {
  [super viewDidUnload];
  activeTextField = nil;
  _scrollView = nil;
  [self unregisterForKeyboardNotifications];
}

#pragma mark -Action events

- (IBAction)btnSearchClicked:(id)sender {
  //    'lat','lng','distance','zipcode','event_title','start_date','end_date','price','cat_id'
  //
  //    Search with Cityname: 'lat','lng','distance'
  //    Search with Zipcode: 'distance','zipcode'
  //    Search with Event title: 'event_title'
  //    Search by Date: 'start_date','end_date'
  //    Search by Paid: 'price'
  //    Search by Category: 'cat_id'
  NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];

  NSString *user_id =
      [[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"];
  NSString *token =
      [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
  [parameters setObject:user_id forKey:@"user_id"];
  [parameters setObject:token forKey:@"token"];

  // Category
  if (_txtCategory.text.length > 0) {
    [parameters setObject:category_id forKey:@"cat_id"];
  } else {
    [parameters setObject:@"" forKey:@"cat_id"];
  }

  // Event title
  if (_txtEventName.text.length > 0) {
    [parameters setObject:_txtEventName.text forKey:@"event_title"];
  } else {
    [parameters setObject:@"" forKey:@"event_title"];
  }

  // Latitude && Longitude

  if (_txtCity.text.length > 0) {
    NSString *strCity = nil;
    if (cityRegion) {
      latString =
          [NSString stringWithFormat:@"%.5f", cityRegion.coordinate.latitude];
      lngString =
          [NSString stringWithFormat:@"%.5f", cityRegion.coordinate.longitude];
      strCity = [NSString stringWithFormat:@"%@", cityRegion.cityName];
    }
  } else {
    CLLocation *location =
        [LocationManagerSingleton sharedSingleton].locationManager.location;
    latString = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
    lngString =
        [NSString stringWithFormat:@"%f", location.coordinate.longitude];
  }
  if (latString != nil && lngString != nil) {
    [parameters setObject:latString forKey:@"lat"];
    [parameters setObject:lngString forKey:@"lng"];
  } else {
    [parameters setObject:@"" forKey:@"lat"];
    [parameters setObject:@"" forKey:@"lng"];
  }
  // Zipcode
  if (_txtZipcode.text.length > 0) {
    [parameters setObject:_txtZipcode.text forKey:@"zipcode"];
    [parameters setObject:@"" forKey:@"lat"];
    [parameters setObject:@"" forKey:@"lng"];
  } else {
    [parameters setObject:@"" forKey:@"zipcode"];
  }

  // Distance
  [parameters setObject:strDistance forKey:@"distance"];

  hud = [[MBProgressHUD alloc] initWithView:self.view];
  [self.view addSubview:hud];
  [hud show:YES];
  [self searchEvents:parameters];
}

- (IBAction)btnDropdownClicked:(id)sender {
  [self.view endEditing:YES];
  strCategory = @"";
  if ([arrCategory count] > 0) {
    Categories *info = [arrCategory objectAtIndex:0];
    strCategory = info.cat_name;
    category_id = [NSString stringWithFormat:@"%ld", (long)info.cat_id];
  }
  [_categoryPickerView setHidden:NO];
}

- (IBAction)btnCloseClicked:(id)sender {
  _txtSearchCity.text = @"";
  [_scrollView setScrollEnabled:YES];
  if ([_resultTableData count] > 0)
    [_resultTableData removeAllObjects];
  [_tblCities setHidden:YES];
  [UIView animateWithDuration:0.40
                   animations:^{
                       _cityView.frame =
                           CGRectMake(10, -320, _cityView.frame.size.width,
                                      _cityView.frame.size.height);
                   }];
  if (_txtCity.text.length > 0) {
    [_btnClear setHidden:NO];
  }
  [self.view endEditing:YES];
}

- (IBAction)btnCityClicked:(id)sender {
  //[_cityView setHidden:NO];
  [_txtSearchCity becomeFirstResponder];
  [_scrollView setContentOffset:CGPointMake(0, 0)];
  [_scrollView setScrollEnabled:NO];
  [UIView animateWithDuration:0.40
                   animations:^{
                       _cityView.frame =
                           CGRectMake(10, 10, _cityView.frame.size.width,
                                      _cityView.frame.size.height);
                   }];
}

- (IBAction)btnClearClicked:(id)sender {
  UIButton *btn = (UIButton *)sender;
  if (btn.tag == BUTTON_CITY_CLEAR) {
    if (_txtCity.text.length > 0) {
      _txtCity.text = @"";
      [_btnClear setHidden:YES];
    }

  } else {
    if (_txtCategory.text.length > 0) {
      _txtCategory.text = @"";
      [_imgDropDown setHidden:NO];
      [_btnCat_Clear setHidden:YES];
    }
  }
}

- (IBAction)cancelPicker:(id)sender {

  [_categoryPickerView setHidden:YES];
}

- (IBAction)donePicker:(id)sender {
  _txtCategory.text = strCategory;
  [_categoryPickerView setHidden:YES];
  [_imgDropDown setHidden:YES];
  [_btnCat_Clear setHidden:NO];
}

- (IBAction)btnLocationClicked:(id)sender {

  if ([LocationManagerSingleton locationServicesEnabled]) {
    [_activity startAnimating];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder
        reverseGeocodeLocation:[LocationManagerSingleton sharedSingleton]
                                   .locationManager.location
             completionHandler:^(NSArray *placemarks, NSError *error) {
                 if (error) {
                   [TSMessage
                       setDefaultViewController:self.navigationController];
                   [TSMessage
                       showNotificationWithTitle:
                           @"Error" subtitle:@"Unable to get current location."
                                            type:
                                                TSMessageNotificationTypeError];
                 } else {
                   if ([placemarks count] > 0) {
                     CLPlacemark *placemark = [placemarks objectAtIndex:0];
                       NSString *strCountry = [placemark.addressDictionary objectForKey:@"Country"];
                       if([strCountry isEqualToString:@"United States"])
                       {
                           _txtCity.text =
                           [placemark.addressDictionary objectForKey:@"City"];
                           _txtZipcode.text =
                           [placemark.addressDictionary objectForKey:@"ZIP"];
                           [_btnLocation
                            setImage:[UIImage imageNamed:@"search-event-active"]
                            forState:UIControlStateNormal];
                       }
                       else
                       {
                           _txtCity.text = @"";
                           _txtZipcode.text = @"";
                       }

                     if (!(_txtCity.text.length > 0) &&
                         !(_txtZipcode.text.length > 0)) {
                       [TSMessage
                           setDefaultViewController:self.navigationController];
                       [TSMessage
                           showNotificationWithTitle:@"Error"
                                            subtitle:@"This facility is not "
                                            @"provided for your " @"region."
                                                type:
                                                    TSMessageNotificationTypeError];
                       [_btnLocation
                           setImage:[UIImage imageNamed:@"search-event"]
                           forState:UIControlStateNormal];
                     }

                   } else {
                     [TSMessage
                         setDefaultViewController:self.navigationController];
                     [TSMessage
                         showNotificationWithTitle:@"Error"
                                          subtitle:@"No place found."
                                              type:
                                                  TSMessageNotificationTypeError];
                   }
                 }

                 [_activity stopAnimating];
             }];
  } else {
    [TSMessage setDefaultViewController:self.navigationController];
    [TSMessage
        showNotificationWithTitle:@"Location Services Denied"
                         subtitle:@"SNAPprints requires access to your "
                         @"device's location services.\n\nPlease "
                         @"enable location services access for this "
                         @"app in Settings / Privacy / Location " @"Services."
                             type:TSMessageNotificationTypeWarning];
  }
}

- (IBAction)btnSaveSearchClicked:(id)sender {
  if ([_btnsaveSearch.titleLabel.text isEqualToString:@"Save Search"]) {
    isResetFromSearch = NO;
    [_btnsaveSearch setTitle:@"Reset Search" forState:UIControlStateNormal];
    if (_txtCategory.text.length > 0) {
      [objDefaults setObject:category_id forKey:@"cat_ID"];
      [objDefaults setObject:strCategory forKey:@"cat_Name"];
    }
    if (_txtZipcode.text.length > 0) {
      [objDefaults setObject:_txtZipcode.text forKey:@"zipcode"];
    }
    if (_txtEventName.text.length > 0) {
      [objDefaults setObject:_txtEventName.text forKey:@"eventName"];
    }
    if (_txtCity.text.length > 0) {
      NSString *strCity;
      if (cityRegion) {
        latString =
            [NSString stringWithFormat:@"%.5f", cityRegion.coordinate.latitude];
        lngString = [NSString
            stringWithFormat:@"%.5f", cityRegion.coordinate.longitude];
        strCity = [NSString stringWithFormat:@"%@", cityRegion.cityName];

      } else
        strCity = _txtCity.text;

      [objDefaults setObject:strCity forKey:@"city"];
      [objDefaults setObject:latString forKey:@"latittude"];
      [objDefaults setObject:lngString forKey:@"longitude"];
    }
    [objDefaults setObject:strDistance forKey:@"distance"];
  } else {
    isResetFromSearch = YES;
    [_btnsaveSearch setTitle:@"Save Search" forState:UIControlStateNormal];
    [_btnLocation setImage:[UIImage imageNamed:@"search-event"]
                  forState:UIControlStateNormal];
    _txtCategory.text = @"";
    _txtEventName.text = @"";
    _txtCity.text = @"";
    _txtZipcode.text = @"";
    _distanceSlider.value = 25.f;
    strDistance = [NSString stringWithFormat:@"%0.f", _distanceSlider.value];
    _lblDistance.text =
        [NSString stringWithFormat:@"%0.f miles", _distanceSlider.value];
    [objDefaults removeObjectForKey:@"cat_ID"];
    [objDefaults removeObjectForKey:@"cat_Name"];
    [objDefaults removeObjectForKey:@"zipcode"];
    [objDefaults removeObjectForKey:@"city"];
    [objDefaults removeObjectForKey:@"eventName"];
    [objDefaults removeObjectForKey:@"latittude"];
    [objDefaults removeObjectForKey:@"longitude"];
    [objDefaults removeObjectForKey:@"distance"];
    [objDefaults synchronize];
  }
}

- (IBAction)distanceValueChanged:(id)sender {

  strDistance =
      [NSString stringWithFormat:@"%0.f", round(_distanceSlider.value)];
  if ([strDistance isEqualToString:@"1"])
    _lblDistance.text = [NSString stringWithFormat:@"%@ mile", strDistance];
  else
    _lblDistance.text = [NSString stringWithFormat:@"%@ miles", strDistance];
}

#pragma mark
#pragma mark - UIPickerDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {

  return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView
    numberOfRowsInComponent:(NSInteger)component {

  return [arrCategory count];
}

- (NSString *)pickerView:(UIPickerView *)thePickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component {

  Categories *cat_Info = [arrCategory objectAtIndex:row];
  return cat_Info.cat_name;
}

- (void)pickerView:(UIPickerView *)thePickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component {

  Categories *cat_Info = [arrCategory objectAtIndex:row];
  strCategory = cat_Info.cat_name;
  category_id = [NSString stringWithFormat:@"%ld", (long)cat_Info.cat_id];
}

#pragma mark
#pragma mark - Tableview Datasource or delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
  return [_resultTableData count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *cellIdentifier = @"Cell";
  UITableViewCell *cell =
      [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  Region *region;
  region = [_resultTableData objectAtIndex:indexPath.row];
  if (region) {
    NSString *CellIdentifier = @"CityCellIdentifier";
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                    reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [NSString
        stringWithFormat:@"%@, %@", region.cityName, region.stateCode];
    [cell.textLabel setFont:[UIFont fontWithName:kAppSupportedFontNormal size:16.f]];
    [cell.textLabel setTextColor:[UIColor darkGrayColor]];
    // cell.textLabel.text = [NSString stringWithFormat:@"%@", region.cityName];
  }
  return cell;
}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  cityRegion = [_resultTableData objectAtIndex:indexPath.row];
  if (_txtCity.text.length > 0 && _txtZipcode.text.length > 0) {
    _txtCity.text = @"";
    _txtZipcode.text = @"";
  }
  _txtCity.text = [NSString
      stringWithFormat:@"%@, %@", cityRegion.cityName, cityRegion.stateCode];
  [_btnLocation setImage:[UIImage imageNamed:@"search-event"]
                forState:UIControlStateNormal];
  [_btnLocation setEnabled:YES];

  [self btnCloseClicked:nil];
}

#pragma mark
#pragma mark - Textfield delegates

- (void)textFieldDidBeginEditing:(UITextField *)textField {
  [_categoryPickerView setHidden:YES];
  activeTextField = textField;
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
  activeTextField = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {

  if (textField.tag == TEXTFIELD_TAG_CITY_SEARCH)
    return YES;

  [textField resignFirstResponder];
  return YES;
}

- (void)textFieldTextDidChange:(NSNotification *)notification {
  UITextField *textfield = [notification object];
  if (textfield.tag == TEXTFIELD_TAG_CITY_SEARCH) {
    if (!isiPhone5) {
      float keyboardHeight = keyboardFrameBeginRect.size.height;
      float diff = (_cityView.frame.origin.y + _tblCities.frame.origin.y +
                    _tblCities.frame.size.height) -
                   keyboardHeight;
      [_tblCities setFrame:CGRectMake(_tblCities.frame.origin.x,
                                      _tblCities.frame.origin.y,
                                      _tblCities.frame.size.width,
                                      _tblCities.frame.size.height - diff)];
    }
  }

  if (textfield.text.length > 0 &&
      !isnumber([textfield.text characterAtIndex:0]) &&
      textfield.text.length > 2) { // We are searching for a string
    NSString *searchText = [textfield.text urlencode];
    [_activityIndicator startAnimating];
    NSString *urlString =
        [NSString stringWithFormat:@"http://ws.geonames.org/"
                                   @"searchJSON?name_startsWith=%@&country=US&"
                                   @"maxRows=5&username=akozlik",
                                   searchText];

    if (_operation) {
      [_operation cancel];
    }
    //[_activityIndicator startAnimating];

    NSURLRequest *request =
        [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation
        JSONRequestOperationWithRequest:request
        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {

            [self.resultTableData removeAllObjects];

            NSArray *geonames = [JSON objectForKey:@"geonames"];

            for (NSDictionary *dict in geonames) {
              Region *region = [[Region alloc] init];
              region.stateCode = [dict objectForKey:@"adminCode1"];
              region.stateName = [dict objectForKey:@"adminName1"];
              region.countryCode = [dict objectForKey:@"countryCode"];
              region.countryName = [dict objectForKey:@"countryName"];
              region.cityName = [dict objectForKey:@"name"];
              region.coordinate = CLLocationCoordinate2DMake(
                  [[dict objectForKey:@"lat"] floatValue],
                  [[dict objectForKey:@"lng"] floatValue]);

              [self.resultTableData addObject:region];
            }
            [_tblCities setHidden:NO];
            [_activityIndicator stopAnimating];
            [_tblCities reloadData];
        }
        failure:^(NSURLRequest *request, NSHTTPURLResponse *response,
                  NSError *error, id JSON) {
            [_activityIndicator stopAnimating];
            [_tblCities setHidden:YES];
        }];

    [operation start];
  } else {
    if ([_resultTableData count] > 0)
      [_resultTableData removeAllObjects];
    [_tblCities reloadData];
    [_tblCities setHidden:YES];
    [_activityIndicator stopAnimating];
  }
}

- (BOOL)textField:(UITextField *)textField
    shouldChangeCharactersInRange:(NSRange)range
                replacementString:(NSString *)string {
  if (textField.tag == TEXTFIELD_TAG_ZIP) {
    NSString *currentString =
        [textField.text stringByReplacingCharactersInRange:range
                                                withString:string];
    NSCharacterSet *nonNumberSet =
        [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    long length = [currentString length];
    if (length > 5 ||
        [string rangeOfCharacterFromSet:nonNumberSet].location != NSNotFound) {
      return NO;
    }
    return YES;
  } else if (textField.tag == TEXTFIELD_TAG_CITY_SEARCH) {
    NSString *currentString =
        [textField.text stringByReplacingCharactersInRange:range
                                                withString:string];
    // NSCharacterSet *nonNumberSet = [[NSCharacterSet letterCharacterSet]
    // invertedSet];
    NSCharacterSet *nonNumberSet = [[NSCharacterSet
        characterSetWithCharactersInString:ACCEPTABLE_CHARECTERS] invertedSet];
    if ([currentString rangeOfCharacterFromSet:nonNumberSet].location !=
        NSNotFound) {
      return NO;
    }
    return YES;
  } else
    return YES;
}

#pragma mark - Custom Methods

/*
 Function: showPicker
 Decription: Displays picker.
 Return: void
 */
- (void)showPicker {
  CGRect rect1 = _categoryPickerView.frame;
  CGFloat height = [UIScreen mainScreen].bounds.size.height;
  CGFloat cord = 206.0;
  _categoryPickerView.frame = CGRectMake(
      0, height - cord, CGRectGetWidth(rect1), CGRectGetHeight(rect1));
  [_categoryPickerView setHidden:NO];
  [self.view endEditing:YES];
}

/*
 Function: popControllerToSpecified
 Decription: Removes specific controller from navigation controller's stack.
 Return: void
 Param: NSString
 */
- (void)popControllerToSpecified:(NSString *)className {
    
    UINavigationController *navController = self.navigationController;
    
    for (NSInteger i = 0; i < [navController.viewControllers count]; i++) {
        
        UIViewController *controller =
        [navController.viewControllers objectAtIndex:i];
        
        if ([controller.nibName isEqualToString:className]) {
            [navController popToViewController:controller animated:YES];
            return;
        }
    }
}

#pragma mark - API Call
/*
 Function: searchEvents
 Decription: Returns the events based on search criteria.
 Return: void
 Param: NSMutableDictionary
 */
- (void)searchEvents:(NSMutableDictionary *)parameters {
  isResetFromSearch = NO;
  [[SnapprintsClient sharedSnapprintsClient]
      getPath:@"events/advanced_search.json"
      parameters:parameters
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          id response = [responseObject objectForKey:@"status"];
          if ([response isEqualToString:@"error"]) {
            [hud hide:YES];
            UIAlertView *alert = [[UIAlertView alloc]
                    initWithTitle:@"SNAPprints"
                          message:[responseObject objectForKey:@"message"]
                         delegate:nil
                cancelButtonTitle:@"OK"
                otherButtonTitles:nil, nil];
            [alert show];
          } else {
            // Save search parameters
            if ([parameters objectForKey:@"cat_id"])
              [objDefaults setObject:[parameters objectForKey:@"cat_id"]
                              forKey:@"cat_ID"];
            if ([parameters objectForKey:@"event_title"])
              [objDefaults setObject:[parameters objectForKey:@"event_title"]
                              forKey:@"eventName"];
            if ([parameters objectForKey:@"lat"])
              [objDefaults setObject:[parameters objectForKey:@"lat"]
                              forKey:@"latittude"];
            if ([parameters objectForKey:@"lng"])
              [objDefaults setObject:[parameters objectForKey:@"lng"]
                              forKey:@"longitude"];
            if ([parameters objectForKey:@"zipcode"])
              [objDefaults setObject:[parameters objectForKey:@"zipcode"]
                              forKey:@"zipcode"];
            if ([parameters objectForKey:@"distance"])
              [objDefaults setObject:[parameters objectForKey:@"distance"]
                              forKey:@"distance"];
            if (_txtCity.text.length > 0)
              [objDefaults setObject:_txtCity.text forKey:@"city"];
            else
              [objDefaults removeObjectForKey:@"city"];
            if (_txtCategory.text.length > 0)
              [objDefaults setObject:_txtCategory.text forKey:@"cat_Name"];
            else
              [objDefaults removeObjectForKey:@"cat_Name"];

            [objDefaults synchronize];
            //

            NSLog(@"%@", responseObject);
            NSArray *events = [responseObject objectForKey:@"events"];

            if ([arrEvents count] > 0)
              [arrEvents removeAllObjects];

            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"YYYY-MM-dd HH:mm:ss"];

            for (NSDictionary *eventsContainerDict in events) {
              NSDictionary *dict = [eventsContainerDict objectForKey:@"Event"];

              Event *event = [[Event alloc] init];
              Company *company = [[Company alloc] init];
              Address *address = [[Address alloc] init];
              User *user = [[User alloc] init];
              event.type = @"E";
              address.address1 = [dict objectForKey:@"address1"];
              address.address2 = [dict objectForKey:@"address2"];
              address.city = [dict objectForKey:@"city"];
              address.state = [dict objectForKey:@"state"];
              address.zip = [dict objectForKey:@"zip"];

              if (![[dict objectForKey:@"company_id"]
                      isKindOfClass:[NSNull class]])
                company.companyId =
                    [[dict objectForKey:@"company_id"] integerValue];

              company.name = [dict objectForKey:@"company_name"];

              if (![[dict objectForKey:@"user_id"]
                      isKindOfClass:[NSNull class]])
                user.userId = [[dict objectForKey:@"user_id"] integerValue];

              // Get event creator's name
              if (![[dict objectForKey:@"created_by"]
                      isKindOfClass:[NSNull class]])
                user.username = [dict objectForKey:@"created_by"];
              else
                user.username = @"";

              event.address = address;
              event.company = company;
              event.eventUser = user;

              NSLog(@"Price:%@", [dict objectForKey:@"price"]);
              if ([[dict objectForKey:@"price"] isKindOfClass:[NSNull class]] ||
                  [[dict objectForKey:@"price"] length] == 0) {

                event.price = [NSNumber numberWithFloat:0.00];
              } else {

                event.price = [dict objectForKey:@"price"];
              }

              if ([[dict objectForKey:@"photo_limit"]
                      isKindOfClass:[NSNull class]]) {
                event.photoLimit = 10;
              } else {
                event.photoLimit =
                    [[dict objectForKey:@"photo_limit"] integerValue];
              }

              event.eventId = [[dict objectForKey:@"id"] integerValue];

              event.title = [dict objectForKey:@"title"];
              event.description = [dict objectForKey:@"description"];
              event.isPrivate = [[dict objectForKey:@"private"] boolValue];
              event.eventStartDateTime =
                  [df dateFromString:[dict objectForKey:@"event_start_time"]];
              event.eventEndDateTime =
                  [df dateFromString:[dict objectForKey:@"event_end_time"]];

              event.created =
                  [df dateFromString:[dict objectForKey:@"created"]];
              event.updated =
                  [df dateFromString:[dict objectForKey:@"updated"]];

              if (![[dict objectForKey:@"thumbnail"]
                      isKindOfClass:[NSNull class]])
                event.thumbnail = [dict objectForKey:@"thumbnail"];
              else
                event.thumbnail = @"";

              NSArray *photos = [eventsContainerDict objectForKey:@"Photo"];

              if ([photos count] > 0) {
                for (NSDictionary *photoDict in photos) {
                  Photo *photo = [[Photo alloc] init];
                  photo.filename = [photoDict objectForKey:@"filename"];
                  photo.thumbnail_filename =
                      [photoDict objectForKey:@"thumbnail"];
                  photo.photoID = [[photoDict objectForKey:@"id"] integerValue];
                  photo.published = [photoDict objectForKey:@"published"];
                  photo.is_deleted = [photoDict objectForKey:@"is_deleted"];

                  photo.user = [[User alloc] init];

                  if (![[photoDict objectForKey:@"user_id"]
                          isKindOfClass:[NSNull class]]) {
                    photo.user.userId =
                        [[photoDict objectForKey:@"user_id"] integerValue];
                  }
                  if (![photo.filename isEqualToString:@""] &&
                      ![photo.thumbnail_filename isEqualToString:@""])
                      if ([photo.is_deleted isEqualToString:@"0"]) {
                          [event.photos addObject:photo];
                      }
                    
                }
              }

              NSDictionary *distanceDict =
                  [eventsContainerDict objectForKey:@"0"];

              if (![[distanceDict objectForKey:@"distance"]
                      isKindOfClass:[NSNull class]]) {
                event.distance =
                    [[distanceDict objectForKey:@"distance"] floatValue];
              } else {
                event.distance = -5;
              }
              /*
               EC =             {
               "category_id" = 9;
               }

             */
              NSDictionary *categoryDict =
                  [eventsContainerDict objectForKey:@"EC"];
              NSString *strCategoryId =
                  [categoryDict objectForKey:@"category_id"];
              if ([strCategoryId isKindOfClass:[NSNull class]])
                event.category_Id = @"";
              else
                event.category_Id = strCategoryId;

              [arrEvents addObject:event];
            }
            if ([arrEvents count] > 0) {
              [self.delegate advancedSearchData:arrEvents];
              [self.view endEditing:YES];
              [self btnCloseClicked:nil];
              [hud hide:YES];
              [self popControllerToSpecified:@"EventListViewController"];
            } else {
              [hud hide:YES];
              [self.view endEditing:YES];
              [self btnCloseClicked:nil];
              UIAlertView *alert =
                  [[UIAlertView alloc] initWithTitle:@"SNAPprints"
                                             message:@"No results found"
                                            delegate:nil
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil, nil];
              [alert show];
            }
          }
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          NSLog(@"%@", error.description);
          [hud hide:YES];
      }];
}

#pragma mark - Notification methode for keyboard
- (void)getKeyboardHeight:(NSNotification *)notification {
  NSDictionary *keyboardInfo = [notification userInfo];
  NSValue *keyboardFrameBegin =
      [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
  keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
}

- (void)keyboardWillShown:(NSNotification *)aNotification {
  NSDictionary *info = [aNotification userInfo];
  NSValue *keyboardFrameBegin =
      [info valueForKey:UIKeyboardFrameBeginUserInfoKey];
  keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
  CGPoint point = CGPointMake(0, activeTextField.frame.size.height);
  [_scrollView setContentOffset:point];
}

- (void)keyboardWillHide:(NSNotification *)aNotification {
  [_scrollView setContentOffset:CGPointMake(0, 0)];
}
#pragma mark - event of keyboard relative methods
- (void)registerForKeyboardNotifications {
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(getKeyboardHeight:)
             name:UIKeyboardDidShowNotification
           object:nil];

  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(keyboardWillShown:)
             name:UIKeyboardWillShowNotification
           object:nil];

  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(keyboardWillHide:)
             name:UIKeyboardWillHideNotification
           object:nil];
}

- (void)unregisterForKeyboardNotifications {
  [[NSNotificationCenter defaultCenter]
      removeObserver:self
                name:UIKeyboardWillShowNotification
              object:nil];
  // unregister for keyboard notifications while not visible.
  [[NSNotificationCenter defaultCenter]
      removeObserver:self
                name:UIKeyboardWillHideNotification
              object:nil];
}

@end
