//
//  EventListViewController.m
//  SNAPprints
//
//  Created by Etay Luz on 9/16/13.
//  Copyright (c) 2013 Etay Luz. All rights reserved.
//

#import "EventListViewController.h"
#import "Event.h"
#import "Photo.h"
#import "UIImageView+AFNetworking.h"
#import <QuartzCore/QuartzCore.h>
#import "LocationManagerSingleton.h"
#import "Region.h"
#import "NSString+CFT.h"
#import "UIImage+ProportionalFill.h"
#import "MBProgressHUD.h"
#import "EventDetailVC.h"
#import "BannerCell.h"
#import "TOWebViewController.h"
#import "ConstantFlags.h"
#import "EventsMapViewController.h"

// Table cell constants
#define CELL_LEFT_PADDING 10
#define CELL_TOP_PADDING 10
#define TEXT_LEFT_PADDING 72

#define THUMBNAIL_WIDTH 50
#define THUMBNAIL_HEIGHT 50

// define event table cell views
#define EVENT_CELL_EVENT_TITLE_LABEL_TAG 500
#define EVENT_CELL_DISTANCE_LABEL_TAG 501
#define EVENT_CELL_DATE_LABEL_TAG 502
#define EVENT_CELL_PHOTOS_LABEL_TAG 503
#define EVENT_CELL_THUMBNAIL_TAG 504
#define EVENT_CELL_PRICE_TAG 505
#define TABLE_HEADER_HEIGHT 40
#define ACCEPTABLE_CHAR                                                        \
@",1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz "

@interface EventListViewController () <EventDetailsDelegate> {
    MBProgressHUD *hud;
    //  BOOL isSearched;
    BOOL isAdvanceSearch;
    BOOL isMapShowing;
    NSTimer *updateImageTimer;
    NSInteger loggedUser_id;
    UIToolbar *numberToolbar;
    UIButton *resetButton;
    UIButton *btnMapView;
    EventsMapViewController *mapVC;
    UIButton *btnAdvSearch;
    CGRect tableViewRect;
}

@property(weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation EventListViewController

@synthesize tableView = _tableView;
@synthesize tableData = _tableData;
//@synthesize searchBar = _searchBar;
@synthesize userID = _userID;
@synthesize _refreshHeaderView;
@synthesize resultTableData = _resultTableData;
@synthesize operation = _operation;

#pragma mark - View LifeCycle

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [RevMobAds startSessionWithAppID:@"556829b0b39950d10a3ced9d" andDelegate:self];
    
    isAdvanceSearch = NO;
    isMapShowing = NO;
    mapVC = [[EventsMapViewController alloc] initWithNibName:@"EventsMapViewController" bundle:[NSBundle mainBundle]];
    location =
    [LocationManagerSingleton sharedSingleton].locationManager.location;
    [self.tableView registerClass:[BannerCell class]
           forCellReuseIdentifier:@"BannerCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"BannerCell" bundle:nil]
         forCellReuseIdentifier:@"BannerCell"];
    //[self loadGoogleAds];
    if ([LocationManagerSingleton locationServicesEnabled]) {
        NSLog(@"Allowed Location");
    } else {
        
        [TSMessage setDefaultViewController:self.navigationController];
        [TSMessage
         showNotificationWithTitle:@"Location Services Denied"
         subtitle:@"SNAPprints requires access to your "
         @"device's location services.\n\nPlease "
         @"enable location services access for this "
         @"app in Settings / Privacy / Location " @"Services."
         type:TSMessageNotificationTypeWarning];
        
    }
    
    self.navigationController.navigationBar.tintColor =
    UIColorFromRGB(COLOR_LIGHT_BLUE);
    [self.navigationController.navigationBar
     setBarTintColor:[UIColor whiteColor]];
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    numberToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleDefault;
    numberToolbar.items = [NSArray
                           arrayWithObjects:
                           [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                            style:UIBarButtonItemStyleBordered
                                                           target:self
                                                           action:@selector(cancelNumberPad)],
                           [[UIBarButtonItem alloc]
                            initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                            target:nil
                            action:nil],
                           [[UIBarButtonItem alloc] initWithTitle:@"Search"
                                                            style:UIBarButtonItemStyleDone
                                                           target:self
                                                           action:@selector(doneWithNumberPad)],
                           nil];
    [numberToolbar sizeToFit];
    UITextField *textField = [self.searchDisplayController.searchBar valueForKey: @"_searchField"];
    [textField setTextColor:[UIColor redColor]];
    [textField setFont:[UIFont fontWithName:kAppSupportedFontNormal size:17.0f]];
    self.searchDisplayController.searchBar.inputAccessoryView = numberToolbar;
    self.searchDisplayController.searchBar.delegate = self;
    self.searchDisplayController.searchResultsTableView.tableFooterView =
    [[UIView alloc] initWithFrame:CGRectZero];
    
    UIBarButtonItem *btnSearch;
    if (isFromEventsNearMe) {
        if (!isFromMyEvent) {
            btnAdvSearch = [UIButton buttonWithType:UIButtonTypeCustom];
            btnAdvSearch.bounds = CGRectMake(0, 0, 30, 27);
            [btnAdvSearch setImage:[UIImage imageNamed:@"advance-search"]
                          forState:UIControlStateNormal];
            [btnAdvSearch addTarget:self
                             action:@selector(showSearchVC)
                   forControlEvents:UIControlEventTouchUpInside];
            btnSearch =
            [[UIBarButtonItem alloc] initWithCustomView:btnAdvSearch];
            
            btnMapView = [UIButton buttonWithType:UIButtonTypeCustom];
            btnMapView.bounds = CGRectMake(0, 0, 30, 27);
            [btnMapView setUserInteractionEnabled:NO];
            [btnMapView setEnabled:NO];
            [btnMapView setImage:[UIImage imageNamed:@"maps_place"]
                        forState:UIControlStateNormal];
            [btnMapView addTarget:self
                           action:@selector(showMapVC)
                 forControlEvents:UIControlEventTouchUpInside];
            UIBarButtonItem *btnMap =
            [[UIBarButtonItem alloc] initWithCustomView:btnMapView];
            
            self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:btnSearch, btnMap, nil];
        }
    }
    
    isSearched = NO;
    
    [self.searchDisplayController.searchBar setTintColor:[UIColor grayColor]];
    [self.searchDisplayController.searchBar
     setBackgroundColor:UIColorFromRGB(SEARCH_BAR_TINT_COLOR)];
    
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
    
    _tableData = [[NSMutableArray alloc] init];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    _resultTableData = [[NSMutableArray alloc] init];
    
    self.navigationController.navigationBarHidden = NO;
    // Do any additional setup after loading the view from its nib.
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading...";
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(getEventsForUser:)
     name:@"com.snapprints.login.success"
     object:[NSNumber numberWithInteger:loggedUser_id]];
    [self.searchDisplayController.searchResultsTableView
     setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    tableViewRect = self.tableView.frame;
    if (isFromMyEvent) {
        [self.searchDisplayController.searchBar setHidden:YES];
        float dy = _tableView.frame.origin.y -
        self.searchDisplayController.searchBar.frame.size.height;
        float newHeight = _tableView.frame.size.height +
        self.searchDisplayController.searchBar.frame.size.height;
        [_tableView
         setFrame:CGRectMake(0, dy, _tableView.frame.size.width, newHeight)];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (isAdvanceSearch) {
        isSearched = YES;
        [_refreshHeaderView removeFromSuperview];
        _refreshHeaderView.delegate = nil;
        //self.tableView.frame = tableViewRect;
        [self.tableView setFrame:CGRectMake(tableViewRect.origin.x, tableViewRect.origin.y, tableViewRect.size.width, tableViewRect.size.height - 64)];
        [self.tableView reloadData];

    } else {
        if (_refreshHeaderView == nil) {
            _refreshHeaderView = [[EGORefreshTableHeaderView alloc]
                                  initWithFrame:CGRectMake(0.0f,
                                                           0.0f - self.tableView.bounds.size.height,
                                                           self.view.frame.size.width,
                                                           self.tableView.bounds.size.height)];
            _refreshHeaderView.delegate = self;
            [self.tableView addSubview:_refreshHeaderView];
            float dy;
            if(!isFromMyEvent)
            {
                dy = self.searchDisplayController.searchBar.frame.origin.y + self.searchDisplayController.searchBar.frame.size.height;
                self.tableView.frame = CGRectMake(0, dy, self.tableView.frame.size.width, self.tableView.frame.size.height);
            }
            
        }
        //  update the last update date
        [_refreshHeaderView refreshLastUpdatedDate];
    }
    if (isResetFromSearch) {
        [hud show:YES];
        isAdvanceSearch = NO;
        isResetFromSearch = NO;
        [self getEventsForUser:0];
        self.tableView.frame = tableViewRect;
    }
    if(isFromEventsNearMe)
    {
        if(([_tableData count]>0 || [_resultTableData count]>0))
        {
            [btnMapView setUserInteractionEnabled:YES];
            [btnMapView setEnabled:YES];
        }
        else
        {
            [btnMapView setUserInteractionEnabled:NO];
            [btnMapView setEnabled:NO];
        }
    }
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action events
- (IBAction)btnResetClicked:(id)sender {
    isAdvanceSearch = NO;
    isSearched = NO;
    isFromAdavanceSearch = NO;
    [hud show:YES];
    [_btnReset setHidden:YES];
    _refreshHeaderView.delegate = self;
    [self.tableView addSubview:_refreshHeaderView];
    [_refreshHeaderView refreshLastUpdatedDate];
    
    NSUserDefaults *objDefaults = [NSUserDefaults standardUserDefaults];
    [objDefaults removeObjectForKey:@"cat_ID"];
    [objDefaults removeObjectForKey:@"cat_Name"];
    [objDefaults removeObjectForKey:@"zipcode"];
    [objDefaults removeObjectForKey:@"city"];
    [objDefaults removeObjectForKey:@"eventName"];
    [objDefaults removeObjectForKey:@"latittude"];
    [objDefaults removeObjectForKey:@"longitude"];
    [objDefaults removeObjectForKey:@"distance"];
    [objDefaults synchronize];
    [self getEventsForUser:0];
}

#pragma mark - Custom Methods

- (void)sideMenu:(id)sender {
    NSLog(@"%@", self.menuContainerViewController);
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{}];
}

/*
 Function: getLocationFromIP
 Decription: This fuction is to get location from IP address.
 Return: Void
 
 */
- (void)getLocationFromIP {
    
    // Method 1 - External IP With Geolocation
    
    // Defines the webservice URL
    NSURL *URL = [NSURL URLWithString:@"http://ip-api.com/json"];
    
    // Start Connection
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:URL];
    
    // Define the JSON header
    [httpClient setDefaultHeader:@"Accept" value:@"text/json"];
    
    // Set the Request
    NSMutableURLRequest *request =
    [httpClient requestWithMethod:@"GET" path:@"" parameters:nil];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation
                                         JSONRequestOperationWithRequest:request
                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                             
                                             NSString *myIP = [JSON valueForKey:@"query"];
                                             NSLog(@"IP: %@", myIP);
                                         }
                                         failure:^(NSURLRequest *request, NSHTTPURLResponse *response,
                                                   NSError *error, id JSON) {
                                             
                                             // Failed
                                             NSLog(@"error: %@", error.description);
                                         }];
    
    // Run the Request
    [operation start];
    
    // *******************************
    
    // Method 2 - External IP Without Geolocation
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       NSURL *theURL = [[NSURL alloc]
                                        initWithString:@"http://ip-api.com/line/?fields=query"];
                       NSString *myIP =
                       [[NSString alloc] initWithData:[NSData dataWithContentsOfURL:theURL]
                                             encoding:NSUTF8StringEncoding];
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                           // Manipulate the ip on the main queue
                           NSLog(@"IP: %@", myIP);
                       });
                   });
}

