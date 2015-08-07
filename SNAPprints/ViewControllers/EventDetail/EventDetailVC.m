//
//  EventDetailVC.m
//  SNAPprints
//
//  Created by Etay Luz on 22/05/14.
//  Copyright (c) 2014 Etay Luz. All rights reserved.
//

#import "EventDetailVC.h"
#import "HeaderView.h"
#import "UIImage+ProportionalFill.h"
#import "ImageCell.h"
#import "InvitedVC.h"
#import "ConstantFlags.h"
#import "AddEventViewController.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "UIImage+ImageEffects.h"
#import "FullImageVC.h"


#define ACTIONSHEET_ADD_PHOTOS_TAG 1
#define ACTIONSHEET_DIRECTIONS_TAG 2
#define ACTIONSHEET_ACTIONS_TAG 3
#define ACTIONSHEET_EDIT_EVENT 4
#define MIN_LABLE_HEIGHT 60.0f
#define SPACE_ADDRESS 10.f

static NSString *kCollectionViewHeaderIdentifier = @"Header";
static NSString *kCollectionViewIdentifier = @"Photocell";

@interface EventDetailVC () {
    NSMutableArray *arrPhotos;
    BOOL isErrorMsgDisplayed, isDeleteClicked, isDeleteSelected;
    NSMutableArray *arrSelectedPhotos;
}

@property(weak, nonatomic) IBOutlet UIButton *btnEditEvent;

@property(nonatomic, retain) NSTimer *timer;
@property(nonatomic, retain) NSTimer *getPhotosTimer;

- (IBAction)btnEditClicked:(id)sender;

@end

@implementation EventDetailVC

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
    
    [self fullscreenOnTouch];
    isErrorMsgDisplayed = NO;
    library = [[ALAssetsLibrary alloc] init];
    isFromAddEvent = NO;
    isDeleteClicked = NO;
    isDeleteSelected = YES;
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBar.tintColor =
    UIColorFromRGB(COLOR_LIGHT_BLUE);
    [self.navigationController.navigationBar
     setBarTintColor:[UIColor whiteColor]];
    
    isExpired = NO;
    
    arrPhotos = [[NSMutableArray alloc] init];
    
    arrSelectedPhotos = [[NSMutableArray alloc] init];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                           target:self
                                           action:@selector(actionTapped:)];
    rightBarButtonItem.tintColor = UIColorFromRGB(COLOR_LIGHT_BLUE);
    //  self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
    UIButton *btn = nil;
    UIBarButtonItem *btnDelete = nil;
    if(isFromMyPicture)
    {
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.bounds = CGRectMake(0, 0, 40, 27);
        [btn setImage:[UIImage imageNamed:@"trash"] forState:UIControlStateNormal];
        [btn addTarget:self
                action:@selector(btnDeleteClicked:)
      forControlEvents:UIControlEventTouchUpInside];
        btn.tintColor = UIColorFromRGB(COLOR_LIGHT_BLUE);
        btnDelete =
        [[UIBarButtonItem alloc] initWithCustomView:btn];
        
    }
    if(btnDelete)
        self.navigationItem.rightBarButtonItems = @[rightBarButtonItem,btnDelete];
    else
        self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
    [_lblTimeRemaining setFont:[UIFont fontWithName:kAppSupportedFontNormal size:13]];
    [_lblPhotoUploaded setFont:[UIFont fontWithName:kAppSupportedFontNormal size:13]];
    
    [self getPhotos];
    
    oldPhotoCount = [_event.photos count];
    NSLog(@"%ld", (long)oldPhotoCount);
    
    [self getHeaderView];
    [self.collectionView
     registerNib:[UINib nibWithNibName:@"ImageCell" bundle:nil]
     forCellWithReuseIdentifier:kCollectionViewIdentifier];
    
    UICollectionViewFlowLayout *layout =
    [[UICollectionViewFlowLayout alloc] init];
    [_collectionView setCollectionViewLayout:layout];
    
    UINib *headerNib = [UINib nibWithNibName:NSStringFromClass([HeaderView class])
                                      bundle:[NSBundle mainBundle]];
    [_collectionView registerNib:headerNib
      forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
             withReuseIdentifier:kCollectionViewHeaderIdentifier];
    
    dbClass = [[SqliteDBClass alloc]init];
    NSInteger loggedUser_id = [[[NSUserDefaults standardUserDefaults]
                                objectForKey:@"user_id"] integerValue];
    if(loggedUser_id != _event.eventUser.userId)
    {
        [_btnSaveDateToCalender setUserInteractionEnabled:YES];
        [self checkEventAddedToCalendar];
    }
    else
    {
        [_btnSaveDateToCalender setUserInteractionEnabled:NO];
    }

}

-(void)checkEventAddedToCalendar
{
    //Get Events from database to check whether Event is added to calendar or not.
    NSArray *arrEventInCalendar = [dbClass getEventsCalendar];
    for(NSDictionary *eventDict in arrEventInCalendar)
    {
        NSInteger eventID = [[eventDict valueForKey:@"Event_ID"]integerValue];
        if(eventID == _event.eventId)
        {
            [_btnSaveDateToCalender setUserInteractionEnabled:NO];
            break;
        }
    }
}

-(void)fullscreenOnTouch{
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture)];
    tapGesture.numberOfTapsRequired=1;
    [self.headerImage setUserInteractionEnabled:YES];
    [self.headerImage addGestureRecognizer:tapGesture];
}
-(void)handleTapGesture{
    //        self.collectionView.hidden = YES;
    //       self.bottomView.hidden = YES;
    //    self.headerImage.frame=CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
    
    FullImageVC *fvc = [[FullImageVC alloc] initWithNibName:@"FullImageVC" bundle:nil];
    fvc.thisImage = self.passThisImage;
    [self.navigationController pushViewController:fvc animated:YES];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_btnPhoto setBackgroundImage:[UIImage imageNamed:@"camera-cut-icon3"]
                         forState:UIControlStateNormal];
    [_btnPhoto setEnabled:NO];
    _getPhotosTimer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(getPhotos) userInfo:nil repeats:YES];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.20
                                              target:self
                                            selector:@selector(updateTimer)
                                            userInfo:nil
                                             repeats:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    [_timer invalidate];
    [_getPhotosTimer invalidate];
    
    if ([self.navigationController.viewControllers indexOfObject:self] ==
        NSNotFound) {
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack.
        if (oldPhotoCount != newPhotoCount)
            [self.delegate refreshEventList];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action Events

- (IBAction)btnSaveDateToCalender:(UIButton *)sender
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[NSString stringWithFormat:@"%ld",(long)_event.eventId] forKey:@"Event[id]"];
    [dict setObject:_event.title forKey:@"Event[title]"];
    [dict setObject:_event.address.address1 forKey:@"Event[address1]"];
    [dict setObject:_event.address.address2 forKey:@"Event[address2]"];
    [dict setObject:_event.address.city forKey:@"Event[city]"];
    [dict setObject:_event.address.state forKey:@"Event[state]"];
    [dict setObject:_event.address.zip forKey:@"Event[zip]"];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"M/d/yyyy h:mm a"];
    NSString *strStartDate = [df stringFromDate:_event.eventStartDateTime];
    [dict setObject:strStartDate forKey:@"Event[event_start_time]"];
    NSString *strEndDate = [df stringFromDate:_event.eventEndDateTime];
    [dict setObject:strEndDate forKey:@"Event[event_end_time]"];
    [dict setObject:_event.description forKey:@"Event[description]"];
    [self saveEventToCalendar:dict];
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
                 dispatch_async(dispatch_get_main_queue(),
                                ^{
                                    
                                    
                                    [TSMessage setDefaultViewController:self.navigationController];
                                    [TSMessage
                                     showNotificationWithTitle:@"Event Saved" subtitle:@"Event successfully saved to calendar."
                                     type:TSMessageNotificationTypeSuccess];
                                    
                                });
                 
                 [_btnSaveDateToCalender setUserInteractionEnabled:NO];
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

