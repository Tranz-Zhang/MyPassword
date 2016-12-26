//
//  VaultInfo.h
//  MyPassword
//
//  Created by chance on 12/26/16.
//  Copyright © 2016 bychance. All rights reserved.
//

#import "JSONModel.h"

@interface VaultInfo : JSONModel

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSTimeInterval createdDate;
@property (nonatomic, assign) NSInteger version;
@property (nonatomic, strong) NSString *masterKey;

@end
