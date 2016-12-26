//
//  IndexInfo.h
//  MyPassword
//
//  Created by chance on 24/12/2016.
//  Copyright © 2016 bychance. All rights reserved.
//

#import "JSONModel.h"

@interface IndexInfo : JSONModel

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *iconURL;
@property (nonatomic, strong) NSString *passwordUUID;

@end
