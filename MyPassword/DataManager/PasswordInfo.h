//
//  PasswordInfo.h
//  MyPassword
//
//  Created by chance on 24/12/2016.
//  Copyright © 2016 bychance. All rights reserved.
//

#import "JSONModel.h"
#import "VaultDefines.h"

@interface PasswordInfo : JSONModel <NSCopying>

@property (nonatomic, strong) NSString *UUID;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *notes;
@property (nonatomic, strong) NSString *account;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, assign) PasswordType type;
@property (nonatomic, assign) NSTimeInterval updatedDate;
@property (nonatomic, assign) NSTimeInterval createdDate;


- (BOOL)isEqual:(PasswordInfo *)object;
- (NSUInteger)hash;

@end