/*
 Function: DisplayEvent
 Decription: Display event data on cell.
 Return: UITableViewCell
 Param: EventTableViewCell, Event
 */
- (UITableViewCell *)DisplayEvent:(EventTableViewCell *)eventCell
                         ForEvent:(Event *)event {
    
    if (event.intInvite == 0) {
        eventCell.imgViewInviteBG.backgroundColor = [UIColor whiteColor];
        //        NSLog(@"invite = %ld",(long)event.intInvite);
    }else{
        eventCell.imgViewInviteBG.backgroundColor = [UIColor colorWithRed:151.0f/255.0f green:205.0f/255.0f blue:239.0f/255.0f alpha:1.0f];
        //        eventCell.imgViewInviteBG.backgroundColor = [UIColor lightGrayColor];
        //        NSLog(@"invite = %ld",(long)event.intInvite);
    }
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setTimeZone:[NSTimeZone localTimeZone]];
    NSDate *date = event.eventStartDateTime;
    
    static NSString *format1 = @"dd MMM, yyyy";
    [df setDateFormat:format1];
    NSString *strDatePart1 = [df stringFromDate:date];
    static NSString *format2 = @"hh:mm a";
    [df setDateFormat:format2];
    NSString *strDatePart2 = [df stringFromDate:date];
    // Changes by mohsinali on 27 may 2015
    NSString *strDateTime =
    [NSString stringWithFormat:@"%@", strDatePart1];
    
    NSString *strTime = [NSString stringWithFormat:@"%@",strDatePart2];
    
    // Set font for labels in cell
    [eventCell.eventTitleLabel setFont:[UIFont fontWithName:kAppSupportedFontNormal size:18]];
    [eventCell.dateLabel setFont:[UIFont fontWithName:kAppSupportedFontNormal size:13]];
    [eventCell.photosLabel setFont:[UIFont fontWithName:kAppSupportedFontNormal size:12]];
    [eventCell.priceLabel setFont:[UIFont systemFontOfSize:12]];
    [eventCell.photosLabel setTextColor:[UIColor darkGrayColor]];
    // Changes by mohsinali on 27 may 2015
    eventCell.eventTitleLabel.text = event.title;
    eventCell.dateLabel.text = strDateTime;
    eventCell.timeLabel.text = strTime;
    
    [eventCell.cityLabel setFont:[UIFont fontWithName:kAppSupportedFontNormal size:12.f]];
    // Changes by mohsinali on 27 may 2015
    NSString *strCityState = @"";
    if ([event.address.city isEqualToString:@""]) {
        strCityState = [NSString stringWithFormat:@"%@",event.address.city];
    }else{
        strCityState = [NSString stringWithFormat:@"%@, %@",event.address.city,event.address.state];
    }
    [eventCell.cityLabel setText:strCityState];
    NSString *format = [NSString stringWithFormat:@"self.published == '1'"];
    NSPredicate *pred = [NSPredicate predicateWithFormat:format];
    event.photos = [NSMutableArray
                    arrayWithArray:[event.photos filteredArrayUsingPredicate:pred]];
    
    if ([event.photos count] == 1) {
        eventCell.photosLabel.text = [NSString
                                      stringWithFormat:@"%lu ", (unsigned long)[event.photos count]];
    } else {
        eventCell.photosLabel.text = [NSString
                                      stringWithFormat:@"%lu ", (unsigned long)[event.photos count]];
    }
    
    if ([event.price floatValue] == 0.00) {
        eventCell.priceLabel.text = @"FREE";
    } else {
        eventCell.priceLabel.text =
        [NSString stringWithFormat:@"$%.02f", [event.price floatValue]];
    }
    
    NSString *urlString = [self getImageURLForEvent:event];
    [eventCell.actvityIndicator startAnimating];
    eventCell.thumbnailURLString = urlString;
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    __weak UIImageView *weakEventImageView = eventCell.thumbnailImageView;
    __weak UIActivityIndicatorView *weakActivityIndicator =
    eventCell.actvityIndicator;
    
    if ([urlString isEqualToString:@""]) {
        [eventCell.actvityIndicator stopAnimating];
        [eventCell.thumbnailImageView setImage:[UIImage imageNamed:@"coming-soon"]];
    } else {
        [eventCell.thumbnailImageView setImageWithURLRequest:request
                                            placeholderImage:Nil
                                                     success:^(NSURLRequest *request, NSHTTPURLResponse *response,
                                                               UIImage *image) {
                                                         
                                                         [weakActivityIndicator stopAnimating];
                                                         image = [image
                                                                  imageScaledToFitSize:CGSizeMake(
                                                                                                  weakEventImageView.frame.size.width,
                                                                                                  weakEventImageView.frame.size.height)];
                                                         eventCell.thumbnailImageView.image = image;
                                                     }
                                                     failure:^(NSURLRequest *request, NSHTTPURLResponse *response,
                                                               NSError *error) {
                                                         
                                                         [weakActivityIndicator stopAnimating];
                                                         [eventCell.thumbnailImageView
                                                          setImage:[UIImage imageNamed:@"coming-soon"]];
                                                     }];
    }
    //  CALayer *layer = eventCell.thumbnailImageView.layer;
    //  [layer setMasksToBounds:YES];
    //  [layer setCornerRadius:5.f];
    //  [layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    //  [layer setBorderWidth:0.5f];
    
    //  eventCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if (event.isPrivate) {
        [eventCell.btnPrivate setHidden:NO];
    } else {
        [eventCell.btnPrivate setHidden:YES];
    }
    //  [eventCell.btnPrivate.layer
    //      setBorderColor:[UIColorFromRGB(COLOR_LIGHT_BLUE) CGColor]];
    //  [[eventCell.btnPrivate layer] setBorderWidth:1.0f];
    //  [[eventCell.btnPrivate layer] setCornerRadius:4.0f];
    //  eventCell.btnPrivate.titleLabel.font =
    //      [UIFont fontWithName:@"Calibri-Light" size:12.0];
    
    return eventCell;
}

