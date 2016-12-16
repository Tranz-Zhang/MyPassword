//
//  PasswordDetailCell.m
//  MyPassword
//
//  Created by chance on 12/16/16.
//  Copyright © 2016 bychance. All rights reserved.
//

#import "PasswordDetailCell.h"

@interface PasswordDetailCell () {
    BOOL _isShowingPassword;
}

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailView;
@property (weak, nonatomic) IBOutlet UILabel *itemTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *accountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *passwordBackgroundView;
@property (weak, nonatomic) IBOutlet UIButton *passwordButton;

@end


@implementation PasswordDetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    UIImage *bgImage = [[UIImage imageNamed:@"default_button_bg"] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
    self.passwordBackgroundView.image = bgImage;
    [self.passwordButton setTitle:@"{ ********** }" forState:UIControlStateNormal];
}


- (IBAction)onPasswordButtonClicked:(UIButton *)button {
    if (_isShowingPassword) {
        _isShowingPassword = NO;
        [button setTitle:@"{ ********** }" forState:UIControlStateNormal];
        
    } else {
        _isShowingPassword = YES;
        [button setTitle:@"XXXXXXXXXX" forState:UIControlStateNormal];
    }
    
}


- (IBAction)onEditButtonClicked:(UIButton *)button {
    if ([_delegate respondsToSelector:@selector(passwordDetailCellDidClickEdit:)]) {
        [_delegate passwordDetailCellDidClickEdit:self];
    }
}



@end


