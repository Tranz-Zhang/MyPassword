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

@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *itemTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *accountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *passwordBackgroundView;
@property (weak, nonatomic) IBOutlet UIButton *passwordButton;
@property (weak, nonatomic) IBOutlet UILabel *notesLabel;

@end


@implementation PasswordDetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self.passwordButton setTitle:@"{ ********** }" forState:UIControlStateNormal];
}


- (void)setPasswordInfo:(PasswordInfo *)passwordInfo {
    _passwordInfo = passwordInfo;
    self.itemTitleLabel.text = passwordInfo.title;
    self.accountLabel.text = passwordInfo.account;
    self.iconView.image = SmallIconImageWithType(passwordInfo.type);
    self.notesLabel.text = passwordInfo.notes;
    
    _isShowingPassword = NO;
    [self updatePasswordVisiablilty];
}


- (IBAction)onPasswordButtonClicked:(UIButton *)button {
    _isShowingPassword = !_isShowingPassword;
    [self updatePasswordVisiablilty];
}


- (void)updatePasswordVisiablilty {
    if (!self.passwordInfo.password.length) {
        NSString *title = NSLocalizedString(@"PasswordDetailCell.NoPassword", nil);
        [self.passwordButton setTitle:title forState:UIControlStateNormal];
        self.passwordButton.enabled = NO;
        return;
    }
    
    self.passwordButton.enabled = YES;
    if (_isShowingPassword) {
        [self.passwordButton setTitle:self.passwordInfo.password
                             forState:UIControlStateNormal];
        
    } else {
        NSString *originalPwd = self.passwordInfo.password;
        NSMutableString *hiddenPwd = [NSMutableString string];
        [hiddenPwd appendFormat:@"%c", (char)[originalPwd characterAtIndex:0]];
        [hiddenPwd appendString:@"********"];
        [hiddenPwd appendFormat:@"%c", (char)[originalPwd characterAtIndex:originalPwd.length - 1]];
        [self.passwordButton setTitle:[hiddenPwd copy]
                             forState:UIControlStateNormal];
        
    }
}


- (IBAction)onEditButtonClicked:(UIButton *)button {
    if ([_delegate respondsToSelector:@selector(passwordDetailCellDidClickEdit:)]) {
        [_delegate passwordDetailCellDidClickEdit:self];
    }
}



@end


