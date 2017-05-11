//
//  ImportViewController.m
//  MyPassword
//
//  Created by chance on 8/5/2017.
//  Copyright © 2017 bychance. All rights reserved.
//

#import "ImportViewController.h"
#import "SSZipArchive.h"
#import "VaultManager.h"

#define kLocalWidth self.view.bounds.size.width
#define kLocalHeight self.view.bounds.size.height

NSNotificationName const kDidFinishImportVaultNotification = @"kDidFinishImportVaultNotification";
NSNotificationName const kImportedVaultPathKey = @"kImportedVaultPathKey";

@interface ImportViewController ()<UITextFieldDelegate> {
    UIButton *_confirmButton;
    NSString *_unzipFilePath;
}

@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UILabel *accountNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *mergeButton;
@property (weak, nonatomic) IBOutlet UIButton *replaceButton;
@property (weak, nonatomic) IBOutlet UIButton *addButton;

@end


@implementation ImportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.accountNameLabel.text = [self.importFilePath lastPathComponent];
    self.mergeButton.alpha = 0;
    self.replaceButton.alpha = 0;
    self.addButton.alpha = 0;
    
    // setup file directory
    NSString *tempVault = GeneratePasswordUUID();
    NSError *error = nil;
    _unzipFilePath = [NSTemporaryDirectory() stringByAppendingFormat:@"/%@.%@", tempVault, kVaultExtension];
    BOOL isOK = [[NSFileManager defaultManager] createDirectoryAtPath:_unzipFilePath
                                          withIntermediateDirectories:YES
                                                           attributes:nil
                                                                error:&error];
    if (!isOK || error) {
        NSLog(@"Fail to create temp vault directory: %@", error);
    }
}


- (void)dealloc {
    NSLog(@"ImportViewController dealloc");
    // clean up temporary files
    [self cleanDirectory:NSTemporaryDirectory()];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.passwordTextField becomeFirstResponder];
}


- (IBAction)onFinishExport {
    [self cleanDirectory:NSTemporaryDirectory()];
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)onExportButtonClicked:(UIButton *)sender {
    [self onUnlockVaultFile];
}


- (BOOL)onUnlockVaultFile {
    if (!self.passwordTextField.text.length) {
        _passwordTextField.text = nil;
        // show fail animation
        [self showInputErrorBoundaryInView:self.passwordTextField];
        return NO;
    }
    
    NSError *error = nil;
    BOOL isOK = [SSZipArchive unzipFileAtPath:self.importFilePath
                                toDestination:_unzipFilePath
                                    overwrite:YES
                                     password:self.passwordTextField.text
                                        error:&error];
    if (!isOK || error) {
        NSLog(@"Fail to unzip temp vault: %@", error);
        [self showAlertMessage:@"Fail to unlock vault file, please try another password."];
        _unzipFilePath = nil;
        return NO;
    }
    
    NSString *vaultName = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultKey_DefaultVaultName];
    
    // show replace/merge ui
    [self.passwordTextField resignFirstResponder];
    [UIView animateWithDuration:0.3 animations:^{
        self.passwordTextField.alpha = 0;
        if (vaultName.length) {
            self.mergeButton.alpha = 1;
            self.replaceButton.alpha = 1;
            
        } else {
            self.addButton.alpha = 1;
        }
    }];
    
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


- (void)showAlertMessage:(NSString *)alertMessage {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confrimAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertController addAction:confrimAction];
    [self presentViewController:alertController animated:YES completion:nil];
}


// 清空目录下的文件
- (void)cleanDirectory:(NSString *)directoryPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *fileNames = [fileManager contentsOfDirectoryAtPath:directoryPath error:nil];
    for (NSString *fileName in fileNames) {
        NSString *filePath = [directoryPath stringByAppendingPathComponent:fileName];
        // delete file
        NSError *removeError = nil;
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&removeError];
        NSLog(@"Delete File: %@ %@", fileName, removeError ? removeError : @"OK");
    }
}


#pragma mark - Vault Processing
- (IBAction)onAddVault:(UIButton *)sender {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *destinatonPath = [documentPath stringByAppendingPathComponent:[self.importFilePath lastPathComponent]];
    NSError *error;
    BOOL isOK = [[NSFileManager defaultManager] moveItemAtPath:_unzipFilePath
                                                        toPath:destinatonPath
                                                         error:&error];
    NSLog(@"Add vault: %@", isOK ? @"OK" : error);
    if (!isOK || error) {
        [self showAlertMessage:@"Fail to add vault, please try again"];
        return;
    }
    
    NSDictionary *userInfo = @{kImportedVaultPathKey : destinatonPath};
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidFinishImportVaultNotification
                                                        object:nil
                                                      userInfo:userInfo];
    [self onFinishExport];
}


- (IBAction)onReplaceVault:(UIButton *)sender {
    
}


- (IBAction)onMergeVault:(UIButton *)sender {
    
}


#pragma mark - Text Field Delegate

- (UIView *)inputAccessoryView {
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _confirmButton.frame = CGRectMake(0, 0, kLocalWidth, 44);
        _confirmButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
        [_confirmButton setTitle:@"Unlock vault file" forState:UIControlStateNormal];
        [_confirmButton addTarget:self action:@selector(onExportButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        UIImage *btnBG = [UIImage imageNamed:@"rect_button"];
        [_confirmButton setBackgroundImage:btnBG forState:UIControlStateNormal];
        UIImage *hightlightedBG = [UIImage imageNamed:@"rect_button_clicked"];
        [_confirmButton setBackgroundImage:hightlightedBG forState:UIControlStateHighlighted];
        [_confirmButton setBackgroundImage:hightlightedBG forState:UIControlStateHighlighted];
    }
    return _confirmButton;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([self onUnlockVaultFile]) {
        [textField resignFirstResponder];
        return YES;
        
    } else {
        return NO;
    }
}


@end
