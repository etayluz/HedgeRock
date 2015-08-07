//
//  Cho0seContactViewController.h
//  SNAPprints
//
//  Created by Etay Luz on 09/07/14.
//  Copyright (c) 2014 Etay Luz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"

@interface ChooseContactViewController : UIViewController {
}

@property(weak, nonatomic) IBOutlet UIButton *btnChooseContacts;
@property(weak, nonatomic) IBOutlet UIButton *btnSubmit;
@property(weak, nonatomic) IBOutlet UITextView *txtViewEmails;
@property(weak, nonatomic) IBOutlet UILabel *lblTitle;
@property(weak, nonatomic) IBOutlet UILabel *lblOR;
@property(weak, nonatomic) IBOutlet UILabel *lblEnterEmail;
@property(weak, nonatomic) IBOutlet UILabel *lblExample;
@property(strong, nonatomic) Event *event;
@property (weak, nonatomic) IBOutlet UIButton *btnLater;
@property (weak, nonatomic) IBOutlet UILabel *lblLater;
- (IBAction)btnLaterClicked:(id)sender;
- (IBAction)btnSubmit:(id)sender;

@end
