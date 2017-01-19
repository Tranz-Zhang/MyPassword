//
//  PasswordDetailCell.h
//  MyPassword
//
//  Created by chance on 12/16/16.
//  Copyright © 2016 bychance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PasswordInfo.h"

@protocol PasswordDetailCellDelegate;
@interface PasswordDetailCell : UITableViewCell

@property (nonatomic, strong) PasswordInfo *passwordInfo;
@property (nonatomic, weak) id<PasswordDetailCellDelegate> delegate;

@end


@protocol PasswordDetailCellDelegate <NSObject>

- (void)passwordDetailCellDidClickEdit:(PasswordDetailCell *)cell;

@end


