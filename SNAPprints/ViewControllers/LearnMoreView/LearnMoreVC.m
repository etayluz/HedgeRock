//
//  LearnMoreVC.m
//  SNAPprints
//
//  Created by Etay Luz on 22/05/14.
//  Copyright (c) 2014 Etay Luz. All rights reserved.
//

#import "LearnMoreVC.h"
#import "UIImage+ProportionalFill.h"
#import "AFHTTPClient.h"
#import "SqliteDBClass.h"
//#import "FDStatusBarNotifierView.h"

@interface LearnMoreVC ()
{
    NSString *strEventCreator;
    SqliteDBClass *dbClass;
}
@end

@implementation LearnMoreVC

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
    [self.navigationController.navigationBar
     setBarTintColor:[UIColor whiteColor]];
    // Do any additional setup after loading the view from its nib.
    dbClass = [[SqliteDBClass alloc]init];
//    UIImageView *headerLogoView =
//    [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"new-logo"]];
//    headerLogoView.frame =
//    CGRectMake(107.0f, 5.0f, headerLogoView.frame.size.width,
//               headerLogoView.frame.size.height);
//    [self.navigationController.navigationBar addSubview:headerLogoView];
    
    UILabel *lable = [[UILabel alloc] init];
    lable.frame = self.navigationController.navigationBar.frame;
    lable.numberOfLines = 2;
    lable.text = self.event.title;
    [lable sizeToFit];
    lable.textColor = [UIColor grayColor];
    lable.font = [UIFont fontWithName:kAppSupportedFontBold size:16.0f];
    self.navigationItem.titleView = lable;
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] init];
    UIButton *btnCancel =
    [[UIButton alloc] initWithFrame:CGRectMake(0, 10, 20, 20)];
    [btnCancel setBackgroundImage:[UIImage imageNamed:@"close-icon"]
                         forState:UIControlStateNormal];
    [btnCancel addTarget:self
                  action:@selector(dismiss:)
        forControlEvents:UIControlEventTouchUpInside];
    [rightBarButtonItem setCustomView:btnCancel];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
    [self.navigationItem.rightBarButtonItem
     setTintColor:UIColorFromRGB(COLOR_LIGHT_BLUE)];
    [self getUsername];
    [_lblTitle setFont:[UIFont fontWithName:kAppSupportedFontBold size:20]];
    [_lblDescription setFont:[UIFont fontWithName:kAppSupportedFontNormal size:14]]; // 12
    [_lblEventTime setFont:[UIFont fontWithName:kAppSupportedFontNormal size:12]]; // 10
    [_lblUploadLimit setFont:[UIFont fontWithName:kAppSupportedFontNormal size:12]]; // 10
    [_lblUsername setFont:[UIFont fontWithName:kAppSupportedFontNormal size:15]];
    [_btnWebsite.titleLabel
     setFont:[UIFont fontWithName:kAppSupportedFontNormal size:12]]; // 10
    
    strEventCreator = _event.eventUser.username;
    
    _lblDescription.text = _event.description;
    
    NSInteger loggedUser_id = [[[NSUserDefaults standardUserDefaults]
                                objectForKey:@"user_id"] integerValue];
    if(loggedUser_id != _event.eventUser.userId)
    {
        [_calendarSwitch setHidden:NO];
        [_lblCalendar setHidden:NO];
        [self checkEventAddedToCalendar];
    }
    else
    {
        CGRect newDetailView = _detailView.frame;
        newDetailView.size.height = _detailView.frame.size.height - _calendarSwitch.frame.size.height;
        _detailView.frame = newDetailView;
    }
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName :
                                     [UIFont systemFontOfSize:_lblDescription.font.pointSize]
                                 };
    CGSize maximumLabelSize = CGSizeMake(_lblDescription.frame.size.width, 9999);
    CGRect expectedLabelRect = [[_lblDescription text]
                                boundingRectWithSize:maximumLabelSize
                                options:(NSStringDrawingUsesLineFragmentOrigin |
                                         NSStringDrawingUsesFontLeading)
                                attributes:attributes
                                context:nil];
    CGRect frameDesc = _lblDescription.frame;
    frameDesc.size.height = expectedLabelRect.size.height;
    _lblDescription.frame = frameDesc;
    [_lblDescription sizeToFit];
    
    CGRect descView = _detailView.frame;
    descView.origin.y =
    _lblDescription.frame.origin.y + _lblDescription.frame.size.height;
    _detailView.frame = descView;
    
    _lblTitle.text = _event.title;
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setTimeZone:[NSTimeZone localTimeZone]];
    
    // For event start datetime
    NSDate *date = _event.eventStartDateTime;
    static NSString *format1 = @"dd MMM yyyy";
    [df setDateFormat:format1];
    NSString *strDatePart1 = [df stringFromDate:date];
    static NSString *format2 = @"hh:mm a";
    [df setDateFormat:format2];
    NSString *strDatePart2 = [df stringFromDate:date];
    
    NSString *strStartDate =
    [NSString stringWithFormat:@"%@   %@", strDatePart1, strDatePart2];
    
    // For event end datetime
    NSDate *enddate = _event.eventEndDateTime;
    static NSString *format1End = @"dd MMM yyyy";
    [df setDateFormat:format1End];
    NSString *endDatePart1 = [df stringFromDate:enddate];
    static NSString *format2End = @"hh:mm a";
    [df setDateFormat:format2End];
    NSString *endDatePart2 = [df stringFromDate:enddate];
    NSString *strEndDate =
    [NSString stringWithFormat:@"%@   %@", endDatePart1, endDatePart2];
    
    _lblEventTime.text =
    [NSString stringWithFormat:@"%@  TO  %@", strStartDate, strEndDate];
    
    _lblUploadLimit.text =
    [NSString stringWithFormat:@"You can upload up to %ld snaps.",
     (long)_event.photoLimit];
    
    NSString *eventURLString = [NSString
                                stringWithFormat:@"%@/events/view/%ld", [Constants retriveServerURL],
                                (long)_event.eventId];
    [_btnWebsite setTitle:eventURLString forState:UIControlStateNormal];
    
    // _scrollView.contentSize = CGSizeMake(320,
    // _detailView.frame.origin.y+_detailView.frame.size.height);
    float detailView_Offset =
    _detailView.frame.origin.y + _detailView.frame.size.height;
    float max = [[UIScreen mainScreen] bounds].size.height -
    (self.navigationController.navigationBar.frame.size.height + 20 +
     _creatorsView.frame.size.height);
    if (isiPhone5) {
        if (detailView_Offset > max) {
            [self calculateOffsetForView:_creatorsView.frame];
        }
        
    } else {
        if (detailView_Offset > max) {
            [self calculateOffsetForView:_creatorsView.frame];
        } else {
            CGRect nextView = _creatorsView.frame;
            float diff =
            [[UIScreen mainScreen] bounds].size.height - nextView.size.height;
            if (max < diff)
                nextView.origin.y = diff - nextView.size.height + 20;
            else
                nextView.origin.y = max;
            _creatorsView.frame = nextView;
        }
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom Methods
/*
 Function: calculateOffsetForView
 Decription: Calculate frame for nextview.
 Return: Void
 Param: CGRect
 */

- (void)calculateOffsetForView:(CGRect)nextView {
    nextView.origin.y =
    _detailView.frame.origin.y + _detailView.frame.size.height;
    _creatorsView.frame = nextView;
    _scrollView.contentSize = CGSizeMake(
                                         320, _creatorsView.frame.origin.y + _creatorsView.frame.size.height);
}

- (void)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
            [_calendarSwitch setOn:YES];
            [_calendarSwitch setUserInteractionEnabled:NO];
            break;
        }
    }
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
                 
                 [_calendarSwitch setOn:YES];
                 [_calendarSwitch setUserInteractionEnabled:NO];
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
                                 [_calendarSwitch setOn:NO];
                                
                            });
         }
     }];
}

