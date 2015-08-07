//
//  EventTableViewCell.h
//  SNAPprints
//
//  Created by Etay Luz on 9/17/13.
//  Copyright (c) 2013 Etay Luz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"

@interface EventTableViewCell : UITableViewCell {
  // UILabel *eventTitleLabel;
}
@property(weak, nonatomic) IBOutlet UIActivityIndicatorView *actvityIndicator;
@property(nonatomic, weak) IBOutlet UILabel *eventTitleLabel;
@property(nonatomic, weak) IBOutlet UILabel *distanceLabel;
@property(nonatomic, weak) IBOutlet UILabel *dateLabel;
@property(nonatomic, weak) IBOutlet UILabel *photosLabel;
@property(nonatomic, weak) IBOutlet UILabel *priceLabel;
@property(nonatomic, weak) IBOutlet UILabel *cityLabel;
@property(nonatomic, weak) IBOutlet UIImageView *thumbnailImageView;
@property(nonatomic, weak) IBOutlet UIView *viewImage;
@property(nonatomic, weak) IBOutlet UIButton *btnPrivate;
@property(nonatomic, retain) NSString *thumbnailURLString;
@property(nonatomic, retain) Event *event;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UIImageView *imgViewInviteBG;

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
           andEvent:(Event *)event;
- (void)cellOnTableView:(UITableView *)tableView didScrollOnView:(UIView *)view;
@end
