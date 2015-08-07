//
//  PTSansLabel.m
//  SNAPprints
//
//  Created by Etay Luz on 10/19/13.
//  Copyright (c) 2013 Etay Luz. All rights reserved.
//

#import "PTSansLabel.h"

@implementation PTSansLabel

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    // Initialization code
  }
  return self;
}

- (void)awakeFromNib {
  [super awakeFromNib];
  self.font = [UIFont fontWithName:@"PTSans-Bold" size:self.font.pointSize];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
