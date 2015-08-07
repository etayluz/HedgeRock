//
//  InvitedVC.m
//  SNAPprints
//
//  Created by Etay Luz on 02/07/14.
//  Copyright (c) 2014 Etay Luz. All rights reserved.
//

#import "InvitedVC.h"
#import "TSMessage.h"

#define TABLE_HEADER_HEIGHT 35

@interface InvitedVC ()

@property(weak, nonatomic) IBOutlet UILabel *lblErrorMessage;

@end

@implementation InvitedVC

@synthesize event;

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
  self.navigationController.navigationBar.tintColor =
      UIColorFromRGB(COLOR_LIGHT_BLUE);
  [_lblErrorMessage setFont:[UIFont fontWithName:kAppSupportedFontLight size:17.f]];
  // Do any additional setup after loading the view from its nib.
  //    UIImageView *headerLogoView = [[UIImageView alloc]
  //    initWithImage:[UIImage imageNamed:@"new-logo"]];
  //    headerLogoView.frame =
  //    CGRectMake(105.0f,5.0f,headerLogoView.frame.size.width ,
  //    headerLogoView.frame.size.height);
  //    [self.navigationController.navigationBar addSubview:headerLogoView];

    UILabel *lable = [[UILabel alloc] init];
    lable.frame = self.navigationController.navigationBar.frame;
    lable.numberOfLines = 2;
    lable.text = @"Invited Guests";
    [lable sizeToFit];
    lable.textColor = [UIColor grayColor];
    lable.font = [UIFont fontWithName:kAppSupportedFontBold size:16.0f];
    self.navigationItem.titleView = lable;
    
  arrInvited = [[NSMutableArray alloc] init];
  invited = [[InvitedGuest alloc] init];
  hud = [[MBProgressHUD alloc] initWithView:self.view];
  hud.labelText = @"Loading...";
  [self.view addSubview:hud];
  [hud show:YES];
  NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
  if ([event.eventEndDateTime timeIntervalSinceDate:[NSDate date]] < 0) {
    [_btnInvite setEnabled:NO];
  }
  NSString *strEventId =
      [NSString stringWithFormat:@"%ld", (long)event.eventId];
  [parameters setObject:strEventId forKey:@"event_id"];
  [self getInvitedMembers:parameters];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark - Action events

- (IBAction)btnInviteClicked:(id)sender {
  ChooseContactViewController *chooseContactVC =
      [[ChooseContactViewController alloc]
          initWithNibName:@"ChooseContactViewController"
                   bundle:nil];
  chooseContactVC.event = event;
  [self.navigationController pushViewController:chooseContactVC animated:YES];
}

#pragma mark
#pragma mark - UITableview Datasource and delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}
- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
  return [arrInvited count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *cellIdentifier = @"Cell";
  UITableViewCell *cell =
      [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                  reuseIdentifier:cellIdentifier];
  }
  invited = [arrInvited objectAtIndex:indexPath.row];
  if ([invited.name isEqualToString:@" "] ||
      [invited.name isKindOfClass:[NSNull class]]) {
    [cell.textLabel setFont:[UIFont fontWithName:kAppSupportedFontLight size:17.f]];
    [cell.textLabel setTextColor:UIColorFromRGB(COLOR_LIGHT_BLUE)];
    cell.textLabel.text = invited.email;
  } else {
    [cell.textLabel setFont:[UIFont fontWithName:kAppSupportedFontLight size:17.f]];
    [cell.textLabel setTextColor:[UIColor grayColor]];
    [cell.detailTextLabel
        setFont:[UIFont fontWithName:kAppSupportedFontLight size:15.f]];
    [cell.detailTextLabel setTextColor:UIColorFromRGB(COLOR_LIGHT_BLUE)];
    cell.textLabel.text = invited.name;
    cell.detailTextLabel.text = invited.email;
  }
  return cell;
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
  label.text = @"Invited Guests";
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
#pragma mark - API call

/*
 Function: getInvitedMembers
 Decription: Returns the list of members list invited for particular event using
 Webservice.
 Return: Void
 Param: NSDictionary
 */
- (void)getInvitedMembers:(NSDictionary *)parameters {
  //  http://snapprints.benchmarkitsolution.com/invites/invited_guests.json?event_id=33
  // {"status":"success","no_of_guests":1,"guests":[{"name":"","email":"sandipy@gmail.com"}]}
  [[SnapprintsClient sharedSnapprintsClient]
      getPath:@"invites/invited_guests.json"
      parameters:parameters
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          id response = [responseObject objectForKey:@"status"];
          if ([response isEqualToString:@"success"]) {
            if ([arrInvited count] > 0)
              [arrInvited removeAllObjects];
            NSArray *arrGuest = [responseObject objectForKey:@"guests"];
            for (NSDictionary *guestDict in arrGuest) {
              NSString *strName = [guestDict objectForKey:@"name"];
              NSString *strEmail = [guestDict objectForKey:@"email"];
              NSLog(@"Name :%@, Email: %@", strName, strEmail);
              InvitedGuest *invitedGuest = [[InvitedGuest alloc] init];
              invitedGuest.name = strName;
              invitedGuest.email = strEmail;
              [arrInvited addObject:invitedGuest];
            }
            [_tblInvited reloadData];
            [_lblErrorMessage setHidden:YES];
            [_tblInvited setScrollEnabled:YES];

          } else {
            // UIAlertView *alert = [[UIAlertView alloc]
            // initWithTitle:@"SNAPprints" message:[responseObject
            // objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK"
            // otherButtonTitles:nil, nil];
            //[alert show];
            _lblErrorMessage.text = [responseObject objectForKey:@"message"];
            [_lblErrorMessage setHidden:NO];
            [_tblInvited setScrollEnabled:NO];
            //            [TSMessage
            //            setDefaultViewController:self.navigationController];
            //            [TSMessage showNotificationWithTitle:@"Invited guests"
            //            subtitle:[responseObject objectForKey:@"message"]
            //            type:TSMessageNotificationTypeMessage];
          }
          [hud hide:YES];
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          NSLog(@"%@", error.description);
          [hud hide:YES];
      }];
}

@end
