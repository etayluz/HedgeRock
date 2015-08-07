//
//  EventDetailVC.h
//  SNAPprints
//
//  Created by Etay Luz on 22/05/14.
//  Copyright (c) 2014 Etay Luz. All rights reserved.
//

#import "SqliteDBClass.h"
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MessageUI.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Social/Social.h>

#import "AFHTTPRequestOperation.h"
#import "MBProgressHUD.h"
#import "TSMessage.h"
#import "UIImage+CFT.h"
#import "UIImage+ProportionalFill.h"
#import "UIImageView+AFNetworking.h"
#import "NSString+CFT.h"

#import "Event.h"
#import "PinAnnotation.h"
#import "Photo.h"
#import "AddPhotoDetailsViewController.h"
#import "SlideshowViewController.h"
#import "MapViewController.h"
#import "LearnMoreVC.h"
#import <AssetsLibrary/AssetsLibrary.h>

#import "UIImageView+AFNetworking.h"
#import "PAImageView.h"
#import "Photo.h"

@protocol EventDetailsDelegate <NSObject>
@optional
- (void)refreshEventList;
@end

@interface EventDetailVC
    : UIViewController <UIActionSheetDelegate, MKMapViewDelegate,
                        UIImagePickerControllerDelegate,
                        AddPhotoDetailsViewControllerDelegate,
                        MFMessageComposeViewControllerDelegate,
                        MFMailComposeViewControllerDelegate,
                        UINavigationControllerDelegate,
                        UICollectionViewDataSource, UICollectionViewDelegate,
                        UICollectionViewDelegateFlowLayout, SlideshowVCDelegate,
                        UIAlertViewDelegate> {
  MBProgressHUD *hud;
  BOOL isExpired;
  NSInteger oldPhotoCount, newPhotoCount;
  ALAssetsLibrary *library;
  BOOL IsGotPhotoResponse;
    PAImageView *avatarView;
    SqliteDBClass *dbClass;
}
- (IBAction)btnSaveDateToCalender:(UIButton *)sender;
@property(nonatomic, retain) EKEventStore *eventStore;
@property (weak, nonatomic) IBOutlet UIButton *btnSaveDateToCalender;

@property(nonatomic, weak) id<EventDetailsDelegate> delegate;
@property(weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property(weak, nonatomic) IBOutlet UILabel *lblPhotoUploaded;

@property(weak, nonatomic) IBOutlet UILabel *lblTimeRemaining;

@property(weak, nonatomic) IBOutlet UIButton *btnPhoto;

@property(weak, nonatomic) IBOutlet UIView *bottomView;

@property(weak, nonatomic) IBOutlet UIView *HeaderView;

@property(weak, nonatomic) IBOutlet UILabel *lblTitle;

@property(weak, nonatomic) IBOutlet UILabel *lblEventTime;

@property(weak, nonatomic) IBOutlet UILabel *lblPrice;

@property(weak, nonatomic) IBOutlet UILabel *lblPhotos;

@property(weak, nonatomic) IBOutlet UILabel *lblAddress;

@property(weak, nonatomic) IBOutlet UILabel *lblDescription;

@property(weak, nonatomic) IBOutlet UIButton *btnDescription;

@property(weak, nonatomic) IBOutlet UIButton *btnShowMap;

@property(weak, nonatomic) IBOutlet UIImageView *mapImage;

@property(weak, nonatomic) IBOutlet UIButton *btnInvited;

@property(weak, nonatomic) IBOutlet UIView *viewbelowAddress;

@property(weak, nonatomic) IBOutlet UIView *viewaboveAddress;

@property(strong, nonatomic) UIImagePickerController *pickerController;

@property (strong, nonatomic) IBOutlet UIImageView *imgPrivate;

@property(strong, nonatomic) Event *event;

@property NSInteger userID;

@property (weak, nonatomic) IBOutlet UIImageView *headerImage;

@property (weak, nonatomic) IBOutlet UIImageView *blurHeaderImage;

@property(nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;

@property(nonatomic,strong)UIImage *passThisImage;

- (IBAction)btnClickedLearn:(id)sender;

- (IBAction)btnClickedPhoto:(id)sender;

@end
