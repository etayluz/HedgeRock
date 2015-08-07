//
//  WebViewController.m
//  SNAPprints
//
//  Created by Etay Luz on 2/18/14.
//  Copyright (c) 2014 Etay Luz. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

#pragma mark - LifeCycle

- (void)viewDidLoad {
  [super viewDidLoad];

  NSString *htmlFile =
      [[NSBundle mainBundle] pathForResource:@"toc" ofType:@"html"];
  NSString *htmlString = [NSString stringWithContentsOfFile:htmlFile
                                                   encoding:NSUTF8StringEncoding
                                                      error:nil];
  [_webView loadHTMLString:htmlString baseURL:nil];
    //self.navigationItem.title = @"Services and Privacy Policy";
    UILabel *lable = [[UILabel alloc] init];
    lable.frame = self.navigationController.navigationBar.frame;
    lable.numberOfLines = 2;
    lable.text = @"Services and Privacy Policy";
    [lable sizeToFit];
    lable.textColor = [UIColor grayColor];
    lable.font = [UIFont fontWithName:kAppSupportedFontBold size:16.0f];
    self.navigationItem.titleView = lable;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
