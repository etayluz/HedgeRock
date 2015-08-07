//
//  LearnMoreVC.h
//  SNAPprints
//
//  Created by Etay Luz on 22/05/14.
//  Copyright (c) 2014 Etay Luz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"
#import "TOWebViewController.h"
#import <EventKit/EventKit.h>
#import "TSMessage.h"

@interface LearnMoreVC : UIViewController

@property(weak, nonatomic) IBOutlet UILabel *lblTitle;

@property(weak, nonatomic) IBOutlet UILabel *lblEventTime;

@property(weak, nonatomic) IBOutlet UILabel *lblUploadLimit;

@property(weak, nonatomic) IBOutlet UILabel *lblWebsite;

@property(nonatomic, retain) Event *event;

@property(weak, nonatomic) IBOutlet UIView *detailView;

@property(weak, nonatomic) IBOutlet UILabel *lblDescription;

@property(weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property(weak, nonatomic) IBOutlet UILabel *lblAbout;

@property(weak, nonatomic) IBOutlet UIButton *btnWebsite;

@property(weak, nonatomic) IBOutlet UIView *creatorsView;

@property(weak, nonatomic) IBOutlet UILabel *lblUsername;

@property(weak, nonatomic) IBOutlet UISwitch *calendarSwitch;

@property(nonatomic, retain) EKEventStore *eventStore;

@property (weak, nonatomic) IBOutlet UILabel *lblCalendar;

- (IBAction)btnWebsiteClicked:(id)sender;

- (IBAction)switchValueChanged:(UISwitch *)sender;


@end
