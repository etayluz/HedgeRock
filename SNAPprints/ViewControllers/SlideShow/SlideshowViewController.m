//
//  SlideshowViewController.m
//  SNAPprints
//
//  Created by Etay Luz on 11/7/13.
//  Copyright (c) 2013 Etay Luz. All rights reserved.
//

#import "SlideshowViewController.h"
#import "Photo.h"
#import "User.h"
#import "UIImageView+AFNetworking.h"
#import "UIImage+ProportionalFill.h"
#import "UIImage+CFT.h"
#import "MBProgressHUD.h"
//#import "NSDate+TimeAgo.h"

#define ALERT_DELETE_TAG 2002
@interface SlideshowViewController ()

@end

@implementation SlideshowViewController

@synthesize scrollView = _scrollView;
@synthesize pageControl = _pageControl;
@synthesize photos = _photos;
@synthesize currentPage;
@synthesize captionContainer;

static NSDateFormatter *df = nil;

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
            andPhotos:(NSArray *)photos {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    _photos = [[NSMutableArray alloc] initWithArray:photos];

    if (nil == df) {
      df = [[NSDateFormatter alloc] init];
    }
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // [self.navigationController.navigationBar setHidden:YES];
  [self.navigationController.navigationBar
      setBarTintColor:[UIColor blackColor]];
  // Do any additional setup after loading the view from its nib.
    lblTimer = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 90, 10,90,30)];
    [lblTimer setFont:[UIFont fontWithName:kAppSupportedFontNormal size:12.0f]];
    [lblTimer setTextColor:[UIColor whiteColor]];
    [lblTimer setNumberOfLines:0];
    [lblTimer setLineBreakMode:NSLineBreakByWordWrapping];
    [self.navigationController.navigationBar addSubview:lblTimer];
    
//    UILabel *lable = [[UILabel alloc] init];
//    lable.frame = self.navigationController.navigationBar.frame;
//    lable.numberOfLines = 2;
//    lable.text = @"Slide Show";
//    [lable sizeToFit];
//    lable.textColor = [UIColor grayColor];
//    self.navigationItem.titleView = lable;

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
  [self.navigationController.navigationBar
      setBarTintColor:[UIColor blackColor]];
  [[UIApplication sharedApplication]
      setStatusBarStyle:UIStatusBarStyleLightContent
               animated:NO];
  _pageControl.numberOfPages = [_photos count];
  _pageControl.currentPage = currentPage;
    if([_photos count] > 0)
    {
        Photo *photo = [_photos objectAtIndex:currentPage];
        currentPhotoID = photo.photoID;
        currentPhoto_UserId = photo.user.userId;
        currentPhoto = photo;
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.20
                                                  target:self
                                                selector:@selector(updateTimer)
                                                userInfo:nil
                                                 repeats:YES];

}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [self.navigationController.navigationBar
      setBarTintColor:[UIColor whiteColor]];
  [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault
                                              animated:NO];
  if (isReported || isPhotoDeleted) {
    [self.delegate refreshPhotos];
  }
    btnDeleteImage = nil;
    btnCaptions = nil;
    newButton = nil;
    currentPhoto = nil;
    lblTimer.text = @"";
    lblTimer = nil;
    [lblTimer removeFromSuperview];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self displayPhotos];
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
  return ![view isKindOfClass:[UIButton class]];
}

