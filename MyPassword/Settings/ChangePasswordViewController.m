//
//  ChangePasswordViewController.m
//  MyPassword
//
//  Created by chance on 26/5/2017.
//  Copyright © 2017 bychance. All rights reserved.
//

#import "ChangePasswordViewController.h"

#define kLocalWidth self.view.bounds.size.width
#define kLocalHeight self.view.bounds.size.height

NSNotificationName const kDidChangedPasswordNotification = @"kDidChangedPasswordNotification";

@interface ChangePasswordViewController () {
    UIButton *_confirmButton;
}

@property (weak, nonatomic) IBOutlet UIView *infoContentView;
@property (weak, nonatomic) IBOutlet UITextField *currentPasswordField;
@property (weak, nonatomic) IBOutlet UITextField *newilyPasswordField;
@property (weak, nonatomic) IBOutlet UITextField *confirmNewPasswordField;

@end

@implementation ChangePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *paddingView0 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    self.currentPasswordField.leftView = paddingView0;
    self.currentPasswordField.leftViewMode = UITextFieldViewModeAlways;
    UIView *paddingView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    self.newilyPasswordField.leftView = paddingView1;
    self.newilyPasswordField.leftViewMode = UITextFieldViewModeAlways;
    UIView *paddingView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    self.confirmNewPasswordField.leftView = paddingView2;
    self.confirmNewPasswordField.leftViewMode = UITextFieldViewModeAlways;
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.currentPasswordField becomeFirstResponder];
}


- (UIView *)inputAccessoryView {
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _confirmButton.frame = CGRectMake(0, 0, kLocalWidth, 44);
        _confirmButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
        NSString *title = NSLocalizedString(@"ChangePassword.KeyboardButton", nil);
        [_confirmButton setTitle:title forState:UIControlStateNormal];
        [_confirmButton addTarget:self action:@selector(onConfirmButtonClick) forControlEvents:UIControlEventTouchUpInside];
        UIImage *btnBG = [UIImage imageNamed:@"rect_button"];
        [_confirmButton setBackgroundImage:btnBG forState:UIControlStateNormal];
        UIImage *hightlightedBG = [UIImage imageNamed:@"rect_button_clicked"];
        [_confirmButton setBackgroundImage:hightlightedBG forState:UIControlStateHighlighted];
        [_confirmButton setBackgroundImage:hightlightedBG forState:UIControlStateHighlighted];
    }
    return _confirmButton;
}


- (void)onConfirmButtonClick {
    [self onChangePassword];
}


- (void)onChangePassword {
    if (!self.vault) {
        [self showAlertWithTitle:NSLocalizedString(@"ChangePassword.AlertTitle.NoVault", nil)
                         message:NSLocalizedString(@"ChangePassword.AlertMessage.NoVault", nil)];
        return;
    }
    
    NSLog(@"%s", __FUNCTION__);
    if (!self.currentPasswordField.text.length) {
        [self showInputErrorBoundaryInView:self.currentPasswordField];
        return;
    }
    
    if (!self.newilyPasswordField.text.length) {
        [self showInputErrorBoundaryInView:self.newilyPasswordField];
        return;
    }
    if (![self.confirmNewPasswordField.text isEqualToString:self.newilyPasswordField.text]) {
        [self showInputErrorBoundaryInView:self.confirmNewPasswordField];
        return;
    }
    
    // verify current password
    if (![self.vault verifyPassword:self.currentPasswordField.text]) {
        [self showAlertWithTitle:NSLocalizedString(@"ChangePassword.AlertTitle.WrongPassword", nil)
                         message:NSLocalizedString(@"ChangePassword.AlertMessage.WrongPassword", nil)];
        return;
    }
    
    // verify same password
    if ([self.currentPasswordField.text isEqualToString:self.newilyPasswordField.text]) {
        [self showAlertWithTitle:NSLocalizedString(@"ChangePassword.AlertTitle.SamePassword", nil)
                         message:NSLocalizedString(@"ChangePassword.AlertMessage.SamePassword", nil)];
        return;
    }
    
    // change password
    if ([self.vault changePassword:self.newilyPasswordField.text]) {
        // post notification
        [self.confirmNewPasswordField resignFirstResponder];
        [self.newilyPasswordField resignFirstResponder];
        [self.currentPasswordField resignFirstResponder];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kDidChangedPasswordNotification object:nil];
        
    } else {
        [self showAlertWithTitle:NSLocalizedString(@"ChangePassword.AlertTitle.FailToChange", nil)
                         message:NSLocalizedString(@"ChangePassword.AlertMessage.FailToChange", nil)];
    }
}


- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    NSString *buttonTitle = NSLocalizedString(@"ChangePassword.AlertButton", nil);
    UIAlertAction *confrimAction = [UIAlertAction actionWithTitle:buttonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertController addAction:confrimAction];
    [self presentViewController:alertController animated:YES completion:nil];
}


- (void)showInputErrorBoundaryInView:(UIView *)view {
    UIImageView *errorView = [[UIImageView alloc] initWithFrame:view.frame];
    errorView.image = [UIImage imageNamed:@"input_boundary_error"];
    [self.infoContentView addSubview:errorView];
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.currentPasswordField) {
        [self.newilyPasswordField becomeFirstResponder];
        
    } else if (textField == self.newilyPasswordField) {
        [self.confirmNewPasswordField becomeFirstResponder];
        
    } else if (textField == self.confirmNewPasswordField) {
        [self onChangePassword];
    }
    return YES;
}


- (IBAction)onConfirmTextFieldChanged:(UITextField *)sender {
    if (!self.newilyPasswordField.text.length) {
        return;
    }
    if ([self.newilyPasswordField.text isEqualToString:self.confirmNewPasswordField.text]) {
        self.confirmNewPasswordField.background = [UIImage imageNamed:@"input_boundary_green"];
        
    } else {
        self.confirmNewPasswordField.background = [UIImage imageNamed:@"input_boundary"];
    }
}



@end


