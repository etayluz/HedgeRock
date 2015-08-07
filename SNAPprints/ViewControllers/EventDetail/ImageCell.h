//
//  ImageCell.h
//  SNAPprints
//
//  Created by Etay Luz on 18/06/14.
//  Copyright (c) 2014 Etay Luz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageCell : UICollectionViewCell
@property(weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *checkImageView;
@property(weak, nonatomic) IBOutlet UIView *bgView;
@property (nonatomic) BOOL isSelected;
@end
