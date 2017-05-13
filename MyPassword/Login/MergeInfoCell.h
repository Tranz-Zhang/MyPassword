//
//  MergeInfoCell.h
//  MyPassword
//
//  Created by chance on 12/5/2017.
//  Copyright © 2017 bychance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MergeInfo.h"


@protocol MergeInfoCellDelegate;
@interface MergeInfoCell : UITableViewCell

@property (nonatomic, strong) MergeInfo *mergeInfo;
@property (nonatomic, weak) id<MergeInfoCellDelegate> delegate;

@end


@protocol MergeInfoCellDelegate <NSObject>

- (void)mergeInfoCell:(MergeInfoCell *)cell didChangeDisplayMode:(MergeCellDisplayMode)displayMode;

@end
