//
//  InvitedVC.h
//  SNAPprints
//
//  Created by Etay Luz on 02/07/14.
//  Copyright (c) 2014 Etay Luz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "InvitedGuest.h"
#import "Event.h"
#import "ChooseContactViewController.h"

@interface InvitedVC : UIViewController {
  NSMutableArray *arrInvited;
  MBProgressHUD *hud;
  InvitedGuest *invited;
}

@property(weak, nonatomic) IBOutlet UITableView *tblInvited;

@property(weak, nonatomic) IBOutlet UIButton *btnInvite;

@property(strong, nonatomic) Event *event;

- (IBAction)btnInviteClicked:(id)sender;

@end