/*
 Function: showSearchVC
 Decription: Navigate to SearchViewController on click of advance search bar
 button.
 Return: void
 */
- (void)showSearchVC
{
    SearchViewController *searchVC =
    [[SearchViewController alloc] initWithNibName:@"SearchViewController"
                                           bundle:[NSBundle mainBundle]];
    searchVC.delegate = self;
    [_tableView setContentOffset:CGPointMake(0, 0)];
    [self.navigationController pushViewController:searchVC animated:YES];
}

/*
 Function: showMapVC
 Decription: Navigate to MapViewController on click of map view bar
 button.
 Return: void
 */
- (void)showMapVC{
    hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    [hud setMode:MBProgressHUDModeIndeterminate];
    [self performSelector:@selector(showMap) withObject:nil afterDelay:0.2];
}
///
-(void)showMap
{
    if(isMapShowing)
    {
        [hud hide:YES];
        [btnMapView setImage:[UIImage imageNamed:@"maps_place"] forState:UIControlStateNormal];
        isMapShowing = NO;
        [mapVC.view removeFromSuperview];
        [btnAdvSearch setUserInteractionEnabled:YES];
        [btnAdvSearch setEnabled:YES];
        //[self refreshEventList];
        [self.tableView reloadData];
    }
    else
    {
        [btnMapView setImage:[UIImage imageNamed:@"action_list"] forState:UIControlStateNormal];
        if(isFromAdavanceSearch && isAdvanceSearch)
            mapVC.eventsArray = _tableData;
        else if(isSearched)
            mapVC.eventsArray = _resultTableData;
        else
            mapVC.eventsArray = _tableData;
        mapVC.superNavController = self.navigationController;
        [self.view addSubview:mapVC.view];
        [btnAdvSearch setUserInteractionEnabled:NO];
        [btnAdvSearch setEnabled:NO];
        isMapShowing = YES;
        [hud hide:YES];
    }
}
- (void)loadGoogleAds {
    
    //  bannerView_ = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    //  bannerView_.adUnitID = ADUNITID;
    //  bannerView_.rootViewController = self;
    //  add_request = [GADRequest request];
    //  add_request.gender = kGADGenderMale;
    //  [add_request setLocationWithDescription:ADLOCATION];
    //  [add_request setLocationWithLatitude:location.coordinate.latitude
    //                             longitude:location.coordinate.longitude
    //                              accuracy:[ADACCURACYINMETER floatValue]];
    //  [add_request setBirthdayWithMonth:[ADBIRTHDAY intValue]
    //                                day:[ADBIRTHMONTH intValue]
    //                               year:[ADBIRTHYEAR intValue]];
    //  [bannerView_ loadRequest:add_request];
}

/*
 Function: getImageURLForEvent
 Decription: Creates image url for event.
 Return: NSString
 Param: Event
 */
-(NSString *)getImageURLForEvent : (Event *)event {
    
    NSString *urlString;
    if (![event.thumbnail isEqualToString:@""]) {
        urlString = [NSString stringWithFormat:@"%@uploads/events/%@",
                     [Constants retriveServerURL],
                     event.thumbnail];
        return urlString;
    } else if ([event.photos count] == 0) {
        return @"";
    } else {
        Photo *photo = [event.photos objectAtIndex:0];
        urlString = [NSString stringWithFormat:@"%@/uploads/photos/%@",
                     [Constants retriveServerURL],
                     photo.thumbnail_filename];
        return urlString;
    }
    return @"";
}

#pragma mark - API Call
//
/*
 Function: searchEventsForParameters
 Decription: Get events based on search parameters.
 Return: void
 Param: NSDictionary
 */
- (void)searchEventsForParameters:(NSDictionary *)parameters {
    
    [_activityIndicator startAnimating];
    // http://71.43.59.189:10028/events/search_by_distance.json?distance=100&q=37057
    
    [[SnapprintsClient sharedSnapprintsClient]
     postPath:@"events/searchbydistance.json"
     parameters:parameters
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         
         NSArray *events = [responseObject objectForKey:@"events"];
         
         [_resultTableData removeAllObjects];
         
         NSDateFormatter *df = [[NSDateFormatter alloc] init];
         [df setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
         
         for (NSDictionary *eventsContainerDict in events) {
             NSDictionary *dict = [eventsContainerDict objectForKey:@"Event"];
             NSDictionary *dictInvite = [eventsContainerDict objectForKey:@"0"];
             
             Event *event = [[Event alloc] init];
             Company *company = [[Company alloc] init];
             Address *address = [[Address alloc] init];
             User *user = [[User alloc] init];
             
             address.address1 = [dict objectForKey:@"address1"];
             address.address2 = [dict objectForKey:@"address2"];
             address.city = [dict objectForKey:@"city"];
             address.state = [dict objectForKey:@"state"];
             address.zip = [dict objectForKey:@"zip"];
             
             if (![[dict objectForKey:@"company_id"]
                   isKindOfClass:[NSNull class]])
                 company.companyId =
                 [[dict objectForKey:@"company_id"] integerValue];
             
             company.name = [dict objectForKey:@"company_name"];
             
             if (![[dict objectForKey:@"user_id"] isKindOfClass:[NSNull class]])
                 user.userId = [[dict objectForKey:@"user_id"] integerValue];
             
             // Get event creator's name
             if (![[dict objectForKey:@"created_by"]
                   isKindOfClass:[NSNull class]])
                 user.username = [dict objectForKey:@"created_by"];
             else
                 user.username = @"";
             
             event.address = address;
             event.company = company;
             event.eventUser = user;
             
             if ([dictInvite objectForKey:@"is_invite"]) {
                 event.intInvite = [[dictInvite objectForKey:@"is_invite"] integerValue];
             }else{
                 event.intInvite = [[NSString stringWithFormat:@"0"] integerValue];
             }
             
             event.isPrivate = [[dict objectForKey:@"private"] boolValue];
             if ([[dict objectForKey:@"photo_limit"]
                  isKindOfClass:[NSNull class]]) {
                 event.photoLimit = 10;
             } else {
                 event.photoLimit =
                 [[dict objectForKey:@"photo_limit"] integerValue];
             }
             
             event.eventId = [[dict objectForKey:@"id"] integerValue];
             
             event.title = [dict objectForKey:@"title"];
             event.description = [dict objectForKey:@"description"];
             
             if ([[dict objectForKey:@"price"] isKindOfClass:[NSNull class]] ||
                 [[dict objectForKey:@"price"] length] == 0) {
                 
                 event.price = [NSNumber numberWithFloat:0.00];
             } else {
                 
                 event.price = [dict objectForKey:@"price"];
             }
             event.eventStartDateTime =
             [df dateFromString:[dict objectForKey:@"event_start_time"]];
             event.eventEndDateTime =
             [df dateFromString:[dict objectForKey:@"event_end_time"]];
             
             event.created = [df dateFromString:[dict objectForKey:@"created"]];
             event.updated = [df dateFromString:[dict objectForKey:@"updated"]];
             
             if (![[dict objectForKey:@"thumbnail"]
                   isKindOfClass:[NSNull class]])
                 event.thumbnail = [dict objectForKey:@"thumbnail"];
             else
                 event.thumbnail = @"";
             
             NSArray *photos = [eventsContainerDict objectForKey:@"Photo"];
             
             if ([photos count] > 0) {
                 for (NSDictionary *photoDict in photos) {
                     Photo *photo = [[Photo alloc] init];
                     photo.filename = [photoDict objectForKey:@"filename"];
                     photo.thumbnail_filename =
                     [photoDict objectForKey:@"thumbnail"];
                     photo.photoID = [[photoDict objectForKey:@"id"] integerValue];
                     photo.published = [photoDict objectForKey:@"published"];
                     photo.is_deleted = [photoDict objectForKey:@"is_deleted"];
                     
                     photo.user = [[User alloc] init];
                     
                     if (![[photoDict objectForKey:@"user_id"]
                           isKindOfClass:[NSNull class]]) {
                         photo.user.userId =
                         [[photoDict objectForKey:@"user_id"] integerValue];
                     }
                     if (!isFromEventsNearMe) {
                         if (photo.user.userId == _userID) {
                             if (![photo.filename isEqualToString:@""] &&
                                 ![photo.thumbnail_filename isEqualToString:@""])
                                 if([photo.is_deleted isEqualToString:@"0"])
                                     [event.photos addObject:photo];
                         }
                         
                     } else {
                         if (![photo.filename isEqualToString:@""] &&
                             ![photo.thumbnail_filename isEqualToString:@""])
                             if([photo.is_deleted isEqualToString:@"0"])
                                 [event.photos addObject:photo];
                     }
                 }
             }
             
             NSDictionary *distanceDict =
             [eventsContainerDict objectForKey:@"0"];
             
             if (![[distanceDict objectForKey:@"distance"]
                   isKindOfClass:[NSNull class]]) {
                 event.distance =
                 [[distanceDict objectForKey:@"distance"] floatValue];
             } else {
                 event.distance = -5;
             }
             /*
              0 =             {
              "category_id" = 9;
              distance = "2.7497818089920534";
              };
              */
             NSDictionary *categoryDict =
             [eventsContainerDict objectForKey:@"0"];
             event.category_Id = [categoryDict objectForKey:@"category_id"];
             event.type = @"E";
             [_resultTableData addObject:event];
         }
         //[hud removeFromSuperview];
         isSearched = YES;
         [_activityIndicator stopAnimating];
         [self.searchDisplayController.searchResultsTableView reloadData];
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         if ([_resultTableData count] > 0)
             [_resultTableData removeAllObjects];
         [self.searchDisplayController.searchResultsTableView reloadData];
         [_activityIndicator stopAnimating];
     }];
}

