//
//  UIImage+CFT.h
//  SNAPprints
//
//  Created by Etay Luz on 10/19/13.
//  Copyright (c) 2013 Etay Luz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (CFT)

// http://stackoverflow.com/questions/158914/cropping-a-uiimage/7704399#7704399
- (UIImage *)crop:(CGRect)rect;

// http://www.catamount.com/forums/viewtopic.php?f=21&t=967
- (UIImage *)imageAtRect:(CGRect)rect;
- (UIImage *)imageByScalingProportionallyToMinimumSize:(CGSize)targetSize;
- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize;
- (UIImage *)imageByScalingToSize:(CGSize)targetSize;
- (UIImage *)imageRotatedByRadians:(CGFloat)radians;
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;

- (UIImage *)imageByCorrectingOrientation;
@end
