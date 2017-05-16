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
@property (weak, nonatomic) IBOutlet UILabel *similarTagLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topBarHeight;


@end


@implementation MergeInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
}


- (void)setMergeInfo:(MergeInfo *)mergeInfo {
    _mergeInfo = mergeInfo;
    BOOL isNew = mergeInfo.displayMode == MergeCellDisplayNew;
    PasswordInfo *displayInfo = isNew ? mergeInfo.passwordInfo : mergeInfo.similarPasswordInfo;
    self.itemTitleLabel.text = displayInfo.title;
    self.accountLabel.text = [NSString stringWithFormat:@"Account: %@", displayInfo.account];
    self.passwordLabel.text = [NSString stringWithFormat:@"Password: %@", displayInfo.password];
    self.iconView.image = SmallIconImageWithType(displayInfo.iconType);
    self.notesLabel.text = [NSString stringWithFormat:@"Notes: %@", displayInfo.notes];
    self.changeModeButton.hidden = (mergeInfo.similarPasswordInfo == nil);
    self.similarTagLabel.hidden = isNew;
    self.backgroundColor = isNew ? [UIColor whiteColor] : [UIColor colorWithWhite:0.95 alpha:1];
    
    // highlight changed content label
    self.accountLabel.highlighted = !isNew && ![mergeInfo.passwordInfo.account isEqualToString:mergeInfo.similarPasswordInfo.account];
    self.passwordLabel.highlighted = !isNew && ![mergeInfo.passwordInfo.password isEqualToString:mergeInfo.similarPasswordInfo.password];
    self.notesLabel.highlighted = !isNew && ![mergeInfo.passwordInfo.notes isEqualToString:mergeInfo.similarPasswordInfo.notes];
    self.topBarHeight.constant = isNew ? 0 : 26;
    UIImage *iconImage = isNew ? [UIImage imageNamed:@"merge_cell_approx_icon"] : [UIImage imageNamed:@"merge_cell_back_icon"];
    [self.changeModeButton setImage:[iconImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    UIImage *highlightedIconImage = isNew ? [UIImage imageNamed:@"merge_cell_approx_icon_clicked"] : [UIImage imageNamed:@"merge_cell_back_icon_clicked"];
    [self.changeModeButton setImage:highlightedIconImage
                           forState:UIControlStateHighlighted];
}


- (IBAction)onChangeDisplayMode:(UIButton *)button {
    MergeCellDisplayMode mode = self.mergeInfo.displayMode == MergeCellDisplayNew ? MergeCellDisplaySimilar : MergeCellDisplayNew;
    self.mergeInfo.displayMode = mode;
    if ([self.delegate respondsToSelector:@selector(mergeInfoCell:didChangeDisplayMode:)]) {
        [self.delegate mergeInfoCell:self didChangeDisplayMode:mode];
    }
}



@end


