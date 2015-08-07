//
//  InviteVC.m
//  SNAPprints
//
//  Created by Etay Luz on 27/06/14.
//  Copyright (c) 2014 Etay Luz. All rights reserved.
//

#import "InviteVC.h"
#import "MFSideMenu.h"
#import "UIImage+ProportionalFill.h"
#import "TSMessage.h"
#import "ConstantFlags.h"

#define TABLE_HEADER_HEIGHT 35

@interface InviteVC () {
  BOOL isSearched;
}
@property(strong, nonatomic) NSMutableArray *arrSearchEmails;

@property(weak, nonatomic) IBOutlet UIImageView *imgSearchbar;

@property(weak, nonatomic) IBOutlet UITextField *txtSearchBar;

@end

@implementation InviteVC

static NSString *cellIdentifier = @"InviteCell";

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
    self.title = @"";
  }
  return self;
}
#pragma mark
#pragma mark - Life cycle methods
- (void)viewDidLoad {
  [super viewDidLoad];
  [_lblErrorMessage setHidden:YES];
  [_lblErrorMessage setFont:[UIFont fontWithName:kAppSupportedFontLight size:17.f]];
  self.navigationController.navigationBar.tintColor =
      UIColorFromRGB(COLOR_LIGHT_BLUE);
  // Do any additional setup after loading the view from its nib.
  //[self.tblEmail registerClass:[InviteCell class]
  //forCellReuseIdentifier:cellIdentifier];
  if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
    self.edgesForExtendedLayout = UIRectEdgeNone;
  }

  UIButton *btnR = [UIButton buttonWithType:UIButtonTypeCustom];
  btnR.bounds = CGRectMake(0, 0, 30, 30);
  [btnR setBackgroundImage:[UIImage imageNamed:@"refresh"]
                  forState:UIControlStateNormal];
  [btnR addTarget:self
                action:@selector(btnRefreshClicked:)
      forControlEvents:UIControlEventTouchUpInside];
  UIBarButtonItem *btnRefresh =
      [[UIBarButtonItem alloc] initWithCustomView:btnR];
  self.navigationItem.rightBarButtonItem = btnRefresh;
    
    UILabel *lable = [[UILabel alloc] init];
    lable.frame = self.navigationController.navigationBar.frame;
    lable.numberOfLines = 2;
    lable.text = @"Contacts";
    [lable sizeToFit];
    lable.textColor = [UIColor grayColor];
    lable.font = [UIFont fontWithName:kAppSupportedFontBold size:16.0f];
    self.navigationItem.titleView = lable;
    
  _arrEmails = [[NSMutableArray alloc] init];
  _arrSelected = [[NSMutableArray alloc] init];
  _arrSearchEmails = [[NSMutableArray alloc] init];

  [_imgSearchbar.layer setCornerRadius:5.f];
  [_imgSearchbar.layer setMasksToBounds:YES];
  [_txtSearchBar setPlaceholder:@"Search by Name"];

  [self.searchDisplayController.searchResultsTableView
      setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(textFieldTextDidChange:)
             name:UITextFieldTextDidChangeNotification
           object:_txtSearchBar];

  _dbClass = [[SqliteDBClass alloc] init];
  AppDelegate *appdelegate =
      (AppDelegate *)[[UIApplication sharedApplication] delegate];
  _hud = [[MBProgressHUD alloc] initWithView:appdelegate.window];
  _hud.labelText = @"Fetching Contacts...";
  _hud.delegate = self;
  [appdelegate.window addSubview:_hud];
  [_hud showWhileExecuting:@selector(getContacts)
                  onTarget:self
                withObject:nil
                  animated:YES];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
}
#pragma mark
#pragma mark - Action events

- (IBAction)btnInviteClicked:(id)sender {
  NSLog(@"%@", _arrSelected);
  AppDelegate *appdelegate =
      (AppDelegate *)[[UIApplication sharedApplication] delegate];
  _hud = [[MBProgressHUD alloc] initWithView:appdelegate.window];
  _hud.labelText = @"Sending Invitation...";
  _hud.delegate = self;
  [appdelegate.window addSubview:_hud];
  [_hud show:YES];
  [self sendInvitation:_arrSelected];
}