- (IBAction)btnClickedLearn:(id)sender {
    
    LearnMoreVC *vc = [[LearnMoreVC alloc] initWithNibName:@"LearnMoreVC"
                                                    bundle:[NSBundle mainBundle]];
    vc.event = _event;
    
    UINavigationController *navController =
    [[UINavigationController alloc] initWithRootViewController:vc];
    [navController.navigationBar setBarTintColor:[UIColor whiteColor]];
    NSArray *ver =
    [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    
    if ([[ver objectAtIndex:0] intValue] >= 7) {
        navController.navigationBar.barTintColor = [UIColor whiteColor];
        [navController.navigationBar setTintColor:[UIColor blackColor]];
        navController.navigationBar.translucent = NO;
        
    } else {
        navController.navigationBar.tintColor = [UIColor blackColor];
        //        eventNav.navigationBar.tintColor = [UIColor blackColor];
    }
    
    [self presentViewController:navController animated:YES completion:^{}];
}

- (IBAction)btnClickedPhoto:(id)sender {
    
    NSInteger numUserPhotos = [self getNumberOfUserPhotos];
    if (numUserPhotos >= _event.photoLimit) {
        NSString *message = [NSString
                             stringWithFormat:@"You can only upload %ld photos to this event",
                             (long)_event.photoLimit];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"OK", nil];
        [alertView show];
    } else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:Nil
                                      delegate:self
                                      cancelButtonTitle:@"Cancel"
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:@"Choose from Camera Roll", @"Take Photo", nil];
        
        actionSheet.tag = 1;
        [actionSheet showInView:self.view];
    }
}
- (IBAction)btnEditClicked:(id)sender {
    UIActionSheet *actionSheet =
    [[UIActionSheet alloc] initWithTitle:Nil
                                delegate:self
                       cancelButtonTitle:@"Cancel"
                  destructiveButtonTitle:@"Delete Event"
                       otherButtonTitles:@"Edit Event", nil];
    actionSheet.tag = ACTIONSHEET_EDIT_EVENT;
    [actionSheet showInView:self.view];
}

- (void)actionTapped:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:Nil
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"Share Via E-mail", @"Share via SMS",
                                  @"Share on Facebook", @"Share on Twitter",
                                  @"Flag as Inappropriate", nil];
    
    actionSheet.tag = ACTIONSHEET_ACTIONS_TAG;
    [actionSheet showInView:self.view];
}

- (IBAction)showMap:(id)sender {
    
    MapViewController *mapVC =
    [[MapViewController alloc] initWithNibName:@"MapViewController"
                                        bundle:[NSBundle mainBundle]];
    mapVC.event = _event;
    [self presentViewController:mapVC animated:YES completion:nil];
}

- (void)showInvited:(id)sender {
    InvitedVC *invitedVC =
    [[InvitedVC alloc] initWithNibName:@"InvitedVC"
                                bundle:[NSBundle mainBundle]];
    invitedVC.event = _event;
    [self.navigationController pushViewController:invitedVC animated:YES];
}