#pragma mark - Action Events
- (IBAction)btnWebsiteClicked:(id)sender {
    NSURL *url = [NSURL URLWithString:_btnWebsite.titleLabel.text];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    BOOL valid = [NSURLConnection canHandleRequest:req];
    if (valid) {
        TOWebViewController *webVC = [[TOWebViewController alloc] initWithURL:url];
        [self presentViewController:[[UINavigationController alloc]
                                     initWithRootViewController:webVC]
                           animated:YES
                         completion:nil];
    } else {
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:@"SNAP prints"
                                   message:@"Website is not valid"
                                  delegate:nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (IBAction)switchValueChanged:(UISwitch *)sender {
    if(sender.on)
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
}

#pragma mark- API Call
/*
 Function: getUsername
 Decription: This API gives information of event creator.
 Return: Void
 */
-(void)getUsername
{
    //http://71.43.59.189:10028/users/info.json?id=97
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc]init];
    NSString *user_id = [NSString stringWithFormat:@"%ld",(long)_event.eventUser.userId];
    [parameters setObject:user_id forKey:@"id"];
    [[SnapprintsClient sharedSnapprintsClient] getPath:@"users/info.json" parameters:parameters
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   if([[responseObject objectForKey:@"status"]isEqualToString:@"success"])
                                                   {
                                                       NSString *strUsername;
                                                       NSDictionary *userDict = [responseObject objectForKey:@"user"];
                                                       if(userDict)
                                                       {
                                                           NSString *strFname = [userDict objectForKey:@"fname"];
                                                           NSString *strLname = [userDict objectForKey:@"lname"];
                                                           //NSString *userName = [userDict objectForKey:@"username"];
                                                           if (![strFname isKindOfClass:[NSNull class]] && ![strLname isKindOfClass:[NSNull class]])
                                                           {
                                                               if(![strFname isEqualToString:@""] || ![strLname isEqualToString:@""])
                                                                   strUsername = [NSString stringWithFormat:@"%@ %@", strFname, strLname];
                                                               else
                                                                   strUsername =[userDict objectForKey:@"username"];
                                                               
                                                           }
                                                           else
                                                               strUsername =[userDict objectForKey:@"username"];
                                                           
                                                           _lblUsername.text = strUsername;
                                                       }
                                                       else    //If user dictionary getting NULL.
                                                       {
                                                           if (strEventCreator)
                                                               _lblUsername.text = strEventCreator;
                                                       }
                                                   }
                                                   else    //If status other than success.
                                                   {
                                                       if (strEventCreator)
                                                           _lblUsername.text = strEventCreator;
                                                   }
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   if (strEventCreator)
                                                       _lblUsername.text = strEventCreator;
                                               }];
}
@end