- (IBAction)btnRefreshClicked:(id)sender {
  [_lblErrorMessage setHidden:YES];
  _txtSearchBar.text = @"";
  [_txtSearchBar resignFirstResponder];
  [_tblEmail setContentOffset:_tblEmail.contentOffset animated:NO];
  [_tblEmail setScrollEnabled:NO]; // Added for crashing issue
  AppDelegate *appdelegate =
      (AppDelegate *)[[UIApplication sharedApplication] delegate];
  _hud = [[MBProgressHUD alloc] initWithView:appdelegate.window];
  // hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
  _hud.labelText = @"Refreshing contacts...";
  [appdelegate.window addSubview:_hud];

  [_hud showWhileExecuting:@selector(refreshContacts)
                  onTarget:self
                withObject:nil
                  animated:YES];
}

- (IBAction)btnSelectClicked:(id)sender {
  UIButton *btn = (UIButton *)sender;
  if ([btn isSelected])
    [btn setSelected:NO];
  else
    [btn setSelected:YES];
  [self checkUncheckAction:sender];
}

#pragma mark
#pragma mark - Custom  methods

/*
 Function: refreshContacts
 Decription: This method refreshes the contact list when user clicked on Refresh
 contacts.
 Return: Void
 */

- (void)refreshContacts {
  [_dbClass deleteContacts];
  if ([_arrEmails count] > 0) {
    [_arrEmails removeAllObjects];
  }
  if ([_arrSelected count] > 0) {
    [_arrSelected removeAllObjects];
    [_btnInvite setEnabled:NO];
  }

  NSArray *arr; //= [[NSArray alloc] init];
  arr = [self getAllContacts];
  [_dbClass insertForContacts:arr];
  _arrEmails = [_dbClass getContact];
  [_tblEmail reloadData];
  [_tblEmail setScrollEnabled:YES]; // Added for crashing issue
}
- (void)toggleLeft:(id)sender {
  [self.menuContainerViewController toggleLeftSideMenuCompletion:^{}];
}

/*
 Function: getAllContacts
 Decription: Insert fetched conatcts from device's contact list into database.
 Return: Void
 */

- (void)getContacts {
  _arrEmails = [_dbClass getContact];
  if ([_arrEmails count] == 0) {
    NSMutableArray *arrContact = [self getAllContacts];
    [_dbClass insertForContacts:arrContact];
    _arrEmails = [_dbClass getContact];
  }
  [_tblEmail reloadData];
}

/*
 Function: getAllContacts
 Decription: Fetches contacts from device's contact list.
 Return: Void
 */