- (void)flagPhoto:(UIButton *)sender {
  
 btnCaptions = (UIButton *)sender;
  UIAlertView *alert =
      [[UIAlertView alloc] initWithTitle:@"SNAPprints"
                                 message:@"Are you sure want to report?"
                                delegate:self
                       cancelButtonTitle:@"Yes"
                       otherButtonTitles:@"No", nil];
  [alert show];
  [alert setTag:2001];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
    shouldRecognizeSimultaneouslyWithGestureRecognizer:
        (UIGestureRecognizer *)otherGestureRecognizer {
  return YES;
}

- (void)showCaption:(UIGestureRecognizer *)sender {
  UITextView *textView = (UITextView *)sender.view;

  float offset = textView.contentSize.height - 50;

  UIImageView *imageView =
      (UIImageView *)[_scrollView viewWithTag:(_pageControl.currentPage + 1)];

  if (imageView.alpha == 1.0f) {
    [UIView animateWithDuration:0.3
                     animations:^{
                         if (offset > 0) {
                           CGRect frame = textView.frame;
                           frame.origin.y = frame.origin.y - offset;
                           textView.frame = frame;
                         }
                         imageView.alpha = 0.50;
                     }];
  } else {
    [UIView animateWithDuration:0.3
                     animations:^{
                         if (offset > 0) {
                           CGRect frame = textView.frame;
                           frame.origin.y = frame.origin.y + offset;
                           textView.frame = frame;
                         }

                         imageView.alpha = 1.0f;
                     }];
  }
}

#pragma mark UIScrollViewDelegate methods
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  CGPoint offset = scrollView.contentOffset;

  float currentPage1 = floorf(offset.x / _scrollView.bounds.size.width);

  _pageControl.currentPage = currentPage1;
    
    //get current user id and currnt photo id.
    NSInteger index = _pageControl.currentPage;
    Photo *photo = [_photos objectAtIndex:index];
    currentPhotoID = photo.photoID;
    currentPhoto_UserId = photo.user.userId;
    currentPhoto = photo;

}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - UIAlertviewDelegate

- (void)alertView:(UIAlertView *)alertView
    clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (alertView.tag == 2001)
  {

    if (buttonIndex == 0) {
      Photo *photo = [_photos objectAtIndex:_pageControl.currentPage];

      NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
      NSString *token = [defaults objectForKey:@"token"];
      NSString *user_id = [defaults objectForKey:@"user_id"];

      NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
      NSString *photo_id =
          [NSString stringWithFormat:@"%ld", (long)photo.photoID];

      [parameters setObject:photo_id forKey:@"photo_id"];
      [parameters setObject:token forKey:@"token"];
      [parameters setObject:user_id forKey:@"user_id"];

      [[SnapprintsClient sharedSnapprintsClient] postPath:@"/photos/flag"
          parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              isReported = YES;
              [btnCaptions setTitle:@"Reported" forState:UIControlStateNormal];
              btnCaptions.enabled = NO;
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              UIAlertView *alertview = [[UIAlertView alloc]
                      initWithTitle:Nil
                            message:@"There was a problem flagging this photo."
                           delegate:nil
                  cancelButtonTitle:@"OK"
                  otherButtonTitles:nil, nil];
              [alertview show];
          }];
    }
  }
  else if(alertView.tag == ALERT_DELETE_TAG)
  {
       if (buttonIndex == 0) {
           [self deletePhotos:[NSString stringWithFormat:@"%ld",(long)currentPhotoID]];
       }
  }
}


