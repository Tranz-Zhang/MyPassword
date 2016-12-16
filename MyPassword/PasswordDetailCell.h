//
//  PasswordDetailCell.h
//  MyPassword
//
//  Created by chance on 12/16/16.
//  Copyright © 2016 bychance. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PasswordDetailCellDelegate;
@interface PasswordDetailCell : UITableViewCell

@property (nonatomic, weak) id<PasswordDetailCellDelegate> delegate;

@end


@protocol PasswordDetailCellDelegate <NSObject>

- (void)passwordDetailCellDidClickEdit:(PasswordDetailCell *)cell;

@end