- (NSMutableArray *)getAllContacts {

  CFErrorRef *error = nil;
  ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
  __block BOOL accessGranted = NO;

  if (ABAddressBookRequestAccessWithCompletion != NULL) { // we're on iOS 6

    dispatch_semaphore_t sema = dispatch_semaphore_create(0);

    ABAddressBookRequestAccessWithCompletion(addressBook,
                                             ^(bool granted, CFErrorRef error) {

        accessGranted = granted;
        dispatch_semaphore_signal(sema);
    });

    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);

  } else { // we're on iOS 5 or older

    accessGranted = YES;
  }

  if (accessGranted) {
    CFArrayRef allPeople =
        ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(
            addressBook, NULL, kABPersonSortByFirstName);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:nPeople];
    for (int i = 0; i < nPeople; i++) {

      NSLog(@"%d", i);
      ContactInformation *contacts = [[ContactInformation alloc] init];
      ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);

      ABRecordID recordID = ABRecordGetRecordID(person);
      contacts.contactId = [NSString stringWithFormat:@"%d", recordID];

      CFStringRef strFirst =
          (__bridge CFStringRef)((__bridge NSString *)ABRecordCopyValue(
              person, kABPersonFirstNameProperty));
      CFStringRef strLast =
          (__bridge CFStringRef)((__bridge NSString *)ABRecordCopyValue(
              person, kABPersonLastNameProperty));
      contacts.firstName = (__bridge NSString *)(strFirst);
      contacts.lastName = (__bridge NSString *)(strLast);
      if (!contacts.firstName) {

        contacts.firstName = @"";
      }
      if (!contacts.lastName) {

        contacts.lastName = @"";
      }

      contacts.userName = [NSString
          stringWithFormat:@"%@ %@", contacts.firstName, contacts.lastName];
      // NSData  *imgData = (__bridge NSData *)ABPersonCopyImageData(person);
      NSData *imgData = (__bridge NSData *)ABPersonCopyImageDataWithFormat(
          person, kABPersonImageFormatThumbnail);
      if ([imgData bytes] > 0) {

        NSArray *paths = NSSearchPathForDirectoriesInDomains(
            NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory =
            [paths objectAtIndex:0]; // Get documents folder
        NSString *dataPath =
            [documentsDirectory stringByAppendingPathComponent:@"/ImageFolder"];

        if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath]) {
          [[NSFileManager defaultManager] createDirectoryAtPath:dataPath
                                    withIntermediateDirectories:NO
                                                     attributes:nil
                                                          error:NULL];
        }

        NSString *savedImagePath = [dataPath
            stringByAppendingPathComponent:
                [NSString stringWithFormat:@"%@%@%d.jpg", contacts.firstName,
                                           contacts.lastName, i]];
        NSData *newImgData =
            [self reduceImageSize:[UIImage imageWithData:imgData]];
        [newImgData writeToFile:savedImagePath atomically:NO];
        contacts.imageUrlDocument = savedImagePath;
      } else {
        contacts.imageUrlDocument = @"";
      }
      // For Phone Number
      ABMultiValueRef multiPhones =
          ABRecordCopyValue(person, kABPersonPhoneProperty);
      for (CFIndex i = 0; i < ABMultiValueGetCount(multiPhones); i++) {
        ContactInformation *phoneContact = [[ContactInformation alloc] init];
        CFStringRef phoneNumberRef =
            ABMultiValueCopyValueAtIndex(multiPhones, i);
        NSString *phoneNumber = (__bridge NSString *)phoneNumberRef;
        NSString *strippedNumber = [phoneNumber
            stringByReplacingOccurrencesOfString:@"[^0-9+]"
                                      withString:@""
                                         options:NSRegularExpressionSearch
                                           range:NSMakeRange(
                                                     0, [phoneNumber length])];
        NSLog(@"%@", strippedNumber);
        phoneContact.contactId = contacts.contactId;
        phoneContact.firstName = contacts.firstName;
        phoneContact.lastName = contacts.lastName;
        phoneContact.userName = contacts.userName;
        phoneContact.imageUrlDocument = contacts.imageUrlDocument;
        phoneContact.phoneNo = strippedNumber;
        [items addObject:phoneContact];
        CFRelease(phoneNumberRef);
      }

      ABMultiValueRef multiEmails =
          ABRecordCopyValue(person, kABPersonEmailProperty);

      for (CFIndex i = 0; i < ABMultiValueGetCount(multiEmails); i++) {
        ContactInformation *emailContact = [[ContactInformation alloc] init];
        CFStringRef contactEmailRef =
            ABMultiValueCopyValueAtIndex(multiEmails, i);
        NSString *contactEmail = (__bridge NSString *)contactEmailRef;
        if ([contactEmail length] > 0)
          emailContact.emailAdd = contactEmail;
        emailContact.contactId = contacts.contactId;
        emailContact.firstName = contacts.firstName;
        emailContact.lastName = contacts.lastName;
        emailContact.userName = contacts.userName;
        emailContact.imageUrlDocument = contacts.imageUrlDocument;

        if (contactEmailRef != NULL) {

          CFRelease(contactEmailRef);
        }
        [items addObject:emailContact];
      }

      if (strLast != NULL)
        CFRelease(strLast);
      if (strFirst != NULL)
        CFRelease(strFirst);
      if ([imgData bytes] > 0)
        CFRelease((__bridge CFTypeRef)(imgData));
      CFRelease(multiEmails);
    }

    CFRelease(addressBook);
    CFRelease(allPeople);
    //[_hud removeFromSuperview];
    return items;

  } else {
    //[_hud removeFromSuperview];
    UIAlertView *alert = [[UIAlertView alloc]
            initWithTitle:@"Contacts Access Denied"
                  message:@"SNAPprints requires access to your device's "
                          @"contacts.\n\nPlease enable contacts access for "
                          @"this app in Settings -> Privacy -> Contacts"
                 delegate:self
        cancelButtonTitle:@"OK"
        otherButtonTitles:nil, nil];
    [alert show];

    return nil;
  }
}