/*
 Function: getCountOfPhotos
 Decription: Get photos count for event.
 Return: void
 Param: Event
 */
- (void)getCountOfPhotos:(Event *)event {
    NSString *path =
    [NSString stringWithFormat:@"/events/view/%ld", (long)event.eventId];
    [[SnapprintsClient sharedSnapprintsClient] getPath:path
                                            parameters:nil
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   
                                                   NSDictionary *eventDict = [responseObject objectForKey:@"event"];
                                                   NSArray *photos = [eventDict objectForKey:@"Photo"];
                                                   for (NSDictionary *dict in photos) {
                                                       
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
                                                       
                                                       if (photo.user.userId == _userID) {
                                                           if (![photo.filename isEqualToString:@""] &&
                                                               ![photo.thumbnail_filename isEqualToString:@""])
                                                           {
                                                               if([photo.is_deleted isEqualToString:@"0"])
                                                                   [event.photos addObject:photo];
                                                           }
                                                           
                                                       }
                                                   }
                                                   
                                                   // Remove event which have all reported photos from My Pictures
                                                   // Section.
                                                   //        NSString *format = [NSString
                                                   //        stringWithFormat:@"self.published == '1'"];
                                                   //        NSPredicate *pred = [NSPredicate
                                                   //        predicateWithFormat:format];
                                                   //        event.photos = [NSMutableArray arrayWithArray:[event.photos
                                                   //        filteredArrayUsingPredicate:pred]];
                                                   //
                                                   //        if ([event.photos count] == 0) {
                                                   //            [_tableData removeObject:event];
                                                   //        }
                                                   //
                                                   
                                                   [_tableView reloadData];
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   NSLog(@"Failed: %@", [error localizedDescription]);
                                               }];
}

/*
 Function: getEventsForUser
 Decription: Get events for logged in user for 'Events Near Me' and 'My
 Pictures' section.
 Return: void
 Param: NSInteger
 */