- (IBAction)btnDeleteClicked:(id)sender {
    UIButton *btnDelete = (UIButton *)sender;
    [btnDelete setSelected:![btnDelete isSelected]];
    if(isExpired)
    {
        [TSMessage setDefaultViewController:self.navigationController];
        [TSMessage showNotificationWithTitle:@"SNAPprints" subtitle:@"Event is Expired. So you can't delete photos." type:TSMessageNotificationTypeError];
    }
    else
    {
        if([arrPhotos count] > 0)
        {
            if(btnDelete.isSelected)
            {
                isDeleteClicked = YES;
                [btnDelete setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
                [btnDelete setTitle:@"Done" forState:UIControlStateSelected];
                btnDelete.titleLabel.font = [UIFont systemFontOfSize:16];
                [btnDelete  setTitleColor:UIColorFromRGB(COLOR_LIGHT_BLUE) forState:UIControlStateSelected];
            }
            else
            {
                isDeleteClicked = NO;
                [btnDelete setImage:[UIImage imageNamed:@"trash"] forState:UIControlStateNormal];
                if([arrSelectedPhotos count]>0)
                {
                    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"Are you sure you want to delete this picture(s)?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
                    alert.tag=100;
                    [alert show];
                    //                    if(hud == nil)
                    //                    {
                    //                        hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
                    //                        [self.view addSubview:hud];
                    //                    }
                    //                    [hud show:YES];
                    //                    [self deletePhotos:arrSelectedPhotos];
                    
                    
                }
                else
                {
                    [TSMessage setDefaultViewController:self.navigationController];
                    [TSMessage showNotificationWithTitle:@"SNAPprints" subtitle:@"Please select atleast one picture to delete." type:TSMessageNotificationTypeError];
                }
            }
        }
        else
        {
            [TSMessage setDefaultViewController:self.navigationController];
            [TSMessage showNotificationWithTitle:@"SNAPprints" subtitle:@"There is no pictures to delete." type:TSMessageNotificationTypeMessage];
        }
    }
    
}
#pragma mark - Custom Methods

/*
 Function: getImageURLForEvent
 Decription: Creates image url for event.
 Return: NSString
 Param: Event
 */
-(NSString *)getImageURLForEvent : (Event *)event {
    
    NSString *urlString;
    if (![event.thumbnail isEqualToString:@""]) {
        urlString = [NSString stringWithFormat:@"%@uploads/events/%@",
                     [Constants retriveServerURL],
                     event.thumbnail];
        return urlString;
    } else if ([event.photos count] == 0) {
        return @"";
    } else {
        Photo *photo = [event.photos objectAtIndex:0];
        urlString = [NSString stringWithFormat:@"%@/uploads/photos/%@",
                     [Constants retriveServerURL],
                     photo.thumbnail_filename];
        return urlString;
    }
    return @"";
}

/*
 Function: getHeaderView
 Decription: Applies font to label in header view of UICollectionView and
 calculates frames for subviews in headerview.
 Return: Void
 */
- (void)getHeaderView {
    // Set font style
    [_lblTitle setFont:[UIFont fontWithName:kAppSupportedFontBold size:21]];
    [_lblTitle setTextColor:[UIColor lightGrayColor]];
    [_lblEventTime setFont:[UIFont fontWithName:kAppSupportedFontNormal size:14]];
    [_lblPrice setFont:[UIFont fontWithName:kAppSupportedFontNormal size:14]];
    [_lblPhotos setFont:[UIFont fontWithName:kAppSupportedFontNormal size:14]];
    
    [_lblAddress setFont:[UIFont fontWithName:kAppSupportedFontNormal size:15.5f]];
    
    [_lblDescription setFont:[UIFont fontWithName:kAppSupportedFontNormal size:17.f]];
    [_btnDescription.titleLabel setFont:[UIFont fontWithName:kAppSupportedFontNormal size:15]];
    [_lblAddress setTextColor:[UIColor blackColor]];
    
    if (_event.isPrivate) {
        [_imgPrivate setHidden:NO];
    } else {
        [_imgPrivate setHidden:YES];
    }
    
    //  self.headerImage.layer.cornerRadius = 10;
    //  self.headerImage.clipsToBounds = YES;
    //  self.headerImage.layer.borderWidth = 2;
    //  self.headerImage.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    [_headerImage setHidden:YES];
    // Changes by mohsinali on 27 may 2015
    //    self.headerImage.clipsToBounds = YES;
    //    self.headerImage.layer.cornerRadius = self.headerImage.frame.size.height/2.0f;
    self.headerImage.layer.borderWidth = 2.0f;
    self.headerImage.layer.borderColor = [UIColor whiteColor].CGColor;
    
    NSString *urlString = [self getImageURLForEvent:_event];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [self.headerImage setImageWithURLRequest:request
                            placeholderImage:Nil
                                     success:^(NSURLRequest *request, NSHTTPURLResponse *response,
                                               UIImage *image) {
                                         [_lblTitle setFrame:CGRectMake(8, 104, 304, 21)];
                                         UIImage *bluredImage = nil;
                                         bluredImage = [image applyLightEffect];
                                         
                                         
                                         //[self.blurHeaderImage setImage:bluredImage];//bg-my-photos-1080x1920.jpg
                                         self.blurHeaderImage.image = [UIImage imageNamed:@"bg-my-photos-1080x1920.jpg"];
                                         [_headerImage setImage:image];
                                         self.passThisImage = image;
                                         [_headerImage setHidden:NO];
                                         [_lblTitle setTextColor:[UIColor whiteColor]];
                                     }
                                     failure:^(NSURLRequest *request, NSHTTPURLResponse *response,
                                               NSError *error) {
                                     }];
    
    if ([self.event.title length] <= 26) {
        [_lblTitle setTextAlignment:NSTextAlignmentCenter];
    }else{
        [_lblTitle setTextAlignment:NSTextAlignmentLeft];
    }
    
    _lblTitle.text = self.event.title;
    if (!_event.address.address2 ||
        [_event.address.address2 isKindOfClass:[NSNull class]]) {
        _event.address.address2 = @"";
    }
    NSString *strDistance = nil;
    if (self.event.distance != -5 && self.event.distance != 0.0) {
        strDistance =
        [NSString stringWithFormat:@"%.01f miles", self.event.distance];
    } else {
        strDistance = @"Distance Unavailable";
    }
    
    NSString *strAddress = nil;
    if (isFromMyEvent) {
        strAddress =
        [NSString stringWithFormat:@"%@ %@\n%@ %@ %@", _event.address.address1,
         _event.address.address2, _event.address.city,
         _event.address.state, _event.address.zip];
    } else
        strAddress = [NSString
                      stringWithFormat:@"%@ %@\n%@ %@ %@\n%@", _event.address.address1,
                      _event.address.address2, _event.address.city,
                      _event.address.state, _event.address.zip, strDistance];
    
    _lblAddress.text = strAddress;
    
    if ([self.event.price floatValue] == 0.00) {
        _lblPrice.text = @"FREE";
    } else {
        _lblPrice.text =
        [NSString stringWithFormat:@"$%.02f", [self.event.price floatValue]];
    }
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setTimeZone:[NSTimeZone localTimeZone]];
    NSDate *date = _event.eventStartDateTime;
    
    static NSString *format1 = @"dd MMM, yyyy";
    [df setDateFormat:format1];
    NSString *strDatePart1 = [df stringFromDate:date];
    static NSString *format2 = @"hh:mm a";
    [df setDateFormat:format2];
    NSString *strDatePart2 = [df stringFromDate:date];
    
    NSString *strDateTime =
    [NSString stringWithFormat:@"%@ @ %@", strDatePart1, strDatePart2];
    
    _lblEventTime.text = strDateTime;
    
    if (![self.event.description isKindOfClass:[NSNull class]]) {
        _lblDescription.text = self.event.description;
        _lblDescription.translatesAutoresizingMaskIntoConstraints = YES;
    }
    
    _lblPhotos.text =
    [NSString stringWithFormat:@"%ld photos", (long)_event.photoLimit];
    _btnDescription.layer.cornerRadius = 5.0f;
    [_btnDescription addTarget:self
                        action:@selector(btnClickedLearn:)
              forControlEvents:UIControlEventTouchUpInside];
    if (_userID) {
        [_btnDescription setEnabled:NO];
        [_btnDescription setBackgroundColor:[UIColor grayColor]];
        [_btnDescription setAlpha:0.50f];
    }
    
    NSString *loggedUser_id =
    [[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"];
    NSString *user_id =
    [NSString stringWithFormat:@"%ld", (long)_event.eventUser.userId];
    [_btnShowMap addTarget:self
                    action:@selector(showMap:)
          forControlEvents:UIControlEventTouchUpInside];
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName : [UIFont systemFontOfSize:_lblAddress.font.pointSize]
                                 };
    CGSize maximumLabelSize = CGSizeMake(_lblAddress.frame.size.width, 9999);
    CGRect expectedLabelRect =
    [strAddress boundingRectWithSize:maximumLabelSize
                             options:(NSStringDrawingUsesLineFragmentOrigin |
                                      NSStringDrawingUsesFontLeading)
                          attributes:attributes
                             context:nil];
    CGRect frameDesc = _lblAddress.frame;
    frameDesc.size.height = expectedLabelRect.size.height;
    _lblAddress.frame = frameDesc;
    [_lblAddress sizeThatFits:CGSizeMake(_lblAddress.frame.size.width,
                                         frameDesc.size.height)];
    
    CGRect nextView = _viewbelowAddress.frame;
    float diff = 0.0f;
    
    diff = nextView.origin.y -
    (_lblAddress.frame.origin.y + _lblAddress.frame.size.height);
    
    if (diff < SPACE_ADDRESS && diff > 0) {
        float newHt = SPACE_ADDRESS - diff;
        nextView.origin.y = nextView.origin.y + newHt;
    } else if (diff > 18) {
        float newHt = diff - SPACE_ADDRESS;
        nextView.origin.y = nextView.origin.y + newHt;
    } else {
        nextView.origin.y =
        (_lblAddress.frame.origin.y + _lblAddress.frame.size.height) +
        SPACE_ADDRESS;
    }
    _viewbelowAddress.frame = nextView;
    // New frame set to Label Description
    [_lblDescription setFrame:CGRectMake(_lblDescription.frame.origin.x,
                                         nextView.origin.y + 15,
                                         _lblDescription.frame.size.width,
                                         _lblDescription.frame.size.height)];
    [_lblDescription sizeToFit];
    
    if ([loggedUser_id isEqualToString:user_id] &&
        (isFromEventsNearMe || isFromMyEvent)) {
        [_btnInvited setHidden:NO];
        _btnInvited.layer.cornerRadius = 5.f;
        _btnInvited.layer.borderWidth = 1.f;
        _btnInvited.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        [_btnInvited addTarget:self
                        action:@selector(showInvited:)
              forControlEvents:UIControlEventTouchUpInside];
        
        [_btnEditEvent setHidden:NO];
        [_btnEditEvent.titleLabel
         setFont:[UIFont fontWithName:kAppSupportedFontNormal size:17.f]];
        _btnEditEvent.layer.cornerRadius = 5.f;
        _btnEditEvent.layer.borderWidth = 1.f;
        _btnEditEvent.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    }
    // New frame set to Button Learn More
    float newBtnY =
    _lblDescription.frame.origin.y + _lblDescription.frame.size.height + 10;
    [_btnDescription setFrame:CGRectMake(_btnDescription.frame.origin.x, newBtnY,
                                         _btnDescription.frame.size.width,
                                         _btnDescription.frame.size.height)];
    
    // New frame set to Image of Map
    float midpoint = _lblAddress.frame.origin.y +
    _lblAddress.frame.size.height / 2 -
    _mapImage.frame.size.height / 2;
    _mapImage.frame =
    CGRectMake(_mapImage.frame.origin.x, midpoint, _mapImage.frame.size.width,
               _mapImage.frame.size.height);
    
    float midView = (_viewaboveAddress.frame.origin.y + nextView.origin.y) / 2;
    NSLog(@"MideView :%f", midView);
    [_btnEditEvent
     setFrame:CGRectMake(_btnEditEvent.frame.origin.x,
                         midView - (_btnEditEvent.frame.size.height)-2,
                         _btnEditEvent.frame.size.width,
                         _btnEditEvent.frame.size.height)];
    
    _btnInvited.frame =
    CGRectMake(_btnInvited.frame.origin.x, midView + 3,
               _btnInvited.frame.size.width, _btnInvited.frame.size.height);
    
    
    float newHeight = newBtnY + _btnDescription.frame.size.height + 10;
    _HeaderView.frame = CGRectMake(0, 0, _HeaderView.frame.size.width, newHeight);
}

/*
 Function: checkPhotoLimit
 Decription: Validation for photo limit.
 Return: Void
 */
- (void)checkPhotoLimit {
    if ([_event.eventStartDateTime timeIntervalSinceDate:[NSDate date]] > 0) {
        [_btnPhoto setEnabled:NO];
        [_btnPhoto setBackgroundImage:[UIImage imageNamed:@"camera-cut-icon3"]
                             forState:UIControlStateNormal];
        if (!isErrorMsgDisplayed) {
            [TSMessage
             showNotificationInViewController:self.navigationController
             title:@""
             subtitle:@"You can't upload the photos "
             @"before the event starts."
             type:TSMessageNotificationTypeError];
            isErrorMsgDisplayed = YES;
        }
    } else {
        NSInteger numberOfUserPhotos = [self getNumberOfUserPhotos];
        
        _lblPhotoUploaded.text = [NSString
                                  stringWithFormat:@"%ld of %ld Uploaded", (long)numberOfUserPhotos,
                                  (long)_event.photoLimit];
        
        if (numberOfUserPhotos >= _event.photoLimit || isExpired) {
            [_btnPhoto setBackgroundImage:[UIImage imageNamed:@"camera-cut-icon3"]
                                 forState:UIControlStateNormal];
            [_btnPhoto setEnabled:NO];
            
        } else {
            if (IsGotPhotoResponse) {
                [_btnPhoto setBackgroundImage:[UIImage imageNamed:@"camera-blue-icon3"]
                                     forState:UIControlStateNormal];
                [_btnPhoto setEnabled:YES];
                
            } else {
                [_btnPhoto setBackgroundImage:[UIImage imageNamed:@"camera-cut-icon3"]
                                     forState:UIControlStateNormal];
                [_btnPhoto setEnabled:NO];
            }
        }
    }
}

/*
 Function: getNumberOfUserPhotos
 Decription: Calculates number of photos count for logged in user.
 Return: NSInteger
 */
- (NSInteger)getNumberOfUserPhotos {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger userID = [[defaults objectForKey:@"user_id"] integerValue];
    
    NSString *format =
    [NSString stringWithFormat:@"user.userId == %ld", (long)userID];
    NSPredicate *pred = [NSPredicate predicateWithFormat:format];
    
    NSArray *photos = [arrPhotos filteredArrayUsingPredicate:pred];
    return [photos count];
}

- (void)hideHUD {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

/*
 Function: updateTimer
 Decription: For calculating remaining time to expire event.
 Return: Void
 */
- (void)updateTimer {
    
    [_lblTimeRemaining setFont:[UIFont fontWithName:kAppSupportedFontNormal size:13]];
    NSCalendar *currCalendar =
    [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit |
    NSSecondCalendarUnit | NSDayCalendarUnit;
    
    NSDateComponents *conversionInfo =
    [currCalendar components:unitFlags
                    fromDate:[NSDate date]
                      toDate:_event.eventEndDateTime
                     options:0];
    
    NSInteger days = [conversionInfo day];
    NSInteger hours = [conversionInfo hour];
    NSInteger minutes = [conversionInfo minute];
    NSInteger seconds = [conversionInfo second];
    
    NSString *beginningOfText = @"Time Remaining";
    
    NSMutableString *timeString =
    [NSMutableString stringWithString:@"Time Remaining\n"];
    
    if (days != 0) {
        if (days == 1) {
            [timeString appendFormat:@"1DAY"];
        } else {
            [timeString appendFormat:@"%dDAYS", (int)days];
        }
    }
    
    if (seconds <= 0 && minutes <= 0 && hours <= 0 && days <= 0) {
        isExpired = YES;
        _lblTimeRemaining.text = @"PHOTOS CAN NO LONGER BE UPLOADED";
    } else {
        //[timeString appendFormat:@"%dHR %dMIN %dSEC", (int)hours, (int)minutes,
        //(int)seconds];
        
        [timeString appendFormat:@"  %dHRS", (int)hours];
        NSMutableAttributedString *attString =
        [[NSMutableAttributedString alloc] initWithString:timeString];
        
        [attString addAttribute:NSForegroundColorAttributeName
                          value:[UIColor blackColor]
                          range:NSMakeRange([beginningOfText length],
                                            [attString length] -
                                            [beginningOfText length])];
        
        [_lblTimeRemaining setAttributedText:attString];
    }
    [self checkPhotoLimit];
}

/*
 Function: parseURLParams
 Decription: A function for parsing URL parameters returned by the Feed Dialog.
 Return: NSDictionary
 Param: NSString
 */
- (NSDictionary *)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val = [kv[1]
                         stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}

#pragma mark - API Call
/*
 Function: getPhotos
 Decription: Get all uploaded photos for particular event.
 Return: void
 */
- (void)getPhotos {
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setTimeZone:[NSTimeZone localTimeZone]];
    [df setDateFormat:@"MMMM d h:mm a"];
    
    NSString *path =
    [NSString stringWithFormat:@"/photos/event/%ld", (long)_event.eventId];
    [[SnapprintsClient sharedSnapprintsClient] getPath:path
                                            parameters:nil
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   NSLog(@"Event Details responseObject = %@",responseObject);
                                                   
                                                   [df setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
                                                   [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                                                   NSArray *photos = [responseObject objectForKey:@"photos"];
                                                   [arrPhotos removeAllObjects];
                                                   for (NSInteger i = [photos count] - 1; i >= 0; i--) {
                                                       NSDictionary *dict = [photos objectAtIndex:i];
                                                       NSDictionary *photoDict = [dict objectForKey:@"Photo"];
                                                       
                                                       Photo *photo = [[Photo alloc] init];
                                                       photo.caption = [photoDict objectForKey:@"caption"];
                                                       photo.filename = [photoDict objectForKey:@"filename"];
                                                       photo.thumbnail_filename = [photoDict objectForKey:@"thumbnail"];
                                                       photo.is_deleted = [photoDict objectForKey:@"is_deleted"];
                                                       
                                                       photo.created =
                                                       [df dateFromString:[photoDict objectForKey:@"created"]];
                                                       photo.photoID = [[photoDict objectForKey:@"id"] intValue];
                                                       
                                                       // Set up user data
                                                       NSDictionary *userDict = [dict objectForKey:@"User"];
                                                       User *user = [[User alloc] init];
                                                       
                                                       if (![[userDict objectForKey:@"id"] isKindOfClass:[NSNull class]])
                                                           user.userId = [[userDict objectForKey:@"id"] intValue];
                                                       
                                                       if (![[userDict objectForKey:@"username"]
                                                             isKindOfClass:[NSNull class]])
                                                           user.username = [userDict objectForKey:@"username"];
                                                       
                                                       if ([[userDict objectForKey:@"profile_image"]
                                                            isKindOfClass:[NSNull class]]) {
                                                           user.profileImage = @"";
                                                       } else {
                                                           user.profileImage = [userDict objectForKey:@"profile_image"];
                                                       }
                                                       
                                                       photo.user = user;
                                                       
                                                       if (_userID) {
                                                           if (photo.user.userId == _userID)
                                                           {
                                                               if (![photo.filename isEqualToString:@""] &&
                                                                   ![photo.thumbnail_filename isEqualToString:@""])
                                                                   if([photo.is_deleted isEqualToString:@"0"])
                                                                       [arrPhotos addObject:photo];
                                                           }
                                                       }
                                                       else {
                                                           if (![photo.filename isEqualToString:@""] &&
                                                               ![photo.thumbnail_filename isEqualToString:@""])
                                                               if([photo.is_deleted isEqualToString:@"0"])
                                                                   [arrPhotos addObject:photo];
                                                       }
                                                       
                                                       newPhotoCount = [arrPhotos count];
                                                       NSLog(@"%ld", (long)newPhotoCount);
                                                   }
                                                   [_collectionView reloadData];
                                                   IsGotPhotoResponse = YES;
                                                   [self checkPhotoLimit];
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   [_btnPhoto setBackgroundImage:[UIImage imageNamed:@"camera-cut-icon3"]
                                                                        forState:UIControlStateNormal];
                                                   [_btnPhoto setEnabled:NO];
                                               }];
}

/*
 Function: removeEvent
 Decription: API for deleting event.
 Return: void
 */
- (void)removeEvent {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [defaults objectForKey:@"token"];
    NSString *user_id = [defaults objectForKey:@"user_id"];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    NSString *event_id = [NSString stringWithFormat:@"%ld", (long)_event.eventId];
    
    [parameters setObject:event_id forKey:@"id"];
    [parameters setObject:token forKey:@"token"];
    [parameters setObject:user_id forKey:@"user_id"];
    
    [[SnapprintsClient sharedSnapprintsClient] getPath:@"/events/delete.json"
                                            parameters:parameters
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   NSLog(@"Delete Event responseObject = %@",responseObject);
                                                   
                                                   if ([[responseObject objectForKey:@"status"]
                                                        isEqualToString:@"success"]) {
                                                       [TSMessage setDefaultViewController:self.navigationController];
                                                       [TSMessage
                                                        showNotificationWithTitle:
                                                        nil subtitle:@"This event has been deleted succesfully."
                                                        type:TSMessageNotificationTypeSuccess];
                                                       if ([self.delegate
                                                            respondsToSelector:@selector(refreshEventList)]) {
                                                           
                                                           [self.delegate refreshEventList];
                                                       }
                                                       [self.navigationController popViewControllerAnimated:YES];
                                                       [hud removeFromSuperview];
                                                   }
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   [TSMessage setDefaultViewController:self.navigationController];
                                                   [TSMessage
                                                    showNotificationWithTitle:
                                                    nil subtitle:@"There was a problem deleting this event."
                                                    type:TSMessageNotificationTypeError];
                                                   [hud removeFromSuperview];
                                               }];
}

/*
 Function: removeEvent
 Decription: API for flagging event as inappropriate.
 Return: void
 */
- (void)flagEvent {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [defaults objectForKey:@"token"];
    NSString *user_id = [defaults objectForKey:@"user_id"];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    NSString *event_id = [NSString stringWithFormat:@"%ld", (long)_event.eventId];
    
    [parameters setObject:event_id forKey:@"event_id"];
    [parameters setObject:token forKey:@"token"];
    [parameters setObject:user_id forKey:@"user_id"];
    NSLog(@"Flag Event parameters = %@",parameters);
    [[SnapprintsClient sharedSnapprintsClient] postPath:@"/events/flag"
                                             parameters:parameters
                                                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                    NSLog(@"Flag Event responseObject = %@",responseObject);
                                                    if ([[responseObject objectForKey:@"status"]
                                                         isEqualToString:@"success"]) {
                                                        [TSMessage setDefaultViewController:self.navigationController];
                                                        [TSMessage
                                                         showNotificationWithTitle:
                                                         nil subtitle:@"This event has been flagged for review"
                                                         type:TSMessageNotificationTypeSuccess];
                                                    }
                                                }
                                                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                    [TSMessage setDefaultViewController:self.navigationController];
                                                    [TSMessage showNotificationWithTitle:
                                                     nil subtitle:@"There was a problem flagging this event"
                                                                                    type:TSMessageNotificationTypeError];
                                                }];
}

