//
//  MyPhotosVC.m
//  SNAPprints
//
//  Created by Etay Luz on 26/05/15.

//

#import "MyPhotosVC.h"
#import "HeaderView.h"
#import "ImageCell.h"
#import "User.h"
#import "UIImage+ProportionalFill.h"
#import "MBProgressHUD.h"

static NSString *kCollectionViewHeaderIdentifier = @"Header";
static NSString *kCollectionViewIdentifier = @"Photocell";

@interface MyPhotosVC (){
    MBProgressHUD *hud;
    NSMutableArray *arrPhotos;
}
@end

@implementation MyPhotosVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.tintColor =
    UIColorFromRGB(COLOR_LIGHT_BLUE);
    [self.navigationController.navigationBar
     setBarTintColor:[UIColor whiteColor]];
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    // Set up left bar item
    UIImage *hamburgerImage = [UIImage imageNamed:@"hamburger-icon"];
    UIButton *sideButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sideButton addTarget:self
                   action:@selector(sideMenu:)
         forControlEvents:UIControlEventTouchUpInside];
    sideButton.bounds =
    CGRectMake(0, 0, hamburgerImage.size.width, hamburgerImage.size.height);
    [sideButton setImage:hamburgerImage forState:UIControlStateNormal];
    UIBarButtonItem *hamburgerButton =
    [[UIBarButtonItem alloc] initWithCustomView:sideButton];
    self.navigationItem.leftBarButtonItem = hamburgerButton;
    self.navigationController.navigationBarHidden = NO;
    
    //          title = @"Events Near Me";
    UILabel *lable = [[UILabel alloc] init];
    lable.frame = self.navigationController.navigationBar.frame;
    lable.numberOfLines = 2;
    lable.text = @"My Photos";
    [lable sizeToFit];
    lable.textColor = [UIColor grayColor];
    lable.font = [UIFont fontWithName:kAppSupportedFontBold size:16.0f];
    self.navigationItem.titleView = lable;
    
    arrPhotos = [[NSMutableArray alloc] init];
    // Do any additional setup after loading the view from its nib.
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading...";
    [self getHeaderView];
    
    [self getPhotos];
    
    [self.collectionView
     registerNib:[UINib nibWithNibName:@"ImageCell" bundle:nil]
     forCellWithReuseIdentifier:kCollectionViewIdentifier];
    
    UICollectionViewFlowLayout *layout =
    [[UICollectionViewFlowLayout alloc] init];
    [_collectionView setCollectionViewLayout:layout];
    
    UINib *headerNib = [UINib nibWithNibName:NSStringFromClass([HeaderView class])
                                      bundle:[NSBundle mainBundle]];
    [_collectionView registerNib:headerNib
      forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
             withReuseIdentifier:kCollectionViewHeaderIdentifier];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom Methods

- (void)sideMenu:(id)sender {
    NSLog(@"%@", self.menuContainerViewController);
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{}];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

/*
 Function: getHeaderView
 Decription: Applies font to label in header view of UICollectionView and
 calculates frames for subviews in headerview.
 Return: Void
 */
