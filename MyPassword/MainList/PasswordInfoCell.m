//
//  PasswordInfoCell.m
//  MyPassword
//
//  Created by chance on 6/12/2016.
//  Copyright © 2016 bychance. All rights reserved.
//

#import "PasswordInfoCell.h"

@interface PasswordInfoCell ()

@property (weak, nonatomic) IBOutlet UILabel *itemTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconView;

@end


@implementation PasswordInfoCell


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setIndexInfo:(IndexInfo *)indexInfo {
    if (_indexInfo != indexInfo) {
        _indexInfo = indexInfo;
    }
    self.itemTitleLabel.text = indexInfo.title;
    self.iconView.image = SmallIconImageWithType(indexInfo.iconType);
}


@end
