//
//  UIImage+CreateThumbnail.m
//  SNAPprints
//
//  Created by Etay Luz on 05/08/14.
//  Copyright (c) 2014 Etay Luz. All rights reserved.
//

#import "UIImage+CreateThumbnail.h"

@implementation UIImage (CreateThumbnail)

+ (UIImage *)squareImageWithImage:(UIImage *)image
                     scaledToSize:(CGSize)newSize {
  double ratio;
  double delta;
  CGPoint offset;

  // make a new square size, that is the resized imaged width
  CGSize sz = CGSizeMake(newSize.width, newSize.width);

  // figure out if the picture is landscape or portrait, then
  // calculate scale factor and offset
  if (image.size.width > image.size.height) {
    ratio = newSize.width / image.size.width;
    delta = (ratio * image.size.width - ratio * image.size.height);
    offset = CGPointMake(delta / 2, 0);
  } else {
    ratio = newSize.width / image.size.height;
    delta = (ratio * image.size.height - ratio * image.size.width);
    offset = CGPointMake(0, delta / 2);
  }

  // make the final clipping rect based on the calculated values
  CGRect clipRect =
      CGRectMake(-offset.x, -offset.y, (ratio * image.size.width) + delta,
                 (ratio * image.size.height) + delta);

  // start a new context, with scale factor 0.0 so retina displays get
  // high quality image
  if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
    UIGraphicsBeginImageContextWithOptions(sz, YES, 0.0);
  } else {
    UIGraphicsBeginImageContext(sz);
  }
  UIRectClip(clipRect);
  [image drawInRect:clipRect];
  UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();

  return newImage;
}
@end
