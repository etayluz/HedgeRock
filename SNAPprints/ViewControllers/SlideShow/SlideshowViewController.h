//
//  SlideshowViewController.h
//  SNAPprints
//
//  Created by Etay Luz on 11/7/13.
//  Copyright (c) 2013 Etay Luz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSMessage.h"
#import "Event.h"
#import "Photo.h"

@protocol SlideshowVCDelegate <NSObject>

- (void)refreshPhotos;

@end

@interface SlideshowViewController
    : UIViewController <UIScrollViewDelegate, UIGestureRecognizerDelegate,
                        UIAlertViewDelegate> {
  __block UIButton *newButton, *btnDeleteImage;
  UIButton *btnCaptions;
  BOOL isReported, isPhotoDeleted;
  NSInteger currentPhotoID, currentPhoto_UserId;
  Photo *currentPhoto;
  UILabel *lblTimer;
}

@property(nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property(nonatomic, retain) IBOutlet UIPageControl *pageControl;
@property(nonatomic, retain) NSMutableArray *photos;
@property(nonatomic, retain) UIView *captionContainer;
@property NSInteger currentPage;
@property(weak, nonatomic) id<SlideshowVCDelegate> delegate;
@property (assign, nonatomic) BOOL isEventExpired;
@property (strong, nonatomic) Event *event;
@property(nonatomic, retain) NSTimer *timer;

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
            andPhotos:(NSArray *)photos;

@end
