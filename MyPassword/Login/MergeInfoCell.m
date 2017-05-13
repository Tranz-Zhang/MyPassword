//
//  MergeInfoCell.m
//  MyPassword
//
//  Created by chance on 12/5/2017.
//  Copyright © 2017 bychance. All rights reserved.
//

#import "MergeInfoCell.h"


@interface MergeInfoCell () {
    BOOL _isShowingPassword;
}

@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *itemTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *accountLabel;
@property (weak, nonatomic) IBOutlet UILabel *passwordLabel;
@property (weak, nonatomic) IBOutlet UILabel *notesLabel;
@property (weak, nonatomic) IBOutlet UIButton *changeModeButton;


@end


@implementation MergeInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
}


- (void)setMergeInfo:(MergeInfo *)mergeInfo {
    _mergeInfo = mergeInfo;
    PasswordInfo *displayInfo = mergeInfo.displayMode == MergeCellDisplayNew ? mergeInfo.passwordInfo : mergeInfo.similarPasswordInfo;
    self.itemTitleLabel.text = displayInfo.title;
    self.accountLabel.text = [NSString stringWithFormat:@"Account: %@", displayInfo.account];
    self.passwordLabel.text = [NSString stringWithFormat:@"Password: %@", displayInfo.password];
    self.iconView.image = SmallIconImageWithType(displayInfo.iconType);
    self.notesLabel.text = [NSString stringWithFormat:@"Notes: %@", displayInfo.notes];
    self.changeModeButton.hidden = (mergeInfo.similarPasswordInfo == nil);
}


- (IBAction)onChangeDisplayMode:(UIButton *)sender {
    MergeCellDisplayMode mode = self.mergeInfo.displayMode == MergeCellDisplayNew ? MergeCellDisplaySimilar : MergeCellDisplayNew;
    self.mergeInfo.displayMode = mode;
    if ([self.delegate respondsToSelector:@selector(mergeInfoCell:didChangeDisplayMode:)]) {
        [self.delegate mergeInfoCell:self didChangeDisplayMode:mode];
    }
}



@end