- (void)getHeaderView {
    [_lblTitle setFont:[UIFont fontWithName:kAppSupportedFontBold size:21]];
    [_lblTitle setTextColor:[UIColor whiteColor]];
    [[NSUserDefaults standardUserDefaults] objectForKey:@"userDetail"];
    [_lblTitle setFont:[UIFont fontWithName:kAppSupportedFontNormal size:24]];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *strUserName =
    [NSString stringWithFormat:@"%@", [defaults objectForKey:@"username"]];
    _lblTitle.text = strUserName;
    NSString *profileImage =
    [[NSUserDefaults standardUserDefaults] objectForKey:@"profile_image"];
    NSString *strURL;
    if (profileImage && ![profileImage isEqualToString:@""]) {
        strURL =
        [NSString stringWithFormat:@"%@uploads/profiles/%@",
         [Constants retriveServerURL], profileImage];
    } else {
        
        NSString *facebook_id =
        [[NSUserDefaults standardUserDefaults] objectForKey:@"facebook_id"];
        strURL = [NSString
                  stringWithFormat:
                  @"https://graph.facebook.com/%@/picture?width=320&height=320",
                  facebook_id];
    }
    NSURLRequest *req =
    [NSURLRequest requestWithURL:[NSURL URLWithString:strURL]];
    BOOL valid = [NSURLConnection canHandleRequest:req];
    if (valid) {
        [_activityIndicator startAnimating];
        AFImageRequestOperation *operation = [AFImageRequestOperation
                                              imageRequestOperationWithRequest:req
                                              imageProcessingBlock:nil
                                              success:^(NSURLRequest *request, NSHTTPURLResponse *response,
                                                        UIImage *image) {
                                                  dispatch_async(dispatch_get_global_queue(
                                                                                           DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                                                                 ^{
                                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                                         if (image) {
                                                                             [_activityIndicator stopAnimating];
                                                                             [self.headerImage setImageWithURL:[NSURL URLWithString:strURL]];
                                                                             avatarView.cacheEnabled = YES;
                                                                         }
                                                                     });
                                                                 });
                                              }
                                              failure:^(NSURLRequest *request, NSHTTPURLResponse *response,
                                                        NSError *error) {
                                                  [self.headerImage
                                                   setImage:[UIImage imageNamed:@"default-human-img"]];
                                              }];
        [operation start];
    }
    
    self.headerImage.clipsToBounds = YES;
    self.headerImage.layer.cornerRadius = self.headerImage.frame.size.height/2.0f;
    self.headerImage.layer.borderWidth = 2.0f;
    self.headerImage.layer.borderColor = [UIColor whiteColor].CGColor;
    [_headerImage setHidden:NO];
    [self.view addSubview:_HeaderView];
}

#pragma mark - API Call
/*
 Function: getPhotos
 Decription: Get all uploaded photos for particular event.
 Return: void
 */

- (void)getPhotos {//http://api.snapprintshere.com/users/getPhotos.json?user_id=171
    NSString *user_id = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"];
    NSString *path = [NSString stringWithFormat:@"/users/getPhotos.json?user_id=%@",user_id];
    [[SnapprintsClient sharedSnapprintsClient] postPath:path
                                            parameters:nil
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   NSLog(@"My Photos responseObject = %@", responseObject);
                                                   NSDictionary *eventDict = [responseObject objectForKey:@"result"];
                                                   NSArray *photos = [eventDict objectForKey:@"photos"];
                                                   for (int i = 0; i < [photos count]; i++) {
                                                        NSMutableDictionary *eventDict1 =
                                                       [photos objectAtIndex:i]; //[[NSMutableDictionary alloc] init];
                                                       NSDictionary *dict = [eventDict1 objectForKey:@"Photo"];
                                                       Photo *photo = [[Photo alloc] init];
                                                       photo.filename = [dict objectForKey:@"filename"];
                                                       photo.thumbnail_filename = [dict objectForKey:@"thumbnail"];
                                                       photo.photoID = [[dict objectForKey:@"id"] integerValue];
                                                       photo.published = [dict objectForKey:@"published"];
                                                       photo.is_deleted = [dict objectForKey:@"is_deleted"];
                                                       photo.user = [[User alloc] init];
                                                       
                                                       if (![[dict objectForKey:@"user_id"]
                                                             isKindOfClass:[NSNull class]]) {
                                                           photo.user.userId = [[dict objectForKey:@"user_id"] integerValue];
                                                       }
                                                       
                                                       if (photo.user.userId == [user_id integerValue]) {
                                                           if (![photo.filename isEqualToString:@""] &&
                                                               ![photo.thumbnail_filename isEqualToString:@""])
                                                           {
                                                               if([photo.is_deleted isEqualToString:@"0"])
                                                                   [arrPhotos addObject:photo];
                                                           }
                                                           
                                                       }
                                                   }
//                                                   NSLog(@"arrPhotos = %@",arrPhotos);
                                                   [_collectionView reloadData];
                                                   [hud hide:YES];
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   NSLog(@"Failed: %@", [error localizedDescription]);
                                                   [hud hide:YES];
                                                   [hud removeFromSuperview];
                                               }];
}

