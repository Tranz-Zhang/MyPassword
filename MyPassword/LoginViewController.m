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


- (BOOL)checkPassword {
    if (!_vault) {
        NSLog(@"Error: no vault!");
        return NO;
    }
    
    BOOL unlocked = [_vault unlockWithPassword:_passwordTextField.text];
    if (!unlocked) {
        _passwordTextField.text = nil;
        // show fail animation
        return NO;
    }
    
    if ([_delegate respondsToSelector:@selector(loginViewControllerDidFinishLogin:)]) {
        [_delegate loginViewControllerDidFinishLogin:self];
    }
    return YES;
}


- (IBAction)onUnlockButtonClicked:(UIButton *)sender {
    [self checkPassword];
}


#pragma mark - Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([self checkPassword]) {
        [textField resignFirstResponder];
        return YES;
        
    } else {
        return NO;
    }
}


@end



