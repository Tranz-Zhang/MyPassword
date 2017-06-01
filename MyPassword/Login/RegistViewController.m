//
//  RegistViewController.m
//  MyPassword
//
//  Created by chance on 1/18/17.
//  Copyright © 2017 bychance. All rights reserved.
//

#import "RegistViewController.h"

#define kLocalWidth self.view.bounds.size.width
#define kLocalHeight self.view.bounds.size.height

@interface RegistViewController () <UITextFieldDelegate> {
    UIButton *_confirmButton;
}

@property (weak, nonatomic) IBOutlet UITextField *accountTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextFiled;
@property (weak, nonatomic) IBOutlet UIView *infoContentView;
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UIButton *showButton;


@end

@implementation RegistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // add padding to text field
    UIView *paddingView0 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    self.accountTextField.leftView = paddingView0;
    self.accountTextField.leftViewMode = UITextFieldViewModeAlways;
    UIView *paddingView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    self.passwordTextField.leftView = paddingView1;
    self.passwordTextField.leftViewMode = UITextFieldViewModeAlways;
    UIView *paddingView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    self.confirmPasswordTextFiled.leftView = paddingView2;
    self.confirmPasswordTextFiled.leftViewMode = UITextFieldViewModeAlways;
    
    // start up ui
    self.infoContentView.alpha = 0;
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}


- (void)dealloc {
    NSLog(@"RegistViewController dealloc");
}


- (IBAction)onShowRegistInfoView:(UIButton *)sender {
    [UIView animateWithDuration:0.3 animations:^{
        self.infoContentView.alpha = 1;
        self.iconView.alpha = 0;
        self.showButton.alpha = 0;
        
    } completion:^(BOOL finished) {
        self.iconView.hidden = YES;
        self.showButton.hidden = YES;
    }];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.accountTextField becomeFirstResponder];
}


- (UIView *)inputAccessoryView {
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _confirmButton.frame = CGRectMake(0, 0, kLocalWidth, 44);
        _confirmButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
        NSString *buttonTitle = NSLocalizedString(@"Regist.KeyboardButton", nil);
        [_confirmButton setTitle:buttonTitle forState:UIControlStateNormal];
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
    [self onCreateVault];
}


- (BOOL)onCreateVault {
    NSLog(@"onCreateVault");
    if (!self.accountTextField.text.length) {
        [self showInputErrorBoundaryInView:self.accountTextField];
        return NO;
    }
    if (!self.passwordTextField.text.length) {
        [self showInputErrorBoundaryInView:self.passwordTextField];
        return NO;
    }
    if (![self.confirmPasswordTextFiled.text isEqualToString:self.passwordTextField.text]) {
        [self showInputErrorBoundaryInView:self.confirmPasswordTextFiled];
        return NO;
    }
    
    [_accountTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
    [_confirmPasswordTextFiled resignFirstResponder];
    
    if ([self.delegate respondsToSelector:@selector(registViewController:didCreateAccount:password:)]) {
        [self.delegate registViewController:self
                           didCreateAccount:self.accountTextField.text
                                   password:self.passwordTextField.text];
    }
    
    return YES;
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
    if (textField == _accountTextField) {
        [self.passwordTextField becomeFirstResponder];
        
    } else if (textField == self.passwordTextField) {
        [self.confirmPasswordTextFiled becomeFirstResponder];
        
    } else if (textField == self.confirmPasswordTextFiled) {
        [self onCreateVault];
    }
    return YES;
}


- (IBAction)onConfirmTextFieldChanged:(UITextField *)sender {
    if (!self.passwordTextField.text.length) {
        return;
    }
    if ([self.passwordTextField.text isEqualToString:self.confirmPasswordTextFiled.text]) {
        self.confirmPasswordTextFiled.background = [UIImage imageNamed:@"input_boundary_green"];
        
    } else {
        self.confirmPasswordTextFiled.background = [UIImage imageNamed:@"input_boundary"];
    }
}



@end