#pragma mark - UICollectionViewDataSource methods
- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return [arrPhotos count];
}

- (NSInteger)numberOfSectionsInCollectionView:
(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ImageCell *cell = [collectionView
                       dequeueReusableCellWithReuseIdentifier:kCollectionViewIdentifier
                       forIndexPath:indexPath];
    
//    [cell.imageView.layer setCornerRadius:10.0f];
//    [cell.imageView.layer setBorderColor:[[UIColor grayColor] CGColor]];
//    [cell.imageView.layer setBorderWidth:0.5f];
    
//    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc]
//                                         initWithFrame:CGRectMake(cell.imageView.frame.size.width / 2 - 10,
//                                                                  cell.imageView.frame.size.height / 2 - 10, 20, 20)];
//    [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
//    [cell.imageView addSubview:activity];
//    [activity startAnimating];
    Photo *photo = [arrPhotos objectAtIndex:indexPath.row];
    if ([photo.thumbnail_filename isEqualToString:@""] ||
        [photo.thumbnail_filename isKindOfClass:[NSNull class]] ||
        photo.thumbnail_filename == nil) {
        if (photo.thumbnailImage) {
            
            [cell.imageView setImage:photo.thumbnailImage];
        }
        //[activity stopAnimating];
    } else {
        //cell.imageView.image = nil;
        NSURL *thumbnailURL = [NSURL
                               URLWithString:[NSString stringWithFormat:@"%@/uploads/photos/%@",
                                              [Constants retriveServerURL],
                                              photo.thumbnail_filename]];
        [cell.imageView setImageWithURL:thumbnailURL usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
       /* NSURLRequest *req = [NSURLRequest requestWithURL:thumbnailURL];
        BOOL valid = [NSURLConnection canHandleRequest:req];
        if (valid) {
            AFImageRequestOperation *operation = [AFImageRequestOperation
                                                  imageRequestOperationWithRequest:req
                                                  imageProcessingBlock:nil
                                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response,
                                                            UIImage *image) {
                                                      
                                                      dispatch_async(dispatch_get_global_queue(
                                                                                               DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                                                                     ^{
                                                                         
                                                                         UIImage *scaledImgH =
                                                                         [image imageToFitSize:cell.imageView.frame.size
                                                                                        method:MGImageResizeScale];
                                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                                             if (scaledImgH) {
                                                                                 [activity stopAnimating];
                                                                                 UICollectionViewCell *updateCell =
                                                                                 [_collectionView cellForItemAtIndexPath:indexPath];
                                                                                 if (updateCell) {
                                                                                     [cell.imageView setImage:scaledImgH];
                                                                                 }
                                                                             }
                                                                         });
                                                                     });
                                                  }
                                                  failure:^(NSURLRequest *request, NSHTTPURLResponse *response,
                                                            NSError *error) { [activity stopAnimating]; }];
            [operation start];
        }*/
    }
    cell.isSelected = NO;
    [cell.checkImageView setImage:nil];
    return cell;
}

#pragma mark - UICollectionViewDelegate methods
- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([arrPhotos count] > 0) {
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(2, 2, 2, 2);
}

#pragma mark - UICollectionViewFlowLayout methods

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(104.f, 104.f);
}

//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
//           viewForSupplementaryElementOfKind:(NSString *)kind
//                                 atIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.section == 0) {
//        HeaderView *headerView;
//        if (kind == UICollectionElementKindSectionHeader) {
//            headerView = [collectionView
//                          dequeueReusableSupplementaryViewOfKind:
//                          UICollectionElementKindSectionHeader
//                          withReuseIdentifier:kCollectionViewHeaderIdentifier
//                          forIndexPath:indexPath];
//            [headerView addSubview:_HeaderView];
//        }
//        return headerView;
//        
//    } else
//    return nil;
//}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:
(UICollectionViewLayout *)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section {
//    if (section == 0)
//        return CGSizeMake(_HeaderView.frame.size.width,
//                          _HeaderView.frame.size.height);
//    else
        return CGSizeMake(0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionView *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 2;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 2;
}


@end
