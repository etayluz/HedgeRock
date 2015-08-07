//
//  BannerCell.h
//  SNAPprints
//
//  Created by Etay Luz on 09/06/14.
//  Copyright (c) 2014 Etay Luz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import <RevMobAds/RevMobAds.h>

@interface BannerCell : UITableViewCell <ADBannerViewDelegate, RevMobAdsDelegate> {
}

@property (weak, nonatomic) IBOutlet ADBannerView *adBannerView;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) IBOutlet UILabel *lblErrorMsg;
@property (weak, nonatomic) IBOutlet UIImageView *bannerImage;


- (void)cellOnTableView:(UITableView *)tableView didScrollOnView:(UIView *)view;

@end
