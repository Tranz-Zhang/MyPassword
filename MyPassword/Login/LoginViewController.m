//
//  LoginViewController.m
//  MyPassword
//
//  Created by chance on 1/17/17.
//  Copyright © 2017 bychance. All rights reserved.
//

#import "LoginViewController.h"

#define kLocalWidth self.view.bounds.size.width
#define kLocalHeight self.view.bounds.size.height

@interface LoginViewController ()<UITextFieldDelegate> {
    UIButton *_confirmButton;
}

@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UILabel *accountNameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconCenterYConstraint;

@end


@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.accountNameLabel.text = self.accountName;
}


- (void)dealloc {
    NSLog(@"LoginViewController dealloc");
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.passwordTextField becomeFirstResponder];
        [UIView animateWithDuration:0.3 animations:^{
            self.iconCenterYConstraint.constant = -120;
            [self.view layoutIfNeeded];
        }];
    });
}


- (void)setAccountName:(NSString *)accountName {
    if (_accountName != accountName) {
        _accountName = accountName;
        self.accountNameLabel.text = accountName;
    }
}


- (void)onUnlockButtonClicked:(UIButton *)sender {
    [self checkPassword];
}


- (BOOL)checkPassword {
    if (!_vault) {
        NSLog(@"Error: no vault!");
        return NO;
    }
    
    BOOL unlocked = [_vault unlockWithPassword:_passwordTextField.text];
    if (!unlocked) {
        _passwordTextField.text = nil;
        // show fail animation
        [self showInputErrorBoundaryInView:self.passwordTextField];
        return NO;
    }
    
    if ([_delegate respondsToSelector:@selector(loginViewControllerDidFinishLogin:)]) {
        [_delegate loginViewControllerDidFinishLogin:self];
    }
    return YES;
}


- (void)showInputErrorBoundaryInView:(UIView *)view {
    UIImageView *errorView = [[UIImageView alloc] initWithFrame:view.frame];
    errorView.image = [UIImage imageNamed:@"input_boundary_error"];
    [self.view addSubview:errorView];
    errorView.alpha = 0;
    
    [UIView animateWithDuration:0.5 animations:^{
        errorView.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 animations:^{
            errorView.alpha = 0;
        } completion:^(BOOL finished) {
            [errorView removeFromSuperview];
        }];
    }];
    
}


#pragma mark - Text Field Delegate

- (UIView *)inputAccessoryView {
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _confirmButton.frame = CGRectMake(0, 0, kLocalWidth, 44);
        _confirmButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
        [_confirmButton setTitle:@"Unlock" forState:UIControlStateNormal];
        [_confirmButton addTarget:self action:@selector(onUnlockButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        UIImage *btnBG = [UIImage imageNamed:@"rect_button"];
        [_confirmButton setBackgroundImage:btnBG forState:UIControlStateNormal];
        UIImage *hightlightedBG = [UIImage imageNamed:@"rect_button_clicked"];
        [_confirmButton setBackgroundImage:hightlightedBG forState:UIControlStateHighlighted];
        [_confirmButton setBackgroundImage:hightlightedBG forState:UIControlStateHighlighted];
    }
    return _confirmButton;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([self checkPassword]) {
        [textField resignFirstResponder];
        return YES;
        
    } else {
        return NO;
    }
}


@end