/*
 Function: reduceImageSize
 Decription: Reduces image size.
 Return: NSData
 Param: UIImage
 */
- (NSData *)reduceImageSize:(UIImage *)image {

  CGFloat compression = 0.9f;
  CGFloat maxCompression = 0.5f;
  int maxFileSize = 2 * 1024;

  NSData *imageData = UIImageJPEGRepresentation(image, compression);

  while ([imageData length] > maxFileSize && compression > maxCompression) {
    compression -= 0.1;
    imageData = UIImageJPEGRepresentation(image, compression);
  }
  return imageData;
}

/*
 Function: checkUncheckAction
 Decription: Get indexpath for selected cell of tableview.
 Return: void
 Param: id
 */
- (void)checkUncheckAction:(id)sender {
  CGPoint subviewPosition = [sender convertPoint:CGPointZero toView:_tblEmail];
  NSIndexPath *indexPath = [_tblEmail indexPathForRowAtPoint:subviewPosition];
  NSLog(@"indexPath : %ld", (long)indexPath.row);
  if (isSearched) {
    [self setCheckOrUncheck:_arrSearchEmails indexPath:indexPath button:sender];
  } else {
    [self setCheckOrUncheck:_arrEmails indexPath:indexPath button:sender];
  }
}

/*
 Function: setCheckOrUncheck
 Decription: set image for checked/unchecked cell and add contact in selected
 contcat's array.
 Return: void
 Param: NSMutableArray,NSIndexPath, UIButton
 */
