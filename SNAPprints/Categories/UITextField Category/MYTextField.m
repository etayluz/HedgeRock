//
//  MYTextField.m
//  FlashRe
//
//  Created by Etay Luz on 11/03/14.
//  Copyright (c) 2014 Etay Luz. All rights reserved.
//

#import "MYTextField.h"

@implementation MYTextField

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    // Initialization code
  }
  return self;
}

- (CGRect)textRectForBounds:(CGRect)bounds {
  int margin = 10;
  CGRect inset = CGRectMake(bounds.origin.x + margin, bounds.origin.y,
                            bounds.size.width - margin, bounds.size.height);
  return inset;
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
  int margin = 10;
  CGRect inset = CGRectMake(bounds.origin.x + margin, bounds.origin.y,
                            bounds.size.width - margin, bounds.size.height);
  return inset;
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
