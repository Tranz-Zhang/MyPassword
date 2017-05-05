//
//  IndexInfo.h
//  MyPassword
//
//  Created by chance on 24/12/2016.
//  Copyright © 2016 bychance. All rights reserved.
//

#import "JSONModel.h"
#import "VaultDefines.h"

@interface IndexInfo : JSONModel

@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) PasswordIconType iconType;
@property (nonatomic, strong) NSString *passwordUUID;

@end
