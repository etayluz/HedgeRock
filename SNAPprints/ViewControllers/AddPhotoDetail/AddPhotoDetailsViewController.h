//
//  AddPhotoDetailsViewController.h
//  SNAPprints
//
//  Created by Etay Luz on 11/10/13.
//  Copyright (c) 2013 Etay Luz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"
#import "MBProgressHUD.h"
#import "AFHTTPRequestOperation.h"

@class AddPhotoDetailsViewController;
@class Photo;

@protocol AddPhotoDetailsViewControllerDelegate <NSObject>

- (void)didAddPhoto:(Photo *)photo;

@end

@interface AddPhotoDetailsViewController : UIViewController <UITextViewDelegate>

@property(nonatomic, retain) IBOutlet UITextView *textView;
@property(nonatomic, retain) IBOutlet UIButton *addPhotoButton;
@property(nonatomic, retain) IBOutlet UIImageView *thumbnailImageView;
@property(nonatomic, retain) IBOutlet UILabel *addCaptionLabel;
@property(nonatomic, retain) Photo *photo;
@property(strong, nonatomic) UIImage *thumbnailImg;
@property(strong, nonatomic) UIImage *originalImg;
@property(strong, nonatomic) Event *event;
@property id delegate;
@property (weak, nonatomic) IBOutlet UILabel *lblDisclaimer;

- (IBAction)tappedAddButton:(id)sender;

@end
