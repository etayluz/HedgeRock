//
//  UITextField+Placeholder.m
//  FlashRe
//
//  Created by Etay Luz on 27/01/14.
//  Copyright (c) 2014 Etay Luz. All rights reserved.
//

#import "UITextField+Placeholder.h"

@implementation UITextField (Placeholder)

- (void)setPlaceholder:(NSString *)placeholder {
  self.attributedPlaceholder = [[NSAttributedString alloc]
      initWithString:placeholder
          attributes:@{
                       NSFontAttributeName :
                           [UIFont systemFontOfSize:[self.font pointSize]],
                       NSForegroundColorAttributeName : [UIColor lightGrayColor]
                     }];
}
@end