- (void)setCheckOrUncheck:(NSMutableArray *)arr
                indexPath:(NSIndexPath *)indexPath
                   button:(UIButton *)btn {
  InviteCell *cell = (InviteCell *)[_tblEmail cellForRowAtIndexPath:indexPath];
  ContactInformation *info = [arr objectAtIndex:indexPath.row];
  info.isSelected = btn.isSelected;
  NSString *str =
      [NSString stringWithFormat:@"%@#%@", info.emailAdd, info.userName];
  if ([btn isSelected]) {
    [cell.btnSelect setImage:[UIImage imageNamed:@"add_user_blue"]
                    forState:UIControlStateNormal];

    [_arrSelected addObject:str];
  } else {
    [cell.btnSelect setImage:[UIImage imageNamed:@"add_user_gray"]
                    forState:UIControlStateNormal];

    [_arrSelected removeObject:str];
  }
  if ([_arrSelected count] > 0)
    [_btnInvite setEnabled:YES];
  else
    [_btnInvite setEnabled:NO];
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

#pragma mark
#pragma mark - API call

/*
 Function: sendInvitation
 Decription: Send invitation for selected contacts.
 Return: void
 Param: NSArray
 */
- (void)sendInvitation:(NSArray *)arr {
  // http://snapprints.benchmarkitsolution.com/invites/add.json

  NSString *user_id =
      [[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"];
  NSString *event_id = [NSString stringWithFormat:@"%ld", (long)_event.eventId];
  NSMutableString *strInvites = [NSMutableString stringWithString:@""];
  for (int i = 0; i < [arr count]; i++) {
    [strInvites appendFormat:@"%@", [arr objectAtIndex:i]];
    if (i < [arr count] - 1) {
      [strInvites appendFormat:@","];
    }
  }
  NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
  [parameters setObject:strInvites forKey:@"Invite[invitees]"];
  [parameters setObject:user_id forKey:@"user_id"];
  [parameters setObject:event_id forKey:@"event_id"];

  [[SnapprintsClient sharedSnapprintsClient] postPath:@"invites/add.json"
      parameters:parameters
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSLog(@"Response for Invite:%@", responseObject);
          [_hud hide:YES];
          if ([[responseObject objectForKey:@"status"]
                  isEqualToString:@"success"]) {

            if (isFromAddEvent) {
              EventListViewController *eventVC =
                  [[EventListViewController alloc]
                      initWithNibName:@"EventListViewController"
                               bundle:[NSBundle mainBundle]];

              NSInteger loggedUser_id = [[[NSUserDefaults standardUserDefaults]
                  objectForKey:@"user_id"] integerValue];
              if (isFromMyEvent)
                [eventVC getEventsForMyEvents:loggedUser_id];
              else
                [eventVC getEventsForUser:loggedUser_id];
              UINavigationController *eventNav = [[UINavigationController alloc]
                  initWithRootViewController:eventVC];

              [TSMessage setDefaultViewController:eventNav];
              [TSMessage
                  showNotificationWithTitle:@"Invite"
                                   subtitle:[responseObject
                                                objectForKey:@"message"]
                                       type:TSMessageNotificationTypeSuccess];

//              UIImageView *headerLogoView = [[UIImageView alloc]
//                  initWithImage:[UIImage imageNamed:@"new-logo"]];
//              [eventNav.navigationBar addSubview:headerLogoView];
//              headerLogoView.center = eventNav.navigationBar.center;

              if ([[[UIDevice currentDevice] systemVersion] floatValue] >=
                  7.0) {
                eventNav.navigationBar.barTintColor = [UIColor whiteColor];
                [eventNav.navigationBar setTintColor:[UIColor blackColor]];
                eventNav.navigationBar.translucent = NO;
              } else {
                eventNav.navigationBar.tintColor = [UIColor blackColor];
              }

              self.menuContainerViewController.centerViewController = eventNav;

            } else {
              [TSMessage setDefaultViewController:self.navigationController];
              [TSMessage
                  showNotificationWithTitle:@"Invite"
                                   subtitle:[responseObject
                                                objectForKey:@"message"]
                                       type:TSMessageNotificationTypeSuccess];
              NSString *str = @"EventDetailVC";
              [self popControllerToSpecified:str];
            }

          } else {
            [TSMessage setDefaultViewController:self.navigationController];
            [TSMessage
                showNotificationWithTitle:@"Error"
                                 subtitle:[responseObject
                                              objectForKey:@"message"]
                                     type:TSMessageNotificationTypeError];
          }
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          NSLog(@"Error: %@", error.description);
          [TSMessage setDefaultViewController:self.navigationController];
          [TSMessage showNotificationWithTitle:@"Error"
                                      subtitle:@"Failed to send invitation."
                                          type:TSMessageNotificationTypeError];
          [_hud hide:YES];
      }];
}

#pragma mark
#pragma mark -UITableview Datasource and delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
  if (isSearched)
    return [_arrSearchEmails count];
  return [_arrEmails count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  InviteCell *cell =
      [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  if (!cell) {
    cell = [[[NSBundle mainBundle] loadNibNamed:@"InviteCell"
                                          owner:self
                                        options:nil] objectAtIndex:0];
  }
  ContactInformation *contactInfo;
  if (isSearched)
    contactInfo = [_arrSearchEmails objectAtIndex:indexPath.row];
  else
    contactInfo = [_arrEmails objectAtIndex:indexPath.row];

  [cell.lblName setFont:[UIFont fontWithName:kAppSupportedFontLight size:17.f]];
  [cell.lblEmail setFont:[UIFont fontWithName:kAppSupportedFontLight size:15.f]];

  if ([contactInfo.userName isEqualToString:@" "]) {
    cell.lblName.text = @"No Name";
  } else
    cell.lblName.text = contactInfo.userName;

  cell.lblEmail.text = contactInfo.emailAdd;

  if ([contactInfo.imageUrlDocument isEqualToString:@""] ||
      [contactInfo.imageUrlDocument isEqualToString:@"(null)"]) {

    [cell.contactImage setImage:[UIImage imageNamed:@"default-event"]];

  } else {

    NSData *imgData =
        [NSData dataWithContentsOfFile:contactInfo.imageUrlDocument];
    UIImage *img = [UIImage imageWithData:imgData];
    [cell.contactImage setImage:img];
  }
  if (contactInfo.isSelected) {
    [cell.btnSelect setSelected:YES];
  } else {
    [cell.btnSelect setSelected:NO];
  }
  [cell.btnSelect setImage:[UIImage imageNamed:@"add_user_blue"]
                  forState:UIControlStateSelected];
  [cell.btnSelect setImage:[UIImage imageNamed:@"add_user_gray"]
                  forState:UIControlStateNormal];
  [cell.contactImage.layer setCornerRadius:5.f];
  [cell.contactImage.layer setBorderWidth:0.5f];
  [cell.contactImage.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
  [cell.btnSelect addTarget:self
                     action:@selector(btnSelectClicked:)
           forControlEvents:UIControlEventTouchUpInside];
  [cell.contactImage.layer setMasksToBounds:YES];
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 80;
}
/*
- (UIView *)tableView:(UITableView *)tableView
    viewForHeaderInSection:(NSInteger)section {
  UIView *view = [[UIView alloc]
      initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
  [view setBackgroundColor:[UIColor whiteColor]];
  UILabel *label = [[UILabel alloc]
      initWithFrame:CGRectMake(0, 5, self.view.frame.size.width, 25)];
  label.textAlignment = NSTextAlignmentCenter;
  label.text = @"Contacts";
  [label setBackgroundColor:[UIColor whiteColor]];
  [label setFont:[UIFont fontWithName:@"Calibri-Light" size:22]];
  label.textColor = [UIColor darkGrayColor];
  [view addSubview:label];
  UIView *lineView = [[UIView alloc]
      initWithFrame:CGRectMake(0, 35, self.view.frame.size.width, 0.5)];
  [lineView setBackgroundColor:[UIColor lightGrayColor]];
  [view addSubview:lineView];
  return view;
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForHeaderInSection:(NSInteger)section {
  return TABLE_HEADER_HEIGHT;
}
*/
#pragma mark
#pragma mark - UITextField delegate

- (void)textFieldTextDidChange:(NSNotification *)notification {
  if ([_arrSearchEmails count] > 0)
    [_arrSearchEmails removeAllObjects];
  isSearched = YES;
  UITextField *txtField = notification.object;
  NSString *searchText = [txtField.text lowercaseString];
  for (int i = 0; i < [_arrEmails count]; i++) {
    if ([searchText length] != 0) {
      ContactInformation *contactInfo;
      contactInfo = [_arrEmails objectAtIndex:i];
      NSString *strTemp =
          [NSString stringWithFormat:@"%@ %@", contactInfo.firstName,
                                     contactInfo.lastName];
      NSString *strEmail = [[NSString
          stringWithFormat:@"%@", contactInfo.emailAdd] lowercaseString];
      NSString *searched = [strTemp lowercaseString];
      if (![searched hasPrefix:searchText] && ![strEmail hasPrefix:searchText])
        continue;
      else
        [_arrSearchEmails addObject:[_arrEmails objectAtIndex:i]];
    } else
      [_arrSearchEmails addObject:[_arrEmails objectAtIndex:i]];
  }
  if ([_arrSearchEmails count] == 0) {

    _lblErrorMessage.text = @"No contacts found";
    _lblErrorMessage.hidden = NO;
  } else {

    _lblErrorMessage.hidden = YES;
  }

  [_tblEmail reloadData];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
  isSearched = NO;
  return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {

  if ([textField.text length] > 0) {

    isSearched = YES;

  } else {

    isSearched = NO;
  }

  [textField resignFirstResponder];
  return YES;
}

@end