#pragma mark
#pragma mark- Button Action
-(IBAction)btnDeleteClicked:(id)sender
{
    btnDeleteImage = (UIButton*)sender;

    for (UIView *view in _scrollView.subviews) {
        if ([view tag] == 1000+[sender tag] && [view isKindOfClass:[UIButton class]])
        {
            newButton = (UIButton *)view;
            break;
        }
    }
    NSInteger loggedin_Userid = [[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"]integerValue];
    if(_isEventExpired)
    {
        UIAlertView *alertview = [[UIAlertView alloc]
                                  initWithTitle:@"SNAPprints"
                                  message:@"Event is Expired. So you can't delete photos."
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil, nil];
        [alertview show];
    }
    else if(currentPhoto_UserId != loggedin_Userid)
    {
        UIAlertView *alertview = [[UIAlertView alloc]
                                  initWithTitle:@"SNAPprints"
                                  message:@"You can't delete other user's picture."
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil, nil];
        [alertview show];
    }
    else
    {
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:@"SNAPprints"
                                   message:@"Are you sure you want to delete this picture?"
                                  delegate:self
                         cancelButtonTitle:@"Yes"
                         otherButtonTitles:@"No", nil];
        [alert show];
        [alert setTag:ALERT_DELETE_TAG];
    }
}

#pragma mark-
#pragma mark - Delete Picture Webservice

-(void)deletePhotos:(NSString*)strPhoto_id
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *user_id =
    [[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"];
    NSString *event_id = [NSString stringWithFormat:@"%ld", (long)_event.eventId];
    NSLog(@"Selected photo: %@",strPhoto_id);
    //    photos/delete_photo.json?event_id=72&user_id=97&photo_id=289,290
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:event_id forKey:@"event_id"];
    [parameters setObject:user_id forKey:@"user_id"];
    [parameters setObject:strPhoto_id forKey:@"photo_id"];
    
    [[SnapprintsClient sharedSnapprintsClient] postPath:@"photos/delete_photo.json"
                                             parameters:parameters
                                                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                    NSLog(@"Response for Delete:%@", responseObject);
                                                    if ([[responseObject objectForKey:@"status"]
                                                         isEqualToString:@"success"]) {
                                                        
                                                        dispatch_async(dispatch_get_main_queue(),
                                                                       ^{
                                                            isPhotoDeleted = YES;
                                                            [btnDeleteImage setEnabled:NO];
                                                            [btnDeleteImage setUserInteractionEnabled:NO];
                                                            [newButton setEnabled:NO];
                                                            [newButton setUserInteractionEnabled:NO];
                                                            if(currentPage == [_photos count]-1)
                                                            {
                                                                currentPage = currentPage -1;
                                                            }
                                                            [_photos removeObject:currentPhoto];
                                                            [_scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
                                                            [self displayPhotos];
                                                            
                                                            UIAlertView *alertview = [[UIAlertView alloc]
                                                                                      initWithTitle:@"SNAPprints"
                                                                                      message:@"Picture deleted successfully."
                                                                                      delegate:self
                                                                                      cancelButtonTitle:@"OK"
                                                                                      otherButtonTitles:nil, nil];
                                                                           alertview.tag =233;
                                                            [alertview show];
                                                        });
                                                        
                                                    }
                                                    else
                                                    {
                                                        UIAlertView *alertview = [[UIAlertView alloc]
                                                                                  initWithTitle:@"Error"
                                                                                  message:[responseObject                                                                  objectForKey:@"message"]
                                                                                  delegate:nil
                                                                                  cancelButtonTitle:@"OK"
                                                                                  otherButtonTitles:nil, nil];
                                                        [alertview show];
                                                    }
                                                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                }
                                                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                    NSLog(@"Error: %@", error.description);
                                                    UIAlertView *alertview = [[UIAlertView alloc]
                                                                              initWithTitle:@"Error"
                                                                              message:@"There was a problem while deleting picture."
                                                                              delegate:nil
                                                                              cancelButtonTitle:@"OK"
                                                                              otherButtonTitles:nil, nil];
                                                    [alertview show];
                                                    
                                                     [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                }];
}

-(void)displayPhotos
{
    NSInteger index = 0;
    for (Photo *photo in _photos) {
        index = [_photos indexOfObject:photo];
        
        UIImageView *imageView = [[UIImageView alloc]
                                  initWithFrame:CGRectMake(_scrollView.bounds.size.width * index, 0,
                                                           _scrollView.frame.size.width, 500)];

        __weak UIImageView *placeholderImageView = imageView;

        NSString *urlString = [NSString
                               stringWithFormat:@"%@/uploads/photos/%@", [Constants retriveServerURL],
                               photo.filename];
        
        NSURL *url = [[NSURL alloc] initWithString:urlString];
        
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];

        [_scrollView addSubview:imageView];
        
        [MBProgressHUD showHUDAddedTo:imageView animated:YES];
        
        if (photo.filename == nil && photo.photoImage) {
            UIImage *image = photo.photoImage;
            float ratio = image.size.height / image.size.width;
            float width = _scrollView.bounds.size.width;
            float height = roundf(ratio * width);
            
            image = [image imageByScalingToSize:CGSizeMake(width, height)];
            
            float y =
            roundf(_scrollView.frame.size.height / 2) - roundf(height / 2) - 50;
            
            CGRect newFrame =
            CGRectMake(placeholderImageView.frame.origin.x, y, width, height);
            
            imageView.frame = newFrame;
            if(image)
                imageView.image = image;
            imageView.tag = index + 1;
            
            // Create the username lable
            UILabel *usernameLabel = [[UILabel alloc]
                                      initWithFrame:CGRectMake(imageView.frame.origin.x + 10,
                                                               self.view.bounds.size.height - 65, 250, 20)];
            usernameLabel.textColor = [UIColor whiteColor];
            usernameLabel.backgroundColor = [UIColor clearColor];
            usernameLabel.text = photo.user.username;
            usernameLabel.font = [UIFont systemFontOfSize:12];
            [usernameLabel sizeToFit];
            [_scrollView addSubview:usernameLabel];
            
            // Creat teh timestamp label
            //            [df setDateFormat:@"MMMM d, YYYY H:mm a"];
            //      [df setDateFormat:@"MMMM d: H:mm a"];
            [df setTimeZone:[NSTimeZone localTimeZone]];
            [df setDateFormat:@"MMMM d: hh:mm a"];
            UILabel *dateLabel = [[UILabel alloc]
                                  initWithFrame:CGRectMake(imageView.frame.origin.x + 10,
                                                           self.view.bounds.size.height - 55, 250, 20)];
            dateLabel.textColor = [UIColor whiteColor];
            dateLabel.backgroundColor = [UIColor clearColor];
            dateLabel.text = [df stringFromDate:photo.created];
            dateLabel.font = [UIFont systemFontOfSize:12];
            [_scrollView addSubview:dateLabel];
            
            if (![photo.user.profileImage isEqualToString:@""]) {
                UIImageView *profileImageView = [[UIImageView alloc]
                                                 initWithFrame:CGRectMake(imageView.frame.origin.x + 10,
                                                                          self.view.bounds.size.height - 45, 40,
                                                                          40)];
                [_scrollView addSubview:profileImageView];
                
                // TODO: Update this to use a build environment variable
                NSString *profileURLString =
                [NSString stringWithFormat:@"%@uploads/profiles/%@",
                 [Constants retriveServerURL],
                 photo.user.profileImage];
                NSURLRequest *profileRequest = [[NSURLRequest alloc]
                                                initWithURL:[NSURL URLWithString:profileURLString]];
                
                __weak UIImageView *weakProfileImageView = profileImageView;
                [profileImageView setImageWithURLRequest:profileRequest
                                        placeholderImage:Nil
                                                 success:^(NSURLRequest *request, NSHTTPURLResponse *response,
                                                           UIImage *image) {
                                                     weakProfileImageView.image = image;
                                                     
                                                     // Reposition username and date labels
                                                     usernameLabel.frame =
                                                     CGRectMake(imageView.frame.origin.x + 60,
                                                                self.view.bounds.size.height - 45,
                                                                usernameLabel.bounds.size.width,
                                                                usernameLabel.bounds.size.height);
                                                     dateLabel.frame = CGRectMake(imageView.frame.origin.x + 60,
                                                                                  self.view.bounds.size.height - 35,
                                                                                  dateLabel.bounds.size.width,
                                                                                  dateLabel.bounds.size.height);
                                                 }
                                                 failure:^(NSURLRequest *request, NSHTTPURLResponse *response,
                                                           NSError *error) {
                                                     //                    NSLog(@"Profile Request Failed:
                                                     //                    %@", [error
                                                     //                    localizedDescription]);
                                                 }];
            } else {
                //                NSLog(@"User does not have anything");
            }
            
            captionContainer = [[UIView alloc]
                                initWithFrame:CGRectMake(imageView.frame.origin.x, 0, 320,
                                                         self.view.frame.size.height)];
            
            UITextView *captionLabel = [[UITextView alloc]
                                        initWithFrame:CGRectMake(0, self.view.frame.size.height - 100, 320,
                                                                 100)];
            captionLabel.textColor = [UIColor whiteColor];
            
            if (![photo.caption isKindOfClass:[NSNull class]])
                captionLabel.text = photo.caption;
            
            captionLabel.backgroundColor = [UIColor clearColor];
            captionLabel.userInteractionEnabled = YES;
            captionLabel.editable = NO;
            captionLabel.selectable = NO;
            captionLabel.font = [UIFont systemFontOfSize:14.0f];
            
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]
                                                  initWithTarget:self
                                                  action:@selector(showCaption:)];
            [captionLabel addGestureRecognizer:tapGesture];
            
            captionLabel.layer.shadowColor = [[UIColor blackColor] CGColor];
            captionLabel.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
            captionLabel.layer.shadowOpacity = 0.5f;
            captionLabel.layer.shadowRadius = 0.5f;
            [captionLabel sizeToFit];
            
            CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
            CGRect maskRect = CGRectMake(0, 0, captionContainer.bounds.size.width,
                                         captionContainer.frame.size.height - 62);
            CGPathRef path = CGPathCreateWithRect(maskRect, NULL);
            maskLayer.path = path;
            CGPathRelease(path);
            
            captionContainer.layer.mask = maskLayer;
            
            [captionContainer addSubview:captionLabel];
            
            [_scrollView addSubview:captionContainer];
        }
        
        __weak UIImageView *weakImageView = imageView;

        [weakImageView setImageWithURLRequest:request
                             placeholderImage:Nil
                                      success:^(NSURLRequest *request, NSHTTPURLResponse *response,
                                                UIImage *image) {
                                          
                                          float ratio = image.size.height / image.size.width;
                                          float width = _scrollView.bounds.size.width;
                                          float height = roundf(ratio * width);
                                          
                                          image = [image imageByScalingToSize:CGSizeMake(width, height)];
                                          
                                          float y = roundf(_scrollView.bounds.size.height / 2) -
                                          roundf(height / 2) - 50;
                                          
                                          CGRect newFrame = CGRectMake(placeholderImageView.frame.origin.x, y,
                                                                       width, height);
                                          
                                          weakImageView.frame = newFrame;
                                          NSLog(@"Image frame=%@",NSStringFromCGRect(newFrame));
                                          if(image)
                                              weakImageView.image = image;
                                          weakImageView.tag = index + 1;
                                          [MBProgressHUD hideHUDForView:imageView animated:YES];
                                          
                                          UILabel *usernameLabel = [[UILabel alloc]
                                                                    initWithFrame:CGRectMake(imageView.frame.origin.x + 8,
                                                                                             self.view.bounds.size.height - 45, 250,
                                                                                             20)];
                                          usernameLabel.textColor = [UIColor whiteColor];
                                          usernameLabel.backgroundColor = [UIColor clearColor];
                                          usernameLabel.text = photo.user.username;
                                          usernameLabel.font = [UIFont boldSystemFontOfSize:12.0f];
                                          [usernameLabel sizeToFit];
                                          [_scrollView addSubview:usernameLabel];
                                          
                                          
                                          
                                          //            [df setDateFormat:@"MMMM d, YYYY H:mm a"];
                                          //            [df setDateFormat:@"MMMM d: h:mm a"];
                                          
                                          [df setTimeZone:[NSTimeZone localTimeZone]];
                                          [df setDateFormat:@"MMMM d: hh:mm a"];
                                          
                                          
                                          UILabel *dateLabel = [[UILabel alloc]
                                                                initWithFrame:CGRectMake(imageView.frame.origin.x + 8,
                                                                                         self.view.bounds.size.height - 30, 250,
                                                                                         20)];
                                          dateLabel.textColor = [UIColor whiteColor];
                                          dateLabel.backgroundColor = [UIColor clearColor];
                                          dateLabel.text = [df stringFromDate:photo.created];
                                          
                                          dateLabel.font = [UIFont systemFontOfSize:12];
                                          [_scrollView addSubview:dateLabel];
                                          
                                          UIView *grayBar = [[UIView alloc]
                                                             initWithFrame:CGRectMake(imageView.frame.origin.x + 8,
                                                                                      self.view.bounds.size.height - 59, 304,
                                                                                      2)];
                                          [grayBar setBackgroundColor:[UIColor grayColor]];
                                          [_scrollView addSubview:grayBar];
                                          
                                          if (![photo.user.profileImage isEqualToString:@""]) {
                                              UIImageView *profileImageView = [[UIImageView alloc]
                                                                               initWithFrame:CGRectMake(imageView.frame.origin.x + 8,
                                                                                                        self.view.bounds.size.height - 45,
                                                                                                        40, 40)];
                   
                                              [_scrollView addSubview:profileImageView];
                                              
                                              // TODO: Update this to use a build environment variable
                                              // NSString *profileURLString = [NSString
                                              // stringWithFormat:@"http://192.168.1.106/uploads/profiles/%@",
                                              // photo.user.profileImage];
                                              NSString *profileURLString =
                                              [NSString stringWithFormat:@"http://%@/uploads/profiles/%@",
                                               [Constants retriveServerURL],
                                               photo.user.profileImage];
                                              
                                              NSURLRequest *profileRequest = [[NSURLRequest alloc]
                                                                              initWithURL:[NSURL URLWithString:profileURLString]];
                                              __weak UIImageView *weakEventImageView = profileImageView;

                                              [weakEventImageView setImageWithURLRequest:profileRequest
                                                                        placeholderImage:Nil
                                                                                 success:^(NSURLRequest *request, NSHTTPURLResponse *response,
                                                                                           UIImage *image) {
                                                                                     weakEventImageView.image = image;
                                                                                     
                                                                                     // Reposition username and date labels
                                                                                     usernameLabel.frame =
                                                                                     CGRectMake(imageView.frame.origin.x + 60,
                                                                                                self.view.bounds.size.height - 45,
                                                                                                usernameLabel.bounds.size.width,
                                                                                                usernameLabel.bounds.size.height);
                                                                                     dateLabel.frame =
                                                                                     CGRectMake(imageView.frame.origin.x + 60,
                                                                                                self.view.bounds.size.height - 35,
                                                                                                dateLabel.bounds.size.width,
                                                                                                dateLabel.bounds.size.height);
                                                                                 }
                                                                                 failure:^(NSURLRequest *request, NSHTTPURLResponse *response,
                                                                                           NSError *error) {
                                                                                     //                    NSLog(@"Profile Request
                                                                                     //                    Failed: %@", [error
                                                                                     //                    localizedDescription]);
                                                                                 }];
                                          } else {
                                              //                NSLog(@"User does not have anything");
                                          }
                                          
                                          captionContainer = [[UIView alloc]
                                                              initWithFrame:CGRectMake(imageView.frame.origin.x, 0, 320,
                                                                                       self.view.frame.size.height)];
                                          
                                          UITextView *captionLabel = [[UITextView alloc]
                                                                      initWithFrame:CGRectMake(8, self.view.frame.size.height - 106,
                                                                                               304, 80)];
                                          captionLabel.textColor = [UIColor whiteColor];
                                          
                                          if (![photo.caption isKindOfClass:[NSNull class]])
                                              captionLabel.text = photo.caption;
                                          
                                          captionLabel.backgroundColor = [UIColor clearColor];
                                          captionLabel.userInteractionEnabled = YES;
                                          captionLabel.editable = NO;
                                          captionLabel.selectable = NO;
                                          captionLabel.font = [UIFont systemFontOfSize:14.0f];
                                          
                                          UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]
                                                                                initWithTarget:self
                                                                                action:@selector(showCaption:)];
                                          [captionLabel addGestureRecognizer:tapGesture];
                                          
                                          captionLabel.layer.shadowColor = [[UIColor blackColor] CGColor];
                                          captionLabel.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
                                          captionLabel.layer.shadowOpacity = 0.5f;
                                          captionLabel.layer.shadowRadius = 0.5f;
                                          [captionLabel sizeToFit];
                                          
                                          CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
                                          CGRect maskRect =
                                          CGRectMake(0, 0, captionContainer.bounds.size.width,
                                                     captionContainer.frame.size.height - 62);
                                          CGPathRef path = CGPathCreateWithRect(maskRect, NULL);
                                          maskLayer.path = path;
                                          CGPathRelease(path);
                                          
                                          captionContainer.layer.mask = maskLayer;
                                          
                                          captionContainer.userInteractionEnabled = YES;
                                          [captionContainer addSubview:captionLabel];
                                          [_scrollView addSubview:captionContainer];
                                          
                                          
                                          UIButton *newButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
                                          //            newButton.frame =
                                          //                CGRectMake(captionContainer.frame.origin.x + 200,
                                          //                           usernameLabel.frame.origin.y - 10, 125, 44);
                                          newButton1.frame =
                                          CGRectMake(captionContainer.frame.origin.x + 220,
                                                     usernameLabel.frame.origin.y - 10, 100, 44);
                                          newButton1.tag = index + 1001;
                                          [newButton1 setImage:[UIImage imageNamed:@"59-flag"]
                                                      forState:UIControlStateNormal];
                                          //            [newButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 10.0f, 0, 0)];
                                          [newButton1 setTitleEdgeInsets:UIEdgeInsetsMake(0, 5.0f, 0, 0)];
                                          newButton1.titleLabel.font = [UIFont systemFontOfSize:12.0f];
                                          [newButton1 addTarget:self
                                                         action:@selector(flagPhoto:)
                                               forControlEvents:UIControlEventTouchUpInside];
                                          [newButton1 setTitle:@"Report" forState:UIControlStateNormal];
                                          //newButton.userInteractionEnabled = YES;
                                          [newButton1 setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
                                          [_scrollView addSubview:newButton1];
                                          
                                          UIButton *btnDelete = [UIButton buttonWithType:UIButtonTypeCustom];
                                          btnDelete.frame =
                                          CGRectMake(newButton1.frame.origin.x - 20,
                                                     usernameLabel.frame.origin.y - 5 , 30 , 30);
                                          btnDelete.tag = index + 1;
                                          [btnDelete setImage:[UIImage imageNamed:@"trash_white"]
                                                     forState:UIControlStateNormal];
                                          [btnDelete addTarget:self
                                                        action:@selector(btnDeleteClicked:)
                                              forControlEvents:UIControlEventTouchUpInside];
//                                          btnDelete.userInteractionEnabled = YES;
                                          if(_isEventExpired)
                                          {
                                              [btnDelete setUserInteractionEnabled:NO];
                                              [btnDelete setEnabled:NO];
                                          }
                                          else
                                          {
                                              [btnDelete setUserInteractionEnabled:YES];
                                              [btnDelete setEnabled:YES];
                                          }
                                          
                                          [_scrollView addSubview:btnDelete];
                                      }
                                      failure:^(NSURLRequest *request, NSHTTPURLResponse *response,
                                                NSError *error) {
                                          [MBProgressHUD hideHUDForView:imageView animated:YES];
                                      }];
        imageView = nil;
        weakImageView = nil;
    }
    
    index++;
    _scrollView.contentSize = CGSizeMake(_scrollView.bounds.size.width * index,
                                         _scrollView.bounds.size.height);
    _scrollView.contentOffset =
    CGPointMake(_scrollView.bounds.size.width * currentPage, 0);
    if(currentPage == [_photos count]-1)
    {
        [_scrollView scrollRectToVisible:CGRectMake(_scrollView.contentOffset.x, 0,_scrollView.frame.size.width, _scrollView.frame.size.height) animated:YES];
    }
}

