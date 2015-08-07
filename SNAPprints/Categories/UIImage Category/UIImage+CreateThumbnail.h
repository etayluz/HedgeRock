//
//  UIImage+CreateThumbnail.h
//  SNAPprints
//
//  Created by Etay Luz on 05/08/14.
//  Copyright (c) 2014 Etay Luz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (CreateThumbnail)

+ (UIImage *)squareImageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
@end
