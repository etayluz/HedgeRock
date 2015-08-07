//
//  InviteVC.h
//  SNAPprints
//
//  Created by Etay Luz on 27/06/14.
//  Copyright (c) 2014 Etay Luz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import "ContactInformation.h"
#import "MBProgressHUD.h"
#import "SqliteDBClass.h"
#import "InviteCell.h"
#import "EventListViewController.h"

@interface InviteVC : UIViewController <MBProgressHUDDelegate>

@property(strong, nonatomic) MBProgressHUD *hud;
@property(strong, nonatomic) SqliteDBClass *dbClass;
@property(strong, nonatomic) IBOutlet NSMutableArray *arrSelected;
@property(weak, nonatomic) IBOutlet UITableView *tblEmail;
@property(weak, nonatomic) IBOutlet UILabel *lblErrorMessage;

@property(strong, nonatomic) NSMutableArray *arrEmails;

@property(strong, nonatomic) Event *event;

@property(weak, nonatomic) IBOutlet UIButton *btnInvite;

@end
