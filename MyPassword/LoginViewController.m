//
//  LoginViewController.m
//  MyPassword
//
//  Created by chance on 1/17/17.
//  Copyright © 2017 bychance. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end


@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.passwordTextField becomeFirstResponder];
}


- (IBAction)onUnlockButtonClicked:(UIButton *)sender {
    if ([_delegate respondsToSelector:@selector(loginViewControllerDidFinishLogin:)]) {
        [_delegate loginViewControllerDidFinishLogin:self];
    }
}


#pragma mark - Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([_delegate respondsToSelector:@selector(loginViewControllerDidFinishLogin:)]) {
        [_delegate loginViewControllerDidFinishLogin:self];
    }
    [textField resignFirstResponder];
    return YES;
}


@end



