//
//  AddPhotoDetailsViewController.m
//  SNAPprints
//
//  Created by Etay Luz on 11/10/13.
//  Copyright (c) 2013 Etay Luz. All rights reserved.
//

#import "AddPhotoDetailsViewController.h"
#import "Photo.h"
#import "User.h"
#import "TSMessage.h"
#import "UIImage+CreateThumbnail.h"
#import "ConstantFlags.h"

@interface AddPhotoDetailsViewController ()

@end

@implementation AddPhotoDetailsViewController

@synthesize thumbnailImageView, addPhotoButton, textView = _textView;
@synthesize addCaptionLabel, photo, delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

#pragma mark - LifeCycle

- (void)viewDidLoad {
  [super viewDidLoad];

  _thumbnailImg = [UIImage squareImageWithImage:_originalImg
                                   scaledToSize:CGSizeMake(200, 200)];
  thumbnailImageView.image = _thumbnailImg;
  // Do any additional setup after loading the view from its nib.
  CALayer *btnLayer = [addPhotoButton layer];
  [btnLayer setCornerRadius:5.f];
  [btnLayer setMasksToBounds:YES];
    
    _lblDisclaimer.text = DISCLIAMER_TEXT;
    _lblDisclaimer.font =[UIFont fontWithName:kAppSupportedFontNormal size:14.f];
    _lblDisclaimer.textColor = [UIColor darkGrayColor];
    
    UILabel *lable = [[UILabel alloc] init];
    lable.frame = self.navigationController.navigationBar.frame;
    lable.numberOfLines = 2;
    lable.text = @"Add Photo";
    [lable sizeToFit];
    lable.textColor = [UIColor grayColor];
    lable.font = [UIFont fontWithName:kAppSupportedFontBold size:16.0f];
    self.navigationItem.titleView = lable;
    
    [self.addCaptionLabel setFont:[UIFont fontWithName:kAppSupportedFontNormal size:14.0f]];
    self.addPhotoButton.titleLabel.font = [UIFont fontWithName:kAppSupportedFontLight size:18.0f];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - Action Events

- (IBAction)tappedAddButton:(UIButton *)sender {
  [self.view endEditing:YES];
  sender.enabled = NO;

  NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];

  NSData *thumbnailData = UIImageJPEGRepresentation(_thumbnailImg, 0.6);
  NSData *imageData = UIImageJPEGRepresentation(_originalImg, 0.6);

  SnapprintsClient *client = [SnapprintsClient sharedSnapprintsClient];

  NSString *eventID = [NSString stringWithFormat:@"%ld", (long)_event.eventId];
  [parameters setObject:eventID forKey:@"Photo[event_id]"];

  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSString *token = [defaults objectForKey:@"token"];
  NSString *user_id = [defaults objectForKey:@"user_id"];

  if (token) {
    [parameters setObject:token forKey:@"User[token]"];
  }

  if (user_id) {
    [parameters setObject:user_id forKey:@"User[user_id]"];
  }
  [parameters setObject:_textView.text forKey:@"Photo[caption]"];
  __block MBProgressHUD *hud =
      [MBProgressHUD showHUDAddedTo:self.view animated:YES];
  hud.mode = MBProgressHUDModeAnnularDeterminate;
  hud.labelText = @"Uploading...";
  NSMutableURLRequest *request = [client
      multipartFormRequestWithMethod:@"POST"
                                path:@"/photos/upload_photo.json"
                          parameters:parameters
           constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
               [formData appendPartWithFileData:imageData
                                           name:@"Event[photo]"
                                       fileName:@"temp.png"
                                       mimeType:@"image/png"];
               [formData appendPartWithFileData:thumbnailData
                                           name:@"Event[thumbnail]"
                                       fileName:@"temp-thumbnail.png"
                                       mimeType:@"image/png"];
           }];

  AFHTTPRequestOperation *operation =
      [[AFHTTPRequestOperation alloc] initWithRequest:request];
  [operation setUploadProgressBlock:^(NSUInteger bytesWritten,
                                      long long totalBytesWritten,
                                      long long totalBytesExpectedToWrite) {
      float ratio = (float)totalBytesWritten / totalBytesExpectedToWrite;
      [hud setProgress:ratio];
  }];

  [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation,
                                             id responseObject) {
      if ([self.delegate respondsToSelector:@selector(didAddPhoto:)]) {
        NSError *error;
        NSDictionary *dict =
            [NSJSONSerialization JSONObjectWithData:responseObject
                                            options:0
                                              error:&error];

        NSDictionary *photoDict =
            [[dict objectForKey:@"photos"] objectForKey:@"Photo"];
        photo.filename = [photoDict objectForKey:@"filename"];
        photo.thumbnail_filename = [photoDict objectForKey:@"thumbnail"];

        User *user = [[User alloc] init];
        user.userId =
            [[[photoDict objectForKey:@"User"] objectForKey:@"id"] intValue];
        user.username =
            [[photoDict objectForKey:@"User"] objectForKey:@"username"];

        if ([[[photoDict objectForKey:@"User"] objectForKey:@"profile_image"]
                isKindOfClass:[NSNull class]]) {
          user.profileImage = @"";
        } else {
          user.profileImage =
              [[photoDict objectForKey:@"User"] objectForKey:@"profile_image"];
        }
        photo.user = user;

        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"YYYY-MM-dd hh:mm a"];
        [df setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        photo.created = [df dateFromString:[[photoDict objectForKey:@"Photo"]
                                               objectForKey:@"created"]];
        photo.caption = _textView.text;

        [self performSelectorOnMainThread:@selector(hideHUD)
                               withObject:nil
                            waitUntilDone:YES];
        [TSMessage setDefaultViewController:self.navigationController];
        [TSMessage
            showNotificationWithTitle:@"Photo added successfully to the event."
                             subtitle:@""
                                 type:TSMessageNotificationTypeSuccess];
        [self.delegate didAddPhoto:photo];
      }
      [self.navigationController popViewControllerAnimated:YES];
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
      [hud hide:YES];
      [hud removeFromSuperview];
      UIAlertView *alert = [[UIAlertView alloc]
              initWithTitle:@"SNAPprints"
                    message:@"Unable to upload photo. Please try again."
                   delegate:nil
          cancelButtonTitle:@"OK"
          otherButtonTitles:nil, nil];
      [alert show];
      [sender setEnabled:YES];
  }];

  [operation start];
}

#pragma mark - UITextViewDelegate methods
- (void)textViewDidBeginEditing:(UITextView *)textView {
  addCaptionLabel.hidden = YES;
}

#pragma mark - Custom Methods

- (void)hideHUD {
  [MBProgressHUD hideHUDForView:self.view animated:YES];
}

@end
