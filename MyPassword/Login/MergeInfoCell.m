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
@property (weak, nonatomic) IBOutlet UIImageView *passwordBackgroundView;
@property (weak, nonatomic) IBOutlet UIButton *passwordButton;
@property (weak, nonatomic) IBOutlet UIImageView *newlyMarkView;
@property (weak, nonatomic) IBOutlet UILabel *notesLabel;

@end


@implementation MergeInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self.passwordButton setTitle:@"{ ********** }" forState:UIControlStateNormal];
}


- (void)setPasswordInfo:(PasswordInfo *)passwordInfo {
    _passwordInfo = passwordInfo;
    self.itemTitleLabel.text = passwordInfo.title;
    self.accountLabel.text = passwordInfo.account;
    self.iconView.image = SmallIconImageWithType(passwordInfo.iconType);
    self.notesLabel.text = passwordInfo.notes;
    
    _isShowingPassword = NO;
    [self updatePasswordVisiablilty];
}


- (void)setIsNew:(BOOL)isNew {
    _isNew = isNew;
    self.newlyMarkView.hidden = !isNew;
    self.backgroundColor = isNew ? [UIColor whiteColor] : [UIColor colorWithWhite:0.97 alpha:1];
}


- (IBAction)onPasswordButtonClicked:(UIButton *)button {
    _isShowingPassword = !_isShowingPassword;
    [self updatePasswordVisiablilty];
}


- (void)updatePasswordVisiablilty {
    if (!self.passwordInfo.password.length) {
        [self.passwordButton setTitle:@"{ NO PASSWORD }" forState:UIControlStateNormal];
        self.passwordButton.enabled = NO;
        return;
    }
    
    self.passwordButton.enabled = YES;
    if (_isShowingPassword) {
        [self.passwordButton setTitle:self.passwordInfo.password
                             forState:UIControlStateNormal];
        
    } else {
        NSString *originalPwd = self.passwordInfo.password;
        NSMutableString *hiddenPwd = [NSMutableString stringWithString:@"{ "];
        [hiddenPwd appendFormat:@"%c", (char)[originalPwd characterAtIndex:0]];
        [hiddenPwd appendString:@"********"];
        [hiddenPwd appendFormat:@"%c", (char)[originalPwd characterAtIndex:originalPwd.length - 1]];
        [hiddenPwd appendString:@" }"];
        [self.passwordButton setTitle:[hiddenPwd copy]
                             forState:UIControlStateNormal];
        
    }
}

@end


