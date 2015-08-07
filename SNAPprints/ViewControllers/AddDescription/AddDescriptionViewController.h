//
//  AddDescriptionViewController.h
//  SNAPprints
//
//  Created by Etay Luz on 1/27/14.
//  Copyright (c) 2014 Etay Luz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AddDescriptionViewController;

@protocol AddDescriptionViewControllerDelegate <NSObject>

- (void)addDescriptionController:(AddDescriptionViewController *)controller
              didSaveDescription:(NSString *)description;

@end

@interface AddDescriptionViewController : UIViewController <UITextViewDelegate>

@property(nonatomic, retain) IBOutlet UITextView *textView;
@property(nonatomic, weak) id delegate;
@property(nonatomic, retain) NSString *defaultText;

@end