/*
 Function: deletePhotos
 Decription: API for deleting photos from 'My Picture' section.
 Return: void
 Param: NSMutableArray
 */
-(void)deletePhotos:(NSMutableArray*)arr
{
    NSString *user_id =
    [[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"];
    NSString *event_id = [NSString stringWithFormat:@"%ld", (long)_event.eventId];
    NSMutableString *strPhotos = [NSMutableString stringWithString:@""];
    for (int i = 0; i < [arr count]; i++) {
        Photo *photo = [arr objectAtIndex:i];
        NSString *photoId = [NSString stringWithFormat:@"%ld",(long)photo.photoID];
        [strPhotos appendFormat:@"%@",photoId];
        if (i < [arr count] - 1) {
            [strPhotos appendFormat:@","];
        }
    }
    NSLog(@"Selected photos: %@",strPhotos);
    //    photos/delete_photo.json?event_id=72&user_id=97&photo_id=289,290
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:event_id forKey:@"event_id"];
    [parameters setObject:user_id forKey:@"user_id"];
    [parameters setObject:strPhotos forKey:@"photo_id"];
    
    [[SnapprintsClient sharedSnapprintsClient] postPath:@"photos/delete_photo.json"
                                             parameters:parameters
                                                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                    NSLog(@"Response for Delete:%@", responseObject);
                                                    [hud hide:YES];
                                                    if ([[responseObject objectForKey:@"status"]
                                                         isEqualToString:@"success"]) {
                                                        for(Photo *photo in arrSelectedPhotos)
                                                        {
                                                            [arrPhotos removeObject:photo];
                                                        }
                                                        newPhotoCount = [arrPhotos count];
                                                        [TSMessage setDefaultViewController:self.navigationController];
                                                        [TSMessage showNotificationWithTitle:@"SNAPprints" subtitle:@"Picture(s) deleted successfully." type:TSMessageNotificationTypeSuccess];
                                                    }
                                                    else {
                                                        [TSMessage setDefaultViewController:self.navigationController];
                                                        [TSMessage
                                                         showNotificationWithTitle:@"Error"
                                                         subtitle:[responseObject
                                                                   objectForKey:@"message"]
                                                         type:TSMessageNotificationTypeError];
                                                    }
                                                    [arrSelectedPhotos removeAllObjects];
                                                    [_collectionView reloadData];
                                                }
                                                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                    NSLog(@"Error: %@", error.description);
                                                    [TSMessage setDefaultViewController:self.navigationController];
                                                    [TSMessage showNotificationWithTitle:@"Error"
                                                                                subtitle:@"There was a problem while deleting picture(s)."
                                                                                    type:TSMessageNotificationTypeError];
                                                    [hud hide:YES];
                                                    [arrSelectedPhotos removeAllObjects];
                                                    [_collectionView reloadData];
                                                    
                                                }];
}

