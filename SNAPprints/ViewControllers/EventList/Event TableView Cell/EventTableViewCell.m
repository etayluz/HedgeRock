//
//  EventTableViewCell.m
//  SNAPprints
//
//  Created by Etay Luz on 9/17/13.
//  Copyright (c) 2013 Etay Luz. All rights reserved.
//

#import "EventTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

#define CELL_LEFT_PADDING 10
#define CELL_TOP_PADDING 10
#define TEXT_LEFT_PADDING 72

#define THUMBNAIL_WIDTH 50
#define THUMBNAIL_HEIGHT 50

@implementation EventTableViewCell

@synthesize eventTitleLabel, distanceLabel, dateLabel, photosLabel,
    event = _event;
@synthesize thumbnailImageView, priceLabel, thumbnailURLString, imgViewInviteBG;

static NSDateFormatter *df;

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
           andEvent:(Event *)event {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    // Initialization code
    _event = event;

    df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"EEE ddd H:mmA"];
  }
  return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];

  //    NSLog(@"Set Selected");

  // Configure the view for the selected state
}
- (void)cellOnTableView:(UITableView *)tableView
        didScrollOnView:(UIView *)view {
  //    CGRect rectInSuperview = [tableView convertRect:self.frame toView:view];
  //
  //    float distanceFromCenter = CGRectGetHeight(view.frame)/2 -
  //    CGRectGetMinY(rectInSuperview);
  //    float difference = CGRectGetHeight(self.thumbnailImageView.frame) -
  //    CGRectGetHeight(self.frame);
  //    float move = (distanceFromCenter / CGRectGetHeight(view.frame)) *
  //    difference;
  //
  //    CGRect imageRect = self.thumbnailImageView.frame;
  //    imageRect.origin.y = -(difference/2)+move;
  //    self.thumbnailImageView.frame = imageRect;
}

@end
