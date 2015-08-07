//
//  ProfileViewController.h
//  SNAPprints
//
//  Created by Etay Luz on 3/23/14.
//  Copyright (c) 2014 Etay Luz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
@interface ProfileViewController
    : UIViewController <UITableViewDataSource, UITableViewDelegate,
                        UITextFieldDelegate, UIActionSheetDelegate,
                        UIImagePickerControllerDelegate, UIAlertViewDelegate> {

  NSUserDefaults *default1;
  BOOL isImagePicked;
}
@property(nonatomic, retain) ALAssetsLibrary *library;
@property(nonatomic, retain) IBOutlet UITableView *tableView;
@property(nonatomic, retain) IBOutlet UIView *headerView;
@property(nonatomic, retain) IBOutlet UIView *footerView;
@property(nonatomic, retain) IBOutlet UILabel *lblUploadProfile;
@property(nonatomic, retain) IBOutlet UILabel *lblMyProfile;
@property(nonatomic, retain) IBOutlet UIImageView *imgProfile;
@property(nonatomic, retain) IBOutlet UIButton *btnSetImage;
@property(nonatomic, retain) IBOutlet UIButton *btnSaveProfile;
@property(nonatomic, retain)
    IBOutlet UIActivityIndicatorView *activityIndicator;
@property(nonatomic, strong) MBProgressHUD *hud;
- (IBAction)btnTakePhoto:(id)sender;
- (IBAction)btnSaveProfile:(id)sender;
- (IBAction)btnSavePhotoToCameraRoll:(id)sender;

@end