#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex {
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
        imagePicker = nil;
    } else if (actionSheet.tag == ACTIONSHEET_DIRECTIONS_TAG) {
        if (buttonIndex == 0) { // Get Directions pressed
            MKPlacemark *place =
            [[MKPlacemark alloc] initWithCoordinate:self.event.address.coordinate
                                  addressDictionary:nil];
            MKMapItem *destination = [[MKMapItem alloc] initWithPlacemark:place];
            destination.name = self.event.title;
            NSArray *items = [[NSArray alloc] initWithObjects:destination, nil];
            NSDictionary *options = [[NSDictionary alloc]
                                     initWithObjectsAndKeys:MKLaunchOptionsDirectionsModeDriving,
                                     MKLaunchOptionsDirectionsModeKey, nil];
            [MKMapItem openMapsWithItems:items launchOptions:options];
        }
    } else if (actionSheet.tag == ACTIONSHEET_ACTIONS_TAG) {
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"MMMM d h:mm a"];
        
        NSString *price = @"free";
        
        NSString *eventURLString = [NSString
                                    stringWithFormat:@"%@/events/view/%ld", [Constants retriveServerURL],
                                    (long)_event.eventId];
        
        NSString *plaintextMessageWithURL = [NSString
                                             stringWithFormat:
                                             @"Join me at %@ for %@ on %@ through SNAPprints on iOS! %@",
                                             _event.title, price, [df stringFromDate:_event.eventStartDateTime],
                                             eventURLString];
        NSString *plaintextMessageWithoutURL = [NSString
                                                stringWithFormat:
                                                @"Join me at %@ for %@ on %@ through SNAPprints on iOS!",
                                                _event.title, price, [df stringFromDate:_event.eventStartDateTime]];
        
        if (_event.price.floatValue > 0) {
            price = [NSString stringWithFormat:@"$%.2f", _event.price.floatValue];
        }
        
        if (buttonIndex == 0) { // Send an e-mail
            if ([MFMailComposeViewController canSendMail]) {
                MFMailComposeViewController *vc =
                [[MFMailComposeViewController alloc] init];
                [vc setSubject:@"Check out this great event on SNAPprints!"];
                NSString *htmlMessage = [NSString
                                         stringWithFormat:@"<html><body><h3>Join me at this event on "
                                         @"SNAPprints!</h3><p><a "
                                         @"href='%@'>%@</a></p><p>Date: %@</p><p>Price: "
                                         @"%@</p></body></html>",
                                         eventURLString, _event.title,
                                         [df stringFromDate:_event.eventStartDateTime],
                                         price];
                
                [vc setMessageBody:htmlMessage isHTML:YES];
                vc.mailComposeDelegate = self;
                
                [self presentViewController:vc animated:YES completion:nil];
                
            } else {
                UIAlertView *alert =
                [[UIAlertView alloc] initWithTitle:@"SNAPprints"
                                           message:@"Please add mail account from "
                 @"Settings-> Mail-> Add Account"
                                          delegate:nil
                                 cancelButtonTitle:@"OK"
                                 otherButtonTitles:nil, nil];
                [alert show];
            }
        } else if (buttonIndex == 1) { // Send a text message
            if ([MFMessageComposeViewController canSendText]) {
                MFMessageComposeViewController *vc =
                [[MFMessageComposeViewController alloc] init];
                NSString *bodyString = plaintextMessageWithURL;
                [vc setBody:bodyString];
                vc.messageComposeDelegate = self;
                [self presentViewController:vc animated:YES completion:nil];
            }
            else{
                [TSMessage setDefaultViewController:self.navigationController];
                [TSMessage showNotificationWithTitle:@"Error"
                                            subtitle:@"Can't send SMS"
                                                type:TSMessageNotificationTypeError];
            }
        } else if (buttonIndex == 2) {
            // Facebook
            FBShareDialogParams *params = [[FBShareDialogParams alloc] init];
            params.link = [NSURL URLWithString:eventURLString];
            params.name = plaintextMessageWithoutURL;
            //            params.caption = @"Build great social apps and get more
            //            installs.";
            params.picture = [NSURL URLWithString:[_event getImageURL]];
            //            params.description = @"Allow your users to share stories on
            //            Facebook from your app using the iOS SDK.";
            
            if ([FBDialogs canPresentShareDialogWithParams:params]) {
                [FBDialogs
                 presentShareDialogWithLink:params.link
                 name:params.name
                 caption:params.caption
                 description:params.description
                 picture:params.picture
                 clientState:nil
                 handler:^(FBAppCall *call, NSDictionary *results,
                           NSError *error) {
                     if (error) {
                         // An error occurred, we need to handle the
                         // error
                         // See:
                         // https://developers.facebook.com/docs/ios/errors
                     } else {
                         // Success
                         if (results ==
                             FBNativeDialogResultSucceeded)
                             [TSMessage
                              showNotificationInViewController:
                              self title:@"Event shared "
                              @"successfully on "
                              @"facebook."
                              subtitle:@""
                              type:
                              TSMessageNotificationTypeSuccess];
                     }
                 }];
                
            } else {
                NSMutableDictionary *params = [NSMutableDictionary
                                               dictionaryWithObjectsAndKeys:plaintextMessageWithoutURL, @"name",
                                               eventURLString, @"link",
                                               [_event getImageURL], @"picture", nil];
                
                // Show the feed dialog
                [FBWebDialogs
                 presentFeedDialogModallyWithSession:
                 nil parameters:params handler:^(FBWebDialogResult result,
                                                 NSURL *resultURL,
                                                 NSError *error) {
                     if (error) {
                         // An error occurred, we need to handle the error
                         // See: https://developers.facebook.com/docs/ios/errors
                     } else {
                         if (result == FBWebDialogResultDialogNotCompleted) {
                             // User cancelled.
                             
                         } else {
                             // Handle the publish feed callback
                             NSDictionary *urlParams =
                             [self parseURLParams:[resultURL query]];
                             
                             if (![urlParams valueForKey:@"post_id"]) {
                                 // User cancelled.
                                 
                             } else {
                                 // User clicked the Share button
                                 // NSString *result = [NSString stringWithFormat:
                                 // @"Posted story, id: %@", [urlParams
                                 // valueForKey:@"post_id"]];
                                 if (result == FBWebDialogResultDialogCompleted)
                                     [TSMessage
                                      showNotificationInViewController:
                                      self title:@"Event shared successfully on "
                                      @"facebook."
                                      subtitle:@""
                                      type:
                                      TSMessageNotificationTypeSuccess];
                             }
                         }
                     }
                 }];
            }
            
        } else if (buttonIndex == 3) {
            if ([SLComposeViewController
                 isAvailableForServiceType:SLServiceTypeTwitter]) {
                SLComposeViewController *vc = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
                vc.completionHandler = ^(SLComposeViewControllerResult result) {
                    switch (result) {
                            //  This means the user cancelled without sending the Tweet
                        case SLComposeViewControllerResultCancelled:
                            break;
                            //  This means the user hit 'Send'
                        case SLComposeViewControllerResultDone:
                            [TSMessage
                             showNotificationInViewController:
                             self title:@"Event shared successfully on twitter."
                             subtitle:@""
                             type:
                             TSMessageNotificationTypeSuccess];
                            break;
                    }
                };
                [vc addURL:[NSURL URLWithString:eventURLString]];
                [vc addImage:_event.thumbnailImage];
                [self presentViewController:vc animated:YES completion:nil];
            } else {
                //        NSString *twitterURLString = [plaintextMessageWithoutURL urlencode];
                //
                //        NSString *str =
                //            [NSString stringWithFormat:@"twitter://%@", twitterURLString];
                //        if ([[UIApplication sharedApplication]
                //                canOpenURL:[NSURL URLWithString:str]]) {
                //          [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
                //        }
                [TSMessage setDefaultViewController:self.navigationController];
                [TSMessage
                 showNotificationWithTitle:@"No Twitter Accounts"
                 subtitle:@"There are no Twitter accounts configured."
                 @"\nPlease add Twitter account from Settings-> Twitter."
                 type:TSMessageNotificationTypeWarning];
            }
            
            // Twitter
            // 1. Try using system twitter
            
            // 2. Try using the Twitter application
        }
        else if (buttonIndex == 4) {
            // Flag as inappropriate
            [self flagEvent];
        }
    } else if (actionSheet.tag == ACTIONSHEET_EDIT_EVENT) {
        if (buttonIndex == 0) {
            NSLog(@"Delete Event");
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@"SNAPprints"
                                      message:@"Are you sure you want to delete this event?"
                                      delegate:self
                                      cancelButtonTitle:nil
                                      otherButtonTitles:@"Yes", @"No", nil];
            [alertView show];
            alertView.tag = 123;
        } else if (buttonIndex == 1) {
            NSLog(@"Edit Event");
            if ([_event.eventEndDateTime timeIntervalSinceDate:[NSDate date]] > 0) {
                isEditEvent = YES;
                AddEventViewController *editEventVC = [[AddEventViewController alloc]
                                                       initWithNibName:@"AddEventViewController"
                                                       bundle:[NSBundle mainBundle]];
                editEventVC.event = [_event copy];
                editEventVC.event.address = [_event.address copy];
                editEventVC.event.eventUser = [_event.eventUser copy];
                editEventVC.event.company = [_event.company copy];
                // editEventVC.newEvent = [_event copy];
                [self.navigationController pushViewController:editEventVC animated:YES];
                
            } else {
                [TSMessage setDefaultViewController:self.navigationController];
                [TSMessage showNotificationWithTitle:@"Error"
                                            subtitle:@"Event is expired. So you can't "
                 @"edit this event."
                                                type:TSMessageNotificationTypeError];
            }
        }
    }
}

