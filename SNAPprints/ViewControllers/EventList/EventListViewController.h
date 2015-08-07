//
//  EventListViewController.h
//  SNAPprints
//
//  Created by Etay Luz on 9/16/13.
//  Copyright (c) 2013 Etay Luz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventTableViewCell.h"
#import "MFSideMenu.h"
#import "EGORefreshTableHeaderView.h"
#import "FirstScreenViewController.h"
#import "AFNetworking.h"
#import "AppDelegate.h"
#import "SearchViewController.h"
//#import "GADBannerView.h"

#import <RevMobAds/RevMobAds.h>

@interface EventListViewController
    : UIViewController <UISearchBarDelegate, UITableViewDataSource,
                        UITableViewDelegate, EGORefreshTableHeaderDelegate,
                        FirstScreenViewControllerDelegate, SearchVCDelegate, RevMobAdsDelegate> {

  BOOL _reloading,isFromAdavanceSearch;
  AppDelegate *appDelegate;
 // GADBannerView *bannerView_;
  CLLocation *location;
 // GADRequest *add_request;
}

@property (nonatomic, strong)RevMobBanner *bannerWindow;

@property(nonatomic, retain) EGORefreshTableHeaderView *_refreshHeaderView;
@property(nonatomic, retain) IBOutlet UITableView *tableView;
@property(nonatomic, retain) NSMutableArray *tableData;
@property(nonatomic, retain) NSMutableArray *resultTableData;
@property(nonatomic, retain) AFJSONRequestOperation *operation;

@property NSInteger userID;
@property(strong, nonatomic) IBOutlet UIView *tableHeader;
@property(weak, nonatomic) IBOutlet UILabel *headerTitle;
@property(weak, nonatomic) IBOutlet UIButton *btnReset;
- (void)getEventsForUser:(NSInteger)userID;
- (void)getEventsForMyEvents:(NSInteger)userID;
- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;
- (IBAction)btnResetClicked:(id)sender;

@end
