//
//  MergeInfoCell.h
//  MyPassword
//
//  Created by chance on 12/5/2017.
//  Copyright © 2017 bychance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PasswordInfo.h"

@interface MergeInfoCell : UITableViewCell

@property (nonatomic, strong) PasswordInfo *passwordInfo;
@property (nonatomic, assign) BOOL isNew;

@end