#pragma mark - MessageDelegate Methods
- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
    switch (result) {
        case MFMailComposeResultSent:
            [TSMessage
             showNotificationInViewController:self
             title:@"Email sent successfully."
             subtitle:@""
             type:TSMessageNotificationTypeSuccess];
            break;
            
        default:
            break;
    }
}
- (void)messageComposeViewController:
(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UIImagePickerViewControllerDelegate methods
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *originalImage =
    [info objectForKey:UIImagePickerControllerOriginalImage];
    if (originalImage.size.width < 300 && originalImage.size.height < 300) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"SNAPprints"
                              message:@"Please select image greater than 300x300 pixels."
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil, nil];
        [alert show];
        
    } else {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        if ([[defaults valueForKeyPath:@"savephoto"] isEqualToString:@"1"] &&
            ![info valueForKey:@"UIImagePickerControllerReferenceURL"]) {
            [library saveImage:originalImage
                       toAlbum:@"SNAPprints"
                    completion:^(NSURL *assetURL, NSError *error) {
                        
                        NSLog(@"Saved Successfully url = %@ error = %@",
                              [assetURL absoluteString], [error description]);
                    }
                       failure:^(NSError *error) {
                           NSLog(@"Saved error = %@", [error description]);
                       }];
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
        if ([arrPhotos count] >= [Photo_Limit integerValue]) {
            [TSMessage
             showNotificationInViewController:self
             title:@""
             subtitle:@"The maximum photo uploading limit "
             @"for this event is reached."
             type:TSMessageNotificationTypeError];
        } else {
            UIImage *newImage = [originalImage imageByCorrectingOrientation];
            
            AddPhotoDetailsViewController *addPhoto =
            [[AddPhotoDetailsViewController alloc]
             initWithNibName:@"AddPhotoDetailsViewController"
             bundle:[NSBundle mainBundle]];
            addPhoto.originalImg = newImage;
            addPhoto.event = _event;
            addPhoto.delegate = self;
            [self.navigationController pushViewController:addPhoto animated:YES];
        }
    }
}

