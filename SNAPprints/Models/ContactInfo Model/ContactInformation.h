//
//  ContactInformation.h
//  FlashRe
//
//  Created by Chetan Kale on 5/29/13.
//  Copyright (c) 2013 Etay Luz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContactInformation : NSObject

@property(nonatomic, strong) NSString *firstName;
@property(nonatomic, strong) NSString *contactId;
@property(nonatomic, strong) NSString *lastName;
@property(nonatomic, strong) NSString *strName;
@property(nonatomic, strong) NSString *userName;
@property(nonatomic, strong) NSString *phoneNo;
@property(nonatomic, strong) NSString *emailAdd;
@property(nonatomic, readwrite) BOOL isSelected;
@property(nonatomic, strong) NSString *isInvitedByPhone;
@property(nonatomic, strong) NSString *isInvitedByEmail;
@property(nonatomic, strong) NSString *strIsConnected;
@property(nonatomic, strong) NSString *imageUrlDocument;

@end
