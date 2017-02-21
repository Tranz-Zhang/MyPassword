//
//  EditViewController.m
//  MyPassword
//
//  Created by chance on 12/16/16.
//  Copyright © 2016 bychance. All rights reserved.
//

#import "EditViewController.h"
#import "IconManager.h"

@interface EditViewController ()

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextField *accountTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *websiteTextField;


@property (weak, nonatomic) IBOutlet UIView *iconContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UISwitch *iconSwitch;


@property (nonatomic, strong) PasswordInfo *editingPassword;

@end


@implementation EditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.password) {
        self.editingPassword = [self.password copy];
        self.title = @"Edit";
        
    } else {
        self.title = @"Add";
        self.editingPassword = [PasswordInfo new];
        // new uuid for password
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        NSString *uuidString = CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuidRef));
        CFRelease(uuidRef);
        uuidString = [[uuidString uppercaseString] stringByReplacingOccurrencesOfString:@"-" withString:@""];
        self.editingPassword.UUID = uuidString;
    }
    
    // update UI
    UIView *paddingView0 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    self.titleTextField.leftView = paddingView0;
    self.titleTextField.leftViewMode = UITextFieldViewModeAlways;
    UIView *paddingView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    self.accountTextField.leftView = paddingView1;
    self.accountTextField.leftViewMode = UITextFieldViewModeAlways;
    UIView *paddingView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    self.passwordTextField.leftView = paddingView2;
    self.passwordTextField.leftViewMode = UITextFieldViewModeAlways;
    UIView *paddingView3 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    self.websiteTextField.leftView = paddingView3;
    self.websiteTextField.leftViewMode = UITextFieldViewModeAlways;
    self.iconContainerView.alpha = 0;
    
    // update content
    self.titleTextField.text = self.editingPassword.title;
    self.accountTextField.text = self.editingPassword.account;
    self.passwordTextField.text = self.editingPassword.password;
    self.websiteTextField.text = self.editingPassword.website;
    
    //    [[IconManager shareManager] fetchIconWithURLString:@"www.taobao.com" completion:^(UIImage *iconImage) {
    //        dispatch_async(dispatch_get_main_queue(), ^{
    //            self.iconView.image = iconImage;
    //        });
    //    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    if (!self.titleTextField.text) {
//        [self.titleTextField becomeFirstResponder];
//    }
    [self.titleTextField becomeFirstResponder];
}


- (IBAction)onDone:(id)sender {
    [self onFinishEditing];
}


- (IBAction)onCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.google.com/favicon.ico"]];
    NSURLSessionDataTask *task = [urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"");
        
        UIImage *image = [UIImage imageWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.iconView.image = image;
        });
        
    }];
    [task resume];
}


- (void)onFinishEditing {
    if (![self verifyEditingContent]) {
        return;
    }
    
    self.editingPassword.title = self.titleTextField.text;
    self.editingPassword.website = self.websiteTextField.text;
    self.editingPassword.account = self.accountTextField.text;
    self.editingPassword.password = self.passwordTextField.text;
    
    if (self.password) {
        self.editingPassword.updatedDate = [[NSDate date] timeIntervalSince1970];
        if ([self.delegate respondsToSelector:@selector(editViewController:didUpdatePassword:)]) {
            [self.delegate editViewController:self didUpdatePassword:self.editingPassword];
        }
        
    } else {
        self.editingPassword.createdDate = [[NSDate date] timeIntervalSince1970];
        self.editingPassword.updatedDate = self.editingPassword.createdDate;
        if ([self.delegate respondsToSelector:@selector(editViewController:didAddPassword:)]) {
            [self.delegate editViewController:self didAddPassword:self.editingPassword];
        }
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


// check if current editing content is OK
- (BOOL)verifyEditingContent {
    return YES;
}


- (void)refreshIconView {
    
}


#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.titleTextField) {
        [self.accountTextField becomeFirstResponder];
        
    } else if (textField == self.accountTextField) {
        [self.passwordTextField becomeFirstResponder];
        
    } else if (textField == self.passwordTextField) {
        [self.websiteTextField becomeFirstResponder];
        
    } else {
        [self.websiteTextField resignFirstResponder];
        [self refreshIconView];
    }
    return YES;
}

@end






