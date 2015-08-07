//
//  MyPhotosVC.h
//  SNAPprints
//
//  Created by Etay Luz on 26/05/15.

//

#import <UIKit/UIKit.h>
#import "MFSideMenu.h"
#import "UIImageView+AFNetworking.h"
#import "PAImageView.h"
#import "Photo.h"

@interface MyPhotosVC : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
{
    PAImageView *avatarView;
}
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) IBOutlet UIView *HeaderView;

@property (strong, nonatomic) IBOutlet UIImageView *blurHeaderImage;

@property (strong, nonatomic) IBOutlet UIImageView *headerImage;
@property(weak, nonatomic) IBOutlet UIButton *btnProfile;

@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property(nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
