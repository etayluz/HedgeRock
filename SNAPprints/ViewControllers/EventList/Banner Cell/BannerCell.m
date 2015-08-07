//
//  BannerCell.m
//  SNAPprints
//
//  Created by Etay Luz on 09/06/14.
//  Copyright (c) 2014 Etay Luz. All rights reserved.
//

#import "BannerCell.h"

@implementation BannerCell

- (void)awakeFromNib
{
    // Initialization code
  
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)cellOnTableView:(UITableView *)tableView didScrollOnView:(UIView *)view{

}

#pragma mark- ADBannerView delegates

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    return YES;
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    [UIView beginAnimations:@"AnimateBanner" context:nil];
    [UIView setAnimationDelay:1.0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [_lblErrorMsg setHidden:YES];
    [_activityIndicator stopAnimating];
    [UIView commitAnimations];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"Error: %@",[error localizedDescription]);

    [_lblErrorMsg setHidden:NO];
     [_activityIndicator stopAnimating];
}
@end
