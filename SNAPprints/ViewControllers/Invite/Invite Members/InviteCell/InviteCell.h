//
//  InviteCell.h
//  SNAPprints
//
//  Created by Etay Luz on 27/06/14.
//  Copyright (c) 2014 Etay Luz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InviteCell : UITableViewCell

@property(weak, nonatomic) IBOutlet UIImageView *contactImage;

@property(weak, nonatomic) IBOutlet UILabel *lblName;

@property(weak, nonatomic) IBOutlet UILabel *lblEmail;

@property(weak, nonatomic) IBOutlet UIButton *btnSelect;

@end
