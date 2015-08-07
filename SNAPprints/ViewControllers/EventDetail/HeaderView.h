//
//  HeaderView.h
//  SNAPprints
//
//  Created by Etay Luz on 23/05/14.
//  Copyright (c) 2014 Etay Luz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HeaderView : UICollectionReusableView

@property(strong, nonatomic) IBOutlet UICollectionReusableView *headerView;

@property(weak, nonatomic) IBOutlet UILabel *lblTitle;

@property(weak, nonatomic) IBOutlet UILabel *lblEventTime;

@property(weak, nonatomic) IBOutlet UILabel *lblPrice;

@property(weak, nonatomic) IBOutlet UILabel *lblPhotos;

@property(weak, nonatomic) IBOutlet UILabel *lblAddress;

@property(weak, nonatomic) IBOutlet UILabel *lblDescription;

@property(weak, nonatomic) IBOutlet UIButton *btnDescription;

@property(weak, nonatomic) IBOutlet UIButton *btnShowMap;

@property(weak, nonatomic) IBOutlet UILabel *lblCity;

@property(weak, nonatomic) IBOutlet UILabel *lblDistance;

@property(weak, nonatomic) IBOutlet UIImageView *mapImage;

@property(weak, nonatomic) IBOutlet UIButton *btnInvited;

@property(weak, nonatomic) IBOutlet UIView *viewbelowAddress;

@property (weak, nonatomic) IBOutlet UIImageView *headerImage;

@end
