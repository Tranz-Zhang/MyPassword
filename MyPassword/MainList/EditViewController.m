//
//  EditViewController.m
//  MyPassword
//
//  Created by chance on 12/16/16.
//  Copyright © 2016 bychance. All rights reserved.
//

#import "EditViewController.h"

#define kVisiableExpansion 30

@interface EditViewController ()<UITextFieldDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *scrollContentView;

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextField *accountTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *iconView;
@property (weak, nonatomic) IBOutlet UITextView *notesTextView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewHeight;

@property (nonatomic, strong) PasswordInfo *editingPassword;
@property (nonatomic, weak) UIControl *editingTextView;
@property (weak, nonatomic) IBOutlet UIView *styleView;

@end


@implementation EditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // setup UI
    self.titleTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    self.titleTextField.leftViewMode = UITextFieldViewModeAlways;
    self.accountTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    self.accountTextField.leftViewMode = UITextFieldViewModeAlways;
    self.passwordTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    self.passwordTextField.leftViewMode = UITextFieldViewModeAlways;
    
    // update UI
    if (self.password) {
        self.titleTextField.text = self.password.title;
        self.accountTextField.text = self.password.account;
        self.passwordTextField.text = self.password.password;
        self.notesTextView.text = self.password.notes;
        self.iconView.tag = self.password.type;
        [self changeStyleWithPasswordType:self.password.type];
        
    } else {
        [self.titleTextField becomeFirstResponder];
    }
    
    // add notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardWillChangeFrameNotification:) name:UIKeyboardWillChangeFrameNotification object:nil];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.password) {
        [self changeStyleWithPasswordType:PasswordTypeLogin];
    }
}


- (void)changeStyleWithPasswordType:(PasswordType)type {
    // update title
    CATransition *fadeTextAnimation = [CATransition animation];
    fadeTextAnimation.duration = 0.3;
    fadeTextAnimation.type = kCATransitionFade;
    [self.navigationController.navigationBar.layer addAnimation:fadeTextAnimation
                                                         forKey:@"fadeText"];
    switch (type) {
        case PasswordTypeLogin:
            self.navigationItem.title = @"Login Info";
            break;
        case PasswordTypeCreditCard:
            self.navigationItem.title = @"Credit Card Info";
            break;
        case PasswordTypeOthers:
            self.navigationItem.title = @"Other Info";
            break;
        default:
            self.navigationItem.title = self.password ? @"Edit" : @"Add";
            break;
    }
    
    [UIView transitionWithView:self.iconView duration:0.4 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
        UIColor *styleColor = StyleColorWithType(type);
        self.styleView.backgroundColor = styleColor;
        [self.iconView setBackgroundImage:IconImageWithType(type)
                                 forState:UIControlStateNormal];
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : styleColor}];
    } completion:nil];
}


- (void)onKeyboardWillChangeFrameNotification:(NSNotification *)notification {
    NSLog(@"%s", __FUNCTION__);
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if (self.scrollViewHeight.constant != -keyboardFrame.size.height) {
        self.scrollViewHeight.constant = -keyboardFrame.size.height;
        [self.view setNeedsLayout];
        NSLog(@"%@", notification);
    }
}


- (IBAction)onDone:(id)sender {
    if (![self verifyEditingContent]) {
        return;
    }
    PasswordInfo *editingPassword = self.password ?: [PasswordInfo new];
    editingPassword.title = self.titleTextField.text;
    editingPassword.account = self.accountTextField.text;
    editingPassword.password = self.passwordTextField.text;
    editingPassword.notes = self.notesTextView.text;
    editingPassword.type = self.iconView.tag;
    
    if (self.password) {
        editingPassword.updatedDate = [[NSDate date] timeIntervalSince1970];
        if ([self.delegate respondsToSelector:@selector(editViewController:didUpdatePassword:)]) {
            [self.delegate editViewController:self didUpdatePassword:editingPassword];
        }
        
    } else {
        editingPassword.createdDate = [[NSDate date] timeIntervalSince1970];
        editingPassword.updatedDate = editingPassword.createdDate;
        if ([self.delegate respondsToSelector:@selector(editViewController:didAddPassword:)]) {
            [self.delegate editViewController:self didAddPassword:editingPassword];
        }
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)onCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


// check if current editing content is OK
- (BOOL)verifyEditingContent {
    if (!self.titleTextField.text.length) {
        [self showInputErrorBoundaryInView:self.titleTextField];
        return NO;
    }
    if (!self.accountTextField.text.length) {
        [self showInputErrorBoundaryInView:self.accountTextField];
        return NO;
    }
    if (!self.passwordTextField.text.length) {
        [self showInputErrorBoundaryInView:self.passwordTextField];
        return NO;
    }
    
    return YES;
}


- (void)showInputErrorBoundaryInView:(UIView *)view {
    UIImageView *errorView = [[UIImageView alloc] initWithFrame:view.frame];
    errorView.image = [UIImage imageNamed:@"input_boundary_error"];
    [self.scrollContentView addSubview:errorView];
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


- (IBAction)onIconViewClick:(UIButton *)button {
    PasswordType nextPasswordType = (button.tag + 1) % PasswordTypeCount;
    button.tag = nextPasswordType;
    [self changeStyleWithPasswordType:nextPasswordType];
}


#pragma mark - Text Field Delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CGRect visiableRect = CGRectInset(textField.frame, 0, -kVisiableExpansion);
        [self.scrollView scrollRectToVisible:visiableRect
                                    animated:YES];
    });
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    UIView *activatedTextField = nil;
    if (textField == self.titleTextField) {
        activatedTextField = self.accountTextField;
        
    } else if (textField == self.accountTextField) {
        activatedTextField = self.passwordTextField;
        
    } else if (textField == self.passwordTextField) {
        activatedTextField = self.notesTextView;
    }
    [activatedTextField becomeFirstResponder];
    CGRect visiableRect = CGRectInset(activatedTextField.frame, 0, -kVisiableExpansion);
    [self.scrollView scrollRectToVisible:visiableRect
                                animated:YES];
    return YES;
}


-(void)textViewDidBeginEditing:(UITextView *)textView {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CGRect visiableRect = CGRectInset(textView.frame, 0, -kVisiableExpansion);
        [self.scrollView scrollRectToVisible:visiableRect
                                    animated:YES];
    });
}


- (void)updateEditingPosition {
    NSArray *textFields = @[self.titleTextField, self.accountTextField, self.passwordTextField, self.notesTextView];
    for (UIControl *textField in textFields) {
        if (textField.isFirstResponder) {
            [self.scrollView scrollRectToVisible:textField.frame
                                        animated:YES];
            break;
        }
    }
}


@end