#pragma mark- Update timer
/*
 Function: updateTimer
 Decription: For calculating remaining time to expire event.
 Return: Void
 */
- (void)updateTimer {
    
//    [lblTimer setFont:[UIFont fontWithName:kAppSupportedFontNormal size:13]];
    NSCalendar *currCalendar =
    [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit |
    NSSecondCalendarUnit ;
    
    NSDateComponents *conversionInfo =
    [currCalendar components:unitFlags
                    fromDate:[NSDate date]
                      toDate:_event.eventEndDateTime
                     options:0];
    
    NSInteger hours = [conversionInfo hour];
    NSInteger minutes = [conversionInfo minute];
    NSInteger seconds = [conversionInfo second];
    
//    NSString *beginningOfText = @"Time Remaining:";
    
    NSMutableString *timeString =
    [NSMutableString stringWithString:@""];

    if (seconds <= 0 && minutes <= 0 && hours <= 0 ) {
        _isEventExpired = YES;
        [lblTimer setText:@"Picture can no longer be deleted."];

    }
    else {
        [timeString appendFormat:@" %02d:%02d:%02d", (int)hours,(int)minutes
         ,(int)seconds];
        NSMutableAttributedString *attString =
        [[NSMutableAttributedString alloc] initWithString:timeString];
        
        [attString addAttribute:NSForegroundColorAttributeName
                          value:[UIColor whiteColor]
                          range:NSMakeRange(0,[timeString length])];
        
        [lblTimer setAttributedText:attString];
        
    }
}

@end
