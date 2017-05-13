//
//  MergeInfo.h
//  MyPassword
//
//  Created by chance on 5/13/17.
//  Copyright © 2017 bychance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VaultManager.h"

typedef NS_ENUM(NSInteger, MergeCellDisplayMode) {
    MergeCellDisplayNew = 0,
    MergeCellDisplaySimilar,
};

@interface MergeInfo : NSObject

@property (nonatomic, assign) MergeCellDisplayMode displayMode;
@property (nonatomic, strong) PasswordInfo *passwordInfo;
@property (nonatomic, strong) PasswordInfo *similarPasswordInfo;

@end
