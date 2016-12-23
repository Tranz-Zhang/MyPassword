//
//  EditViewController.m
//  MyPassword
//
//  Created by chance on 12/16/16.
//  Copyright © 2016 bychance. All rights reserved.
//

#import "EditViewController.h"

@interface EditViewController ()

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextField *websiteTextField;
@property (weak, nonatomic) IBOutlet UITextField *accountTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (nonatomic, strong) PasswordItem *editingPassword;

@end


@implementation EditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.password) {
        self.editingPassword = [self.password copy];
        self.title = @"Edit";
        
    } else {
        self.title = @"Add";
        self.editingPassword = [PasswordItem new];
        // new uuid for password
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        NSString *uuidString = CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuidRef));
        CFRelease(uuidRef);
        uuidString = [[uuidString uppercaseString] stringByReplacingOccurrencesOfString:@"-" withString:@""];
        self.editingPassword.UUID = uuidString;
    }
    
    // update UI
    self.titleTextField.text = self.editingPassword.title;
    self.websiteTextField.text = self.editingPassword.website;
    self.accountTextField.text = self.editingPassword.account;
    self.passwordTextField.text = self.editingPassword.password;
}



- (IBAction)onDone:(id)sender {
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


- (IBAction)onCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


// check if current editing content is OK
- (BOOL)verifyEditingContent {
    return YES;
}


@end