- (void)getEventsForUser:(NSInteger)userID {
    loggedUser_id = [[[NSUserDefaults standardUserDefaults]
                      objectForKey:@"user_id"] integerValue];
    _userID = userID;
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    CLLocation *location1 =
    [LocationManagerSingleton sharedSingleton].locationManager.location;
    
    if (!isFromEventsNearMe) {
        [parameters setObject:[NSNumber numberWithInteger:userID]
                       forKey:@"photo_user_id"];
        if (location1.coordinate.latitude != 0.00 &&
            location1.coordinate.longitude != 0.00) {
            
            [parameters
             setObject:[NSNumber numberWithDouble:location1.coordinate.latitude]
             forKey:@"lat"];
            [parameters
             setObject:[NSNumber numberWithDouble:location1.coordinate.longitude]
             forKey:@"lng"];
        }
    } else {
        
        // CLLocation *location = [LocationManagerSingleton
        // sharedSingleton].locationManager.location;
        
        if (location1.coordinate.latitude != 0.00 &&
            location1.coordinate.longitude != 0.00) {
            [parameters setObject:CONSTANT_DISTANCE forKey:@"distance"]; // 10000
            [parameters
             setObject:[NSNumber numberWithDouble:location1.coordinate.latitude]
             forKey:@"lat"];
            [parameters
             setObject:[NSNumber numberWithDouble:location1.coordinate.longitude]
             forKey:@"lng"];
        } else {
            //        NSLog(@"Use IP interrogation");
            [parameters setObject:CONSTANT_DISTANCE forKey:@"distance"]; // 10000
            [parameters
             setObject:[NSNumber numberWithDouble:0.0]
             forKey:@"lat"];
            [parameters
             setObject:[NSNumber numberWithDouble:0.0]
             forKey:@"lng"];        }
        
        NSString *user_id =
        [[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"];
        NSString *token =
        [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
        
        if (user_id) {
            [parameters setObject:user_id forKey:@"user_id"];
            [parameters setObject:token forKey:@"token"];
        }
    }
    [[SnapprintsClient sharedSnapprintsClient] postPath:@"events/searchbydistance.json"//@"events.json"
                                             parameters:parameters
                                                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                    NSArray *events = [responseObject objectForKey:@"events"];
                                                    NSLog(@"Event Count:%lu", (unsigned long)[events count]);
                                                    [_tableData removeAllObjects];
                                                    NSLog(@"Evnet List responseObject = %@",responseObject);
                                                    
                                                    NSDateFormatter *df = [[NSDateFormatter alloc] init];
                                                    [df setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
                                                    
                                                    int j = 0;
                                                    int z = 5;
                                                    for (int i = 0; i < [events count]; i++) {
                                                        NSMutableDictionary *eventDict =
                                                        [events objectAtIndex:i]; //[[NSMutableDictionary alloc] init];
                                                        NSDictionary *dict = [eventDict objectForKey:@"Event"];
                                                        NSDictionary *dictInvite = [eventDict objectForKey:@"0"];
                                                        
                                                        
                                                        Event *event = [[Event alloc] init];
                                                        event.type = @"E";
                                                        Company *company = [[Company alloc] init];
                                                        Address *address = [[Address alloc] init];
                                                        User *user = [[User alloc] init];
                                                        
                                                        
                                                        address.address1 = [dict objectForKey:@"address1"];
                                                        address.address2 = [dict objectForKey:@"address2"];
                                                        address.city = [dict objectForKey:@"city"];
                                                        address.state = [dict objectForKey:@"state"];
                                                        address.zip = [dict objectForKey:@"zip"];
                                                        
                                                        if (![[dict objectForKey:@"price"] isKindOfClass:[NSNull class]]) {
                                                            event.price = [NSNumber
                                                                           numberWithFloat:[[dict objectForKey:@"price"] floatValue]];
                                                        } else {
                                                            event.price = [NSNumber numberWithFloat:0.00];
                                                        }
                                                        
                                                        if (![[dict objectForKey:@"lat"] isKindOfClass:[NSNull class]]) {
                                                            float lat = [[dict objectForKey:@"lat"] floatValue];
                                                            float lng = [[dict objectForKey:@"lng"] floatValue];
                                                            address.coordinate = CLLocationCoordinate2DMake(lat, lng);
                                                        }
                                                        
                                                        if ([dictInvite objectForKey:@"is_invite"]) {
                                                            event.intInvite = [[dictInvite objectForKey:@"is_invite"] integerValue];
                                                        }else{
                                                            event.intInvite = [[NSString stringWithFormat:@"0"] integerValue];
                                                        }
                                                        
                                                        event.isPrivate = [[dict objectForKey:@"private"] boolValue];
                                                        
                                                        if (![[dict objectForKey:@"company_id"]
                                                              isKindOfClass:[NSNull class]])
                                                            company.companyId =
                                                            [[dict objectForKey:@"company_id"] integerValue];
                                                        
                                                        company.name = [dict objectForKey:@"company_name"];
                                                        
                                                        if (![[dict objectForKey:@"user_id"] isKindOfClass:[NSNull class]])
                                                            user.userId = [[dict objectForKey:@"user_id"] integerValue];
                                                        
                                                        // Get event creator's name
                                                        if (![[dict objectForKey:@"created_by"]
                                                              isKindOfClass:[NSNull class]])
                                                            user.username = [dict objectForKey:@"created_by"];
                                                        else
                                                            user.username = @"";
                                                        
                                                        event.address = address;
                                                        event.company = company;
                                                        event.eventUser = user;
                                                        
                                                        if (![[dict objectForKey:@"photo_limit"]
                                                              isKindOfClass:[NSNull class]]) {
                                                            event.photoLimit =
                                                            [[dict objectForKey:@"photo_limit"] integerValue];
                                                        } else {
                                                            event.photoLimit = 10;
                                                        }
                                                        
                                                        event.eventId = [[dict objectForKey:@"id"] integerValue];
                                                        
                                                        event.title = [dict objectForKey:@"title"];
                                                        event.description = [dict objectForKey:@"description"];
                                                        
                                                        event.eventStartDateTime =
                                                        [df dateFromString:[dict objectForKey:@"event_start_time"]];
                                                        event.eventEndDateTime =
                                                        [df dateFromString:[dict objectForKey:@"event_end_time"]];
                                                        event.created = [df dateFromString:[dict objectForKey:@"created"]];
                                                        event.updated = [df dateFromString:[dict objectForKey:@"updated"]];
                                                        
                                                        if ([[dict objectForKey:@"thumbnail"]
                                                             isKindOfClass:[NSNull class]]) {
                                                            event.thumbnail = @"";
                                                        } else {
                                                            event.thumbnail = [dict objectForKey:@"thumbnail"];
                                                        }
                                                        
                                                        if (!isFromEventsNearMe) {
                                                            [self getCountOfPhotos:event];
                                                        } else {
                                                            NSArray *photos = [eventDict objectForKey:@"Photo"];
                                                            
                                                            if ([photos count] > 0) {
                                                                for (NSDictionary *photoDict in photos) {
                                                                    Photo *photo = [[Photo alloc] init];
                                                                    
                                                                    if ([photoDict isKindOfClass:[NSDictionary class]]) {
                                                                        photo.filename = [photoDict objectForKey:@"filename"];
                                                                        photo.thumbnail_filename =
                                                                        [photoDict objectForKey:@"thumbnail"];
                                                                        photo.photoID =
                                                                        [[photoDict objectForKey:@"id"] integerValue];
                                                                        photo.published = [photoDict objectForKey:@"published"];
                                                                        photo.is_deleted = [photoDict objectForKey:@"is_deleted"];
                                                                        
                                                                        if (![[photoDict objectForKey:@"flag_count"]
                                                                              isKindOfClass:[NSNull class]]) {
                                                                            photo.flagCount =
                                                                            [[photoDict objectForKey:@"flag_count"] intValue];
                                                                        } else {
                                                                            photo.flagCount = 0;
                                                                        }
                                                                        
                                                                        photo.user = [[User alloc] init];
                                                                        
                                                                        if (![[photoDict objectForKey:@"user_id"]
                                                                              isKindOfClass:[NSNull class]]) {
                                                                            photo.user.userId =
                                                                            [[photoDict objectForKey:@"user_id"] integerValue];
                                                                        }
                                                                        
                                                                        if (photo.flagCount < 3) {
                                                                            if (![photo.filename isEqualToString:@""] &&
                                                                                ![photo.thumbnail_filename isEqualToString:@""])
                                                                            {
                                                                                if([photo.is_deleted isEqualToString:@"0"])
                                                                                    [event.photos addObject:photo];
                                                                            }
                                                                            
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                        
                                                        NSDictionary *distanceDict = [eventDict objectForKey:@"0"];
                                                        
                                                        if (![[distanceDict objectForKey:@"distance"]
                                                              isKindOfClass:[NSNull class]]) {
                                                            event.distance =
                                                            [[distanceDict objectForKey:@"distance"] floatValue];
                                                        } else {
                                                            event.distance = -5;
                                                        }
                                                        NSDictionary *categoryDict = [eventDict objectForKey:@"EC"];
                                                        NSString *strCategoryId =
                                                        [categoryDict objectForKey:@"category_id"];
                                                        if ([strCategoryId isKindOfClass:[NSNull class]])
                                                            event.category_Id = @"";
                                                        else
                                                            event.category_Id = strCategoryId;
                                                        [_tableData addObject:event];
                                                        j++;
#warning For Ad displaying
                                                        if (j == z) {
                                                            Event *event1 = [[Event alloc] init];
                                                            event1.type = @"B";
                                                            if (j == 5) {
                                                                j = 0;
                                                                z = 10;
                                                            } else {
                                                                j = 0;
                                                            }
                                                            [_tableData addObject:event1];
                                                        }
                                                    }
                                                    
                                                    [_tableView reloadData];
                                                    if([_tableData count] >0 || [_resultTableData count] > 0)
                                                    {
                                                        [btnMapView setUserInteractionEnabled:YES];
                                                        [btnMapView setEnabled:YES];
                                                    }
                                                    [hud hide:YES];
                                                }
                                                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                    NSLog(@"%@", error.description);
                                                    
                                                    [hud hide:YES];
                                                    [hud removeFromSuperview];
                                                }];
}

/*
 Function: getEventsForMyEvents
 Decription: Get events for logged in user for 'My Events' section.
 Return: void
 Param: NSInteger
 */
- (void)getEventsForMyEvents:(NSInteger)userID {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    NSString *user_id =
    [[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"];
    if (user_id) {
        [parameters setObject:user_id forKey:@"user_id"];
    }
    
    [[SnapprintsClient sharedSnapprintsClient] getPath:@"events/my.json"
                                            parameters:parameters
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   [hud hide:YES];
                                                   [hud removeFromSuperview];
                                                   if ([[responseObject valueForKey:@"status"]
                                                        isEqualToString:@"success"]) {
                                                       
                                                       NSArray *events = [responseObject objectForKey:@"events"];
                                                       [_tableData removeAllObjects];
                                                       
                                                       NSDateFormatter *df = [[NSDateFormatter alloc] init];
                                                       [df setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
                                                       
                                                       int j = 0;
                                                       int z = 5;
                                                       for (int i = 0; i < [events count]; i++) {
                                                           NSMutableDictionary *eventDict = [events objectAtIndex:i];
                                                           
                                                           NSDictionary *dict = [eventDict objectForKey:@"Event"];
                                                           
                                                           Event *event = [[Event alloc] init];
                                                           event.type = @"E";
                                                           Company *company = [[Company alloc] init];
                                                           Address *address = [[Address alloc] init];
                                                           User *user = [[User alloc] init];
                                                           
                                                           address.address1 = [dict objectForKey:@"address1"];
                                                           address.address2 = [dict objectForKey:@"address2"];
                                                           address.city = [dict objectForKey:@"city"];
                                                           address.state = [dict objectForKey:@"state"];
                                                           address.zip = [dict objectForKey:@"zip"];
                                                           
                                                           if (![[dict objectForKey:@"price"]
                                                                 isKindOfClass:[NSNull class]]) {
                                                               event.price = [NSNumber
                                                                              numberWithFloat:[[dict objectForKey:@"price"] floatValue]];
                                                           } else {
                                                               event.price = [NSNumber numberWithFloat:0.00];
                                                           }
                                                           
                                                           if (![[dict objectForKey:@"lat"] isKindOfClass:[NSNull class]]) {
                                                               float lat = [[dict objectForKey:@"lat"] floatValue];
                                                               float lng = [[dict objectForKey:@"lng"] floatValue];
                                                               address.coordinate = CLLocationCoordinate2DMake(lat, lng);
                                                           }
                                                           
                                                           event.isPrivate = [[dict objectForKey:@"private"] boolValue];
                                                           
                                                           if (![[dict objectForKey:@"company_id"]
                                                                 isKindOfClass:[NSNull class]])
                                                               company.companyId =
                                                               [[dict objectForKey:@"company_id"] integerValue];
                                                           
                                                           company.name = [dict objectForKey:@"company_name"];
                                                           
                                                           if (![[dict objectForKey:@"user_id"]
                                                                 isKindOfClass:[NSNull class]])
                                                               user.userId = [[dict objectForKey:@"user_id"] integerValue];
                                                           
                                                           if (![[dict objectForKey:@"created_by"]
                                                                 isKindOfClass:[NSNull class]])
                                                               user.username = [dict objectForKey:@"created_by"];
                                                           else
                                                               user.username = @"";
                                                           
                                                           event.address = address;
                                                           event.company = company;
                                                           event.eventUser = user;
                                                           
                                                           if (![[dict objectForKey:@"photo_limit"]
                                                                 isKindOfClass:[NSNull class]]) {
                                                               event.photoLimit =
                                                               [[dict objectForKey:@"photo_limit"] integerValue];
                                                           } else {
                                                               event.photoLimit = 10;
                                                           }
                                                           
                                                           event.eventId = [[dict objectForKey:@"id"] integerValue];
                                                           
                                                           event.title = [dict objectForKey:@"title"];
                                                           event.description = [dict objectForKey:@"description"];
                                                           
                                                           event.eventStartDateTime =
                                                           [df dateFromString:[dict objectForKey:@"event_start_time"]];
                                                           event.eventEndDateTime =
                                                           [df dateFromString:[dict objectForKey:@"event_end_time"]];
                                                           event.created =
                                                           [df dateFromString:[dict objectForKey:@"created"]];
                                                           event.updated =
                                                           [df dateFromString:[dict objectForKey:@"updated"]];
                                                           
                                                           if ([[dict objectForKey:@"thumbnail"]
                                                                isKindOfClass:[NSNull class]]) {
                                                               
                                                               event.thumbnail = @"";
                                                               
                                                           } else {
                                                               
                                                               event.thumbnail = [dict objectForKey:@"thumbnail"];
                                                           }
                                                           
                                                           NSArray *photos = [eventDict objectForKey:@"Photo"];
                                                           
                                                           if ([photos count] > 0) {
                                                               for (NSDictionary *photoDict in photos) {
                                                                   Photo *photo = [[Photo alloc] init];
                                                                   
                                                                   if ([photoDict isKindOfClass:[NSDictionary class]]) {
                                                                       photo.filename = [photoDict objectForKey:@"filename"];
                                                                       photo.thumbnail_filename =
                                                                       [photoDict objectForKey:@"thumbnail"];
                                                                       photo.photoID =
                                                                       [[photoDict objectForKey:@"id"] integerValue];
                                                                       photo.published = [photoDict objectForKey:@"published"];
                                                                       photo.is_deleted = [photoDict objectForKey:@"is_deleted"];
                                                                       
                                                                       if (![[photoDict objectForKey:@"flag_count"]
                                                                             isKindOfClass:[NSNull class]]) {
                                                                           photo.flagCount =
                                                                           [[photoDict objectForKey:@"flag_count"] intValue];
                                                                       } else {
                                                                           photo.flagCount = 0;
                                                                       }
                                                                       
                                                                       photo.user = [[User alloc] init];
                                                                       
                                                                       if (![[photoDict objectForKey:@"user_id"]
                                                                             isKindOfClass:[NSNull class]]) {
                                                                           photo.user.userId =
                                                                           [[photoDict objectForKey:@"user_id"] integerValue];
                                                                       }
                                                                       
                                                                       if (photo.flagCount < 3) {
                                                                           if (![photo.filename isEqualToString:@""] &&
                                                                               ![photo.thumbnail_filename isEqualToString:@""])
                                                                           {
                                                                               
                                                                               if([photo.is_deleted isEqualToString:@"0"])
                                                                                   [event.photos addObject:photo];
                                                                           }
                                                                           
                                                                       }
                                                                   }
                                                               }
                                                           }
                                                           
                                                           //            }
                                                           
                                                           NSDictionary *distanceDict = [eventDict objectForKey:@"0"];
                                                           
                                                           if (![[distanceDict objectForKey:@"distance"]
                                                                 isKindOfClass:[NSNull class]]) {
                                                               event.distance =
                                                               [[distanceDict objectForKey:@"distance"] floatValue];
                                                           } else {
                                                               event.distance = -5;
                                                           }
                                                           
                                                           //                EC =     {
                                                           //                    "category_id" = 3;
                                                           //                };
                                                           NSDictionary *categoryDict = [eventDict objectForKey:@"EC"];
                                                           NSString *strCategoryId =
                                                           [categoryDict objectForKey:@"category_id"];
                                                           if ([strCategoryId isKindOfClass:[NSNull class]])
                                                               event.category_Id = @"";
                                                           else
                                                               event.category_Id = strCategoryId;
                                                           
                                                           [_tableData addObject:event];
                                                           j++;
#warning For Ad displaying
                                                           if (j == z) {
                                                               Event *event1 = [[Event alloc] init];
                                                               event1.type = @"B";
                                                               if (j == 5) {
                                                                   
                                                                   j = 0;
                                                                   z = 10;
                                                               } else {
                                                                   
                                                                   j = 0;
                                                               }
                                                               [_tableData addObject:event1];
                                                           }
                                                       }
                                                       [_tableView reloadData];
                                                       
                                                       if([_tableData count] >0 || [_resultTableData count] > 0)
                                                       {
                                                           [btnMapView setUserInteractionEnabled:YES];
                                                           [btnMapView setEnabled:YES];
                                                       }
                                                       
                                                   } else {
                                                       
                                                       [TSMessage
                                                        showNotificationWithTitle:@"Error"
                                                        subtitle:[responseObject
                                                                  valueForKey:@"message"]
                                                        type:TSMessageNotificationTypeError];
                                                   }
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   NSLog(@"%@", error.description);
                                                   [TSMessage showNotificationWithTitle:@"Error"
                                                                               subtitle:@"Unknown error from server"
                                                                                   type:TSMessageNotificationTypeError];
                                                   [hud hide:YES];
                                                   [hud removeFromSuperview];
                                               }];
}

#pragma mark - UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
    }
    if (!isFromEventsNearMe) {
        return 1;
    } else {
        return 2;
    }
}

- (UIView *)tableView:(UITableView *)tableView
viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc]
                    initWithFrame:CGRectMake(0, 0, _tableHeader.frame.size.width,
                                             _tableHeader.frame.size.height)];
    
    NSString *title;
    if (!isFromEventsNearMe) {
        if (!isFromMyEvent) {
            if (tableView == self.searchDisplayController.searchResultsTableView){
                //           title = @"Search Results";
                UILabel *lable = [[UILabel alloc] init];
                lable.frame = self.navigationController.navigationBar.frame;
                lable.numberOfLines = 2;
                lable.text = @"Search Results";
                [lable sizeToFit];
                lable.textColor = [UIColor grayColor];
                lable.font = [UIFont fontWithName:kAppSupportedFontBold size:16.0f];
                self.navigationItem.titleView = lable;
            }
            else {
                //       title = @"My Pictures";
                UILabel *lable = [[UILabel alloc] init];
                lable.frame = self.navigationController.navigationBar.frame;
                lable.numberOfLines = 2;
                lable.text = @"My Pictures";
                [lable sizeToFit];
                lable.textColor = [UIColor grayColor];
                lable.font = [UIFont fontWithName:kAppSupportedFontBold size:16.0f];
                self.navigationItem.titleView = lable;
                isSearched = NO;
            }
        } else {
            //      title = @"My Events";
            UILabel *lable = [[UILabel alloc] init];
            lable.frame = self.navigationController.navigationBar.frame;
            lable.numberOfLines = 2;
            lable.text = @"My Events";
            [lable sizeToFit];
            lable.textColor = [UIColor grayColor];
            lable.font = [UIFont fontWithName:kAppSupportedFontBold size:16.0f];
            self.navigationItem.titleView = lable;
        }
    } else if (tableView == self.searchDisplayController.searchResultsTableView) {
        //    title = @"Search Results";
        UILabel *lable = [[UILabel alloc] init];
        lable.frame = self.navigationController.navigationBar.frame;
        lable.numberOfLines = 2;
        lable.text = @"Search Results";
        [lable sizeToFit];
        lable.textColor = [UIColor grayColor];
        lable.font = [UIFont fontWithName:kAppSupportedFontBold size:16.0f];
        self.navigationItem.titleView = lable;
        [_btnReset setHidden:YES];
    } else {
        if (section == 0) {
            if (isFromMyEvent){
                //        title = @"My Events";
                UILabel *lable = [[UILabel alloc] init];
                lable.frame = self.navigationController.navigationBar.frame;
                lable.numberOfLines = 2;
                lable.text = @"My Events";
                [lable sizeToFit];
                lable.textColor = [UIColor grayColor];
                lable.font = [UIFont fontWithName:kAppSupportedFontBold size:16.0f];
                self.navigationItem.titleView = lable;
            }
            else {
                if (isAdvanceSearch) {
                    NSUserDefaults *objDefaults = [NSUserDefaults standardUserDefaults];
                    NSString *strCategory = [objDefaults valueForKey:@"cat_Name"];
                    if (strCategory != nil && ![strCategory isEqualToString:@""]) {
                        title = strCategory;
                    } else{
                        //            title = @"Search Results";
                        /*
                        UILabel *lable = [[UILabel alloc] init];
                        lable.frame = self.navigationController.navigationBar.frame;
                        lable.numberOfLines = 2;
                        lable.text = @"Search Results";
                        [lable sizeToFit];
                        lable.textColor = [UIColor grayColor];
                        lable.font = [UIFont fontWithName:kAppSupportedFontBold size:16.0f];
                        self.navigationItem.titleView = lable;
                         */
                        [self performSelector:@selector(changeTitle) withObject:nil afterDelay:0.5];
                    }
                    isSearched = YES;
                    [_btnReset setHidden:NO];
                    [_headerTitle setFont:[UIFont fontWithName:kAppSupportedFontLight size:20]];
                    [_headerTitle setText:title];
                    [_headerTitle setTextAlignment:NSTextAlignmentCenter];
                    [_btnReset.layer setCornerRadius:5.0f];
                    [_btnReset.layer setMasksToBounds:YES];
                    [view addSubview:_tableHeader];
                    UIView *lineView = [[UIView alloc]
                                        initWithFrame:CGRectMake(0, _tableHeader.frame.size.height,
                                                                 self.view.frame.size.width, 0.5)];
                    [lineView setBackgroundColor:[UIColor lightGrayColor]];
                    [_tableHeader addSubview:lineView];
                    return view;
                } else {
                    isSearched = NO;
                    //          title = @"Events Near Me";
                    UILabel *lable = [[UILabel alloc] init];
                    lable.frame = self.navigationController.navigationBar.frame;
                    lable.numberOfLines = 2;
                    // Changes by mohsinali on 26 may 2015
                    lable.text = @"Nearby Events";//@"Event Near Me";
                    [lable sizeToFit];
                    lable.textColor = [UIColor grayColor];
                    lable.font = [UIFont fontWithName:kAppSupportedFontBold size:16.0f];
                    self.navigationItem.titleView = lable;
                    [_btnReset setHidden:YES];
                }
            }
        }
    }
    return nil;
}

-(void)changeTitle
{
    UILabel *lable = [[UILabel alloc] init];
    lable.frame = self.navigationController.navigationBar.frame;
    lable.numberOfLines = 2;
    lable.text = @"Search Results";
    [lable sizeToFit];
    lable.textColor = [UIColor grayColor];
    lable.font = [UIFont fontWithName:kAppSupportedFontBold size:16.0f];
    self.navigationItem.titleView = lable;

}

- (CGFloat)tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section {
    if(isSearched && isAdvanceSearch)
    {
        return TABLE_HEADER_HEIGHT;
    }
    else
        return 1;
    //        return (self.searchDisplayController.searchBar.frame.size.height);
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [_resultTableData count];
    } else {
        return [_tableData count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        if ([[_resultTableData objectAtIndex:0] isKindOfClass:[Region class]]) {
            return 50;
        } else if ([[_resultTableData objectAtIndex:0]
                    isKindOfClass:[Event class]]) {
            return 110;
        } else
            return 50;
    }
    Event *event = [_tableData objectAtIndex:indexPath.row];
    if ([event.type isEqualToString:@"B"]) {
        return 50;
    }
    return 110;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Event *event;
    Region *region;
    UITableViewCell *cell;
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        if ([[_resultTableData objectAtIndex:0] isKindOfClass:[Region class]]) {
            
            region = [_resultTableData objectAtIndex:indexPath.row];
            
        } else {
            
            event = [_resultTableData objectAtIndex:indexPath.row];
        }
        if (region) {
            NSString *CellIdentifier = @"CityCellIdentifier";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell =
                [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:CellIdentifier];
            }
            cell.textLabel.text = [NSString
                                   stringWithFormat:@"%@, %@", region.cityName, region.stateCode];
        }
        if (event) {
            
            static NSString *eventCellIdentifier = @"EventCell";
            EventTableViewCell *eventCell =
            [tableView dequeueReusableCellWithIdentifier:eventCellIdentifier];
            if (!eventCell) {
                eventCell = [[[NSBundle mainBundle] loadNibNamed:@"EventTableViewCell"
                                                           owner:self
                                                         options:nil] objectAtIndex:0];
            }
            
            cell = (EventTableViewCell *)[self DisplayEvent:eventCell ForEvent:event];
            eventCell = nil;
        }
        
    } else {
        Event *event = [_tableData objectAtIndex:indexPath.row];
        if ([event.type isEqualToString:@"E"]) {
            static NSString *eventCellIdentifier = @"EventCell";
            EventTableViewCell *eventCell =
            [tableView dequeueReusableCellWithIdentifier:eventCellIdentifier];
            if (!eventCell) {
                eventCell = [[[NSBundle mainBundle] loadNibNamed:@"EventTableViewCell"
                                                           owner:self
                                                         options:nil] objectAtIndex:0];
            }
            if (event) {
                cell =
                (EventTableViewCell *)[self DisplayEvent:eventCell ForEvent:event];
            }
            
            eventCell = nil;
        } else {
            static NSString *bannerCellIdentifier = @"BannerCell";
            BannerCell *bannerCell =
            [tableView dequeueReusableCellWithIdentifier:bannerCellIdentifier];
            if (!bannerCell) {
                bannerCell = [[[NSBundle mainBundle] loadNibNamed:@"BannerCell"
                                                            owner:self
                                                          options:nil] objectAtIndex:0];
            }
            //Changes by mohsinali on 29 may 2015

            RevMobBannerView *ad = [[RevMobAds session] bannerView];
            ad.delegate = self;
            [ad loadWithSuccessHandler:^(RevMobBannerView *banner) {
                [ad loadAd];
                [self revmobAdDidReceive];
                ad.frame = CGRectMake(20, bannerCell.contentView.frame.origin.y, bannerCell.contentView.frame.size.width-40, bannerCell.contentView.frame.size.height);
                [bannerCell.contentView addSubview:ad];
                NSLog(@"Ad loaded");
            } andLoadFailHandler:^(RevMobBannerView *banner, NSError *error) {
                NSLog(@"Ad error: %@",error);
                [self revmobAdDidFailWithError:error];
            } onClickHandler:^(RevMobBannerView *banner) {
                NSLog(@"Ad clicked");
                [self revmobUserClickedInTheAd];
            }];
            //      [bannerCell addSubview:_adView];
            
            cell = bannerCell;
            bannerCell = nil;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    EventDetailVC *eventDetailVC =
    [[EventDetailVC alloc] initWithNibName:@"EventDetailVC"
                                    bundle:[NSBundle mainBundle]];
    eventDetailVC.delegate = self;
    
    Event *event;
    Region *region;
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        if ([[_resultTableData objectAtIndex:indexPath.row]
             isKindOfClass:[Event class]]) {
            event = [_resultTableData objectAtIndex:indexPath.row];
        } else {
            region = [_resultTableData objectAtIndex:indexPath.row];
            self.searchDisplayController.searchBar.text = [NSString
                                                           stringWithFormat:@"%@, %@", region.cityName, region.stateCode];
        }
        
    } else {
        if (isFromEventsNearMe)
            isFromMyEvent = NO;
        else if (isFromMyPicture)
            isFromMyEvent = NO;
        else {
            isFromMyEvent = YES;
        }
        event = [_tableData objectAtIndex:indexPath.row];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (event) {
        if ([event.type isEqualToString:@"E"]) {
            eventDetailVC.event = event;
            if (!isFromEventsNearMe) {
                eventDetailVC.userID = _userID;
            }
            
            [self.navigationController pushViewController:eventDetailVC animated:YES];
        }
        
    } else {
        NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
        
        NSString *latString =
        [NSString stringWithFormat:@"%.5f", region.coordinate.latitude];
        NSString *lngString =
        [NSString stringWithFormat:@"%.5f", region.coordinate.longitude];
        
        [parameters setObject:latString forKey:@"lat"];
        [parameters setObject:lngString forKey:@"lng"];
        [parameters setObject:CONSTANT_DISTANCE forKey:@"distance"];
        
        NSString *user_id =
        [[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"];
        NSString *token =
        [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
        
        [parameters setObject:user_id forKey:@"user_id"];
        [parameters setObject:token forKey:@"token"];
        //    [parameters
        //        setObject:[NSString
        //                      stringWithFormat:@"%@", [[UIDevice currentDevice]
        //                      name]]
        //           forKey:@"device"];
        [self searchEventsForParameters:parameters];
        [self.searchDisplayController.searchBar resignFirstResponder];
    }
}

- (void)keyboardWillHide {
    
    UITableView *tableView =
    [[self searchDisplayController] searchResultsTableView];
    
    [tableView setContentInset:UIEdgeInsetsMake(0.0, 0.0, 256.0, 0.0)];
    [tableView setScrollIndicatorInsets:UIEdgeInsetsZero];
}

#pragma mark - Refresh Controller Delegate Methods
#pragma mark Data Source Loading / Reloading Methods
- (void)reloadTableViewDataSource {
    
    if (isFromMyEvent) {
        
        [hud show:YES];
        [self getEventsForMyEvents:loggedUser_id];
        
    } else if (isFromEventsNearMe) {
        
        [hud show:YES];
        [self getEventsForUser:_userID];
    } else {
        [hud show:YES];
        [self getEventsForUser:loggedUser_id];
    }
    //_reloading = YES;
}
- (void)doneLoadingTableViewData {
    
    //  model should call this when its done loading
    _reloading = NO;
    [_refreshHeaderView
     egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!isSearched) //|| !isAdvanceSearch)
        [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
    // Get visible cells on table view.
    NSArray *visibleCells = [self.tableView visibleCells];
    
    for (EventTableViewCell *cell in visibleCells) {
        
        [cell cellOnTableView:self.tableView didScrollOnView:self.view];
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate {
    
    if (!isSearched) //|| !isAdvanceSearch)
    {
        [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    }
}

#pragma mark - EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:
(EGORefreshTableHeaderView *)view {
    
    [self reloadTableViewDataSource];
    [self performSelector:@selector(doneLoadingTableViewData)
               withObject:nil
               afterDelay:0];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:
(EGORefreshTableHeaderView *)view {
    
    return _reloading; // should return if data source model is reloading
}

- (NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:
(EGORefreshTableHeaderView *)view {
    
    return [NSDate date]; // should return date data source was last changed
}

#pragma mark - FirstScreen Controller delegate

- (void)firstScreenViewController:(FirstScreenViewController *)controller
                         didLogin:(NSString *)status {
    //[_tableView reloadData];
    [self reloadTableViewDataSource];
}

#pragma mark - SearchBar Delegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    // isSearched = YES;
    for (UIView *searchBarSubview in [searchBar subviews]) {
        for (int i = 0; i < [[searchBarSubview subviews] count]; i++) {
            UIView *subview = [[searchBarSubview subviews] objectAtIndex:i];
            if ([subview isKindOfClass:[UITextField class]]) {
                UITextField *searchbarTextField = (UITextField *)subview;
                [searchbarTextField setReturnKeyType:UIReturnKeyDefault];
                break;
            }
        }
    }
}

- (BOOL)searchBar:(UISearchBar *)searchBar
shouldChangeTextInRange:(NSRange)range
  replacementText:(NSString *)text {
    NSString *currentString =
    [searchBar.text stringByReplacingCharactersInRange:range withString:text];
    NSCharacterSet *nonNumberSet = [[NSCharacterSet
                                     characterSetWithCharactersInString:ACCEPTABLE_CHAR] invertedSet];
    if ([currentString length] > 0) {
        
        if (isnumber([currentString characterAtIndex:0])) {
            
            if ([currentString length] > 5) {
                return NO;
            }
        }
    }
    if ([currentString rangeOfCharacterFromSet:nonNumberSet].location !=
        NSNotFound) {
        
        return NO;
    }
    
    return YES;
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [_tableView reloadData];
    searchBar.showsCancelButton = NO;
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    isSearched = NO;
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar
    textDidChange:(NSString *)searchText {
    if (searchText.length > 0 &&
        !isnumber(
                  [searchText characterAtIndex:0])) { // We are searching for a string
            [numberToolbar setHidden:YES];
            searchText = [searchText urlencode];
            NSString *urlString =
            [NSString stringWithFormat:@"http://ws.geonames.org/"
             @"searchJSON?name_startsWith=%@&country=US&"
             @"maxRows=5&username=akozlik",
             searchText];
            
            if (_operation) {
                [_operation cancel];
            }
            [_activityIndicator startAnimating];
            
            NSURLRequest *request =
            [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
            AFJSONRequestOperation *operation = [AFJSONRequestOperation
                                                 JSONRequestOperationWithRequest:request
                                                 success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                     
                                                     [self.resultTableData removeAllObjects];
                                                     
                                                     NSArray *geonames = [JSON objectForKey:@"geonames"];
                                                     
                                                     for (NSDictionary *dict in geonames) {
                                                         Region *region = [[Region alloc] init];
                                                         region.stateCode = [dict objectForKey:@"adminCode1"];
                                                         region.stateName = [dict objectForKey:@"adminName1"];
                                                         region.countryCode = [dict objectForKey:@"countryCode"];
                                                         region.countryName = [dict objectForKey:@"countryName"];
                                                         region.cityName = [dict objectForKey:@"name"];
                                                         region.coordinate = CLLocationCoordinate2DMake(
                                                                                                        [[dict objectForKey:@"lat"] floatValue],
                                                                                                        [[dict objectForKey:@"lng"] floatValue]);
                                                         
                                                         [self.resultTableData addObject:region];
                                                     }
                                                     
                                                     [self.searchDisplayController.searchResultsTableView reloadData];
                                                     //[self.searchDisplayController.searchResultsTableView
                                                     // setScrollEnabled:NO];
                                                     [_activityIndicator stopAnimating];
                                                 }
                                                 failure:^(NSURLRequest *request, NSHTTPURLResponse *response,
                                                           NSError *error,
                                                           id JSON) { [_activityIndicator stopAnimating]; }];
            
            [operation start];
        } else {
            [numberToolbar setHidden:NO];
            if ([_resultTableData count] > 0)
                [_resultTableData removeAllObjects];
            [_tableView reloadData];
        }
}

#pragma mark - SearchDisplayController delegate
- (void)searchDisplayController:(UISearchDisplayController *)controller
  didHideSearchResultsTableView:(UITableView *)tableView {
    
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:UIKeyboardWillHideNotification
     object:nil];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller
 willShowSearchResultsTableView:(UITableView *)tableView {
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(keyboardWillHide)
     name:UIKeyboardWillHideNotification
     object:nil];
}

#pragma mark - SearchViewController Delegate

- (void)advancedSearchData:(NSMutableArray *)arr
{
    isAdvanceSearch = YES; // This is for advance search is done.
    [resetButton setHidden:NO];
    if ([_tableData count] > 0)
        [_tableData removeAllObjects];
    _tableData = [NSMutableArray arrayWithArray:arr];
    isFromAdavanceSearch = YES;
    [_tableView reloadData];
    
}

#pragma mark - Numberpad Methods

- (void)doneWithNumberPad {
    if (![self.searchDisplayController.searchBar.text isEqualToString:@""]) {
        isSearched = YES;
        [_activityIndicator startAnimating];
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setObject:CONSTANT_DISTANCE forKey:@"distance"];
        [params setObject:self.searchDisplayController.searchBar.text forKey:@"q"];
        NSString *user_id =
        [[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"];
        
        [params setObject:user_id forKey:@"user_id"];
        NSString *token =
        [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
        [params setObject:token forKey:@"token"];
        //    [params
        //        setObject:[NSString
        //                      stringWithFormat:@"%@", [[UIDevice currentDevice]
        //                      name]]
        //           forKey:@"device"];
        [self searchEventsForParameters:params];
        [self.searchDisplayController.searchBar resignFirstResponder];
    }
}

- (void)cancelNumberPad {
    isSearched = NO;
    [self.searchDisplayController.searchBar resignFirstResponder];
    [self.searchDisplayController setActive:NO animated:YES];
    [_resultTableData removeAllObjects];
    [_activityIndicator stopAnimating];
    [_tableView reloadData];
}

#pragma mark - EventDetailsDelegate
- (void)refreshEventList { // After delete event this method get called from
    // event details.
    
    [self reloadTableViewDataSource];
}

#pragma mark - Stautsbar style

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

//Changes by mohsinali on 29 may 2015
#pragma mark - RevMobAdsDelegate methods

/////Session Listeners/////
- (void)revmobSessionIsStarted {
    NSLog(@"[RevMob Sample App] Session started with delegate.");
    //    [self basicUsageShowFullscreen];
}

- (void)revmobSessionNotStarted:(NSError *)error {
    NSLog(@"[RevMob Sample App] Session not started again: %@", error);
}


/////Ad Listeners/////
- (void)revmobAdDidReceive {
    NSLog(@"[RevMob Sample App] Ad loaded.");
}

- (void)revmobAdDidFailWithError:(NSError *)error {
    NSLog(@"[RevMob Sample App] Ad failed: %@", error);
}

- (void)revmobAdDisplayed {
    NSLog(@"[RevMob Sample App] Ad displayed.");
}

- (void)revmobUserClosedTheAd {
    NSLog(@"[RevMob Sample App] User clicked in the close button.");
}

- (void)revmobUserClickedInTheAd {
    NSLog(@"[RevMob Sample App] User clicked in the Ad.");
}


/////Video Listeners/////
-(void)revmobVideoDidLoad{
    NSLog(@"[RevMob Sample App] Video loaded.");
}

-(void)revmobVideoNotCompletelyLoaded{
    NSLog(@"[RevMob Sample App] Video not completely loaded.");
}

-(void)revmobVideoDidStart{
    NSLog(@"[RevMob Sample App] Video started.");
}

-(void)revmobVideoDidFinish{
    NSLog(@"[RevMob Sample App] Video started.");
}


/////Rewarded Video Listeners/////
-(void)revmobRewardedVideoDidLoad{
    NSLog(@"[RevMob Sample App] Rewarded Video loaded.");
}

-(void)revmobRewardedVideoNotCompletelyLoaded{
    NSLog(@"[RevMob Sample App] Rewarded Video not completely loaded.");
}

-(void)revmobRewardedVideoDidStart{
    NSLog(@"[RevMob Sample App] Rewarded Video started.");
}

-(void)revmobRewardedVideoDidFinish{
    NSLog(@"[RevMob Sample App] Rewarded Video finished.");
}

-(void)revmobRewardedVideoComplete {
    NSLog(@"[RevMob Sample App] Rewarded Video completed.");
}

-(void)revmobRewardedPreRollDisplayed{
    NSLog(@"[RevMob Sample App] Rewarded Pre Roll displayed.");
}


/////Advertiser Listeners/////
- (void)installDidReceive {
    NSLog(@"[RevMob Sample App] Install received.");
}

- (void)installDidFail {
    NSLog(@"[RevMob Sample App] Install failed.");
}


@end