#pragma mark - UINavigation controller delegate

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault
                                                animated:NO];
}

#pragma mark - UICollectionViewDataSource methods
- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return [arrPhotos count];
}

- (NSInteger)numberOfSectionsInCollectionView:
(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ImageCell *cell = [collectionView
                       dequeueReusableCellWithReuseIdentifier:kCollectionViewIdentifier
                       forIndexPath:indexPath];
    
    //  [cell.imageView.layer setCornerRadius:10.0f];
    //  [cell.imageView.layer setBorderColor:[[UIColor grayColor] CGColor]];
    //  [cell.imageView.layer setBorderWidth:0.5f];
    
//    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc]
//                                         initWithFrame:CGRectMake(cell.imageView.frame.size.width / 2 - 10,
//                                                                  cell.imageView.frame.size.height / 2 - 10, 20, 20)];
//    [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
//    [cell.imageView addSubview:activity];
//    [activity startAnimating];
    
    Photo *photo = [arrPhotos objectAtIndex:indexPath.row];
    if ([photo.thumbnail_filename isEqualToString:@""] ||
        [photo.thumbnail_filename isKindOfClass:[NSNull class]] ||
        photo.thumbnail_filename == nil) {
        if (photo.thumbnailImage) {
            
            [cell.imageView setImage:photo.thumbnailImage];
        }
        //[activity stopAnimating];
    } else {
        //cell.imageView.image = nil;
        NSURL *thumbnailURL = [NSURL
                               URLWithString:[NSString stringWithFormat:@"%@/uploads/photos/%@",
                                              [Constants retriveServerURL],
                                              photo.thumbnail_filename]];
        [cell.imageView setImageWithURL:thumbnailURL usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        /*NSURLRequest *req = [NSURLRequest requestWithURL:thumbnailURL];
        BOOL valid = [NSURLConnection canHandleRequest:req];
        if (valid) {
            AFImageRequestOperation *operation = [AFImageRequestOperation
                                                  imageRequestOperationWithRequest:req
                                                  imageProcessingBlock:nil
                                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response,
                                                            UIImage *image) {
                                                      
                                                      dispatch_async(dispatch_get_global_queue(
                                                                                               DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                                                                     ^{
                                                                         
                                                                         UIImage *scaledImgH =
                                                                         [image imageToFitSize:cell.imageView.frame.size
                                                                                        method:MGImageResizeScale];
                                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                                             if (scaledImgH) {
                                                                                 [activity stopAnimating];
                                                                                 UICollectionViewCell *updateCell =
                                                                                 [_collectionView cellForItemAtIndexPath:indexPath];
                                                                                 if (updateCell) {
                                                                                     [cell.imageView setImage:scaledImgH];
                                                                                 }
                                                                             }
                                                                         });
                                                                     });
                                                  }
                                                  failure:^(NSURLRequest *request, NSHTTPURLResponse *response,
                                                            NSError *error) { [activity stopAnimating]; }];
            [operation start];
        }*/
    }
    cell.isSelected = NO;
    [cell.checkImageView setImage:nil];
    return cell;
}

#pragma mark - UICollectionViewDelegate methods
- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([arrPhotos count] > 0) {
        if(isDeleteClicked)
        {
            ImageCell *cell = (ImageCell*)[collectionView cellForItemAtIndexPath:indexPath];
            if(cell.isSelected)
            {
                cell.isSelected = NO;
                [cell.checkImageView setImage:nil];
                [arrSelectedPhotos removeObject:[arrPhotos objectAtIndex:indexPath.item]];
            }
            else
            {
                cell.isSelected = YES;
                [cell.checkImageView setImage:[UIImage imageNamed:@"Overlay"]];
                [arrSelectedPhotos addObject:[arrPhotos objectAtIndex:indexPath.item]];
            }
        }
        else
        {
            SlideshowViewController *slideshowVC = [[SlideshowViewController alloc]
                                                    initWithNibName:@"SlideshowViewController"
                                                    bundle:[NSBundle mainBundle]
                                                    andPhotos:arrPhotos];
            slideshowVC.isEventExpired = isExpired;
            slideshowVC.event = self.event;
            slideshowVC.delegate = self;
            if (indexPath.section == 0)
                slideshowVC.currentPage = indexPath.row;
            
            [self.navigationController pushViewController:slideshowVC animated:YES];
        }
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(5, 5, 5, 5);
    //return UIEdgeInsetsMake(2, 2, 2, 2);
}

#pragma mark - UICollectionViewFlowLayout methods

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //return CGSizeMake(96.f, 96.f);
    return CGSizeMake(102.f, 102.f);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        HeaderView *headerView;
        if (kind == UICollectionElementKindSectionHeader) {
            headerView = [collectionView
                          dequeueReusableSupplementaryViewOfKind:
                          UICollectionElementKindSectionHeader
                          withReuseIdentifier:kCollectionViewHeaderIdentifier
                          forIndexPath:indexPath];
            [headerView addSubview:_HeaderView];
        }
        return headerView;
        
    } else
        return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:
(UICollectionViewLayout *)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section {
    if (section == 0)
        return CGSizeMake(_HeaderView.frame.size.width,
                          _HeaderView.frame.size.height);
    else
        return CGSizeMake(0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionView *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 2;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 2;
}

#pragma mark - AddPhotoDetail controller delegate
- (void)didAddPhoto:(Photo *)photo {
    [self getPhotos];
}

#pragma mark - SlideShow view controller delegate
- (void)refreshPhotos {
    [self getPhotos];
}

#pragma mark - UIAlertview delegate
- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 123) {
        
        if (buttonIndex == 0) {
            
            hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
            [self.view addSubview:hud];
            hud.labelText = @"Loading...";
            [hud show:YES];
            [self removeEvent];
        }
    }
    
    else if(alertView.tag==100)
    {
        if (buttonIndex == 0)
        {
            if(hud == nil)
            {
                hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
                [self.view addSubview:hud];
            }
            [hud show:YES];
            [self deletePhotos:arrSelectedPhotos];
        }
        
    }
}

@end
