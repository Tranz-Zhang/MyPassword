//
//  ImportViewController.m
//  MyPassword
//
//  Created by chance on 8/5/2017.
//  Copyright © 2017 bychance. All rights reserved.
//

#import "ImportViewController.h"
#import "MainViewController.h"
#import "MergeViewController.h"
#import "SSZipArchive.h"
#import "VaultManager.h"
#import "StoryboardLoader.h"

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
    
    VaultManager *importedVault = [[VaultManager alloc] initWithVaultPath:_unzipFilePath];
    if (![importedVault unlockWithPassword:self.passwordTextField.text]) {
        NSLog(@"Fail to unlock temp vault");
        [self showAlertMessage:@"Fail to unlock vault file, this vault has inconsistent password."];
        [[NSFileManager defaultManager] removeItemAtPath:_unzipFilePath error:nil];
        _unzipFilePath = nil;
        return NO;
    }
    
    NSString *vaultName = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultKey_DefaultVaultName];
    
    // show replace/merge ui
    [self.passwordTextField resignFirstResponder];
    [UIView animateWithDuration:0.3 animations:^{
        self.passwordTextField.alpha = 0;
        self.passwordTextField.userInteractionEnabled = NO;
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
    
    // post notifications
    NSString *vaultName = [[destinatonPath lastPathComponent] stringByDeletingPathExtension];
    [[NSUserDefaults standardUserDefaults] setObject:vaultName forKey:kUserDefaultKey_DefaultVaultName];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSDictionary *userInfo = @{kImportedVaultPathKey : destinatonPath};
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidFinishImportVaultNotification
                                                        object:nil
                                                      userInfo:userInfo];
    [self onFinishExport];
}


- (IBAction)onReplaceVault:(UIButton *)sender {
    NSString *currentVaultName = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultKey_DefaultVaultName];
    NSString *message = [NSString stringWithFormat:@"All your data in current vault \"%@\" will be deleted!", currentVaultName];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Do you want to replace current vault?" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confrimAction = [UIAlertAction actionWithTitle:@"Replace" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
        // do replace
        [self replaceCurrentVault];
    }];
    [alertController addAction:confrimAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}


- (void)replaceCurrentVault {
    // copy new vault
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *newVaultPath = [documentPath stringByAppendingPathComponent:[self.importFilePath lastPathComponent]];
    if ([fileManager fileExistsAtPath:newVaultPath]) {
        NSError *error;
        BOOL isOK = [fileManager removeItemAtPath:newVaultPath error:&error];
        NSLog(@"Remove duplicated vault: %@", isOK ? @"OK" : error);
    }
    NSError *error;
    BOOL isOK = [fileManager moveItemAtPath:_unzipFilePath toPath:newVaultPath error:&error];
    NSLog(@"Replace vault: %@", isOK ? @"OK" : error);
    if (!isOK || error) {
        [self showAlertMessage:@"Fail to replace current vault, please try again"];
        return;
    }

    // delete old vault
    NSString *oldVaultName = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultKey_DefaultVaultName];
    NSString *oldVaultPath = [documentPath stringByAppendingFormat:@"/%@.%@", oldVaultName, kVaultExtension];
    if ([fileManager fileExistsAtPath:oldVaultPath]) {
        NSError *error;
        BOOL isOK = [fileManager removeItemAtPath:oldVaultPath error:&error];
        NSLog(@"Remove old vault: %@", isOK ? @"OK" : error);
    }
    
    // post notifications
    NSString *newVaultName = [[newVaultPath lastPathComponent] stringByDeletingPathExtension];
    [[NSUserDefaults standardUserDefaults] setObject:newVaultName forKey:kUserDefaultKey_DefaultVaultName];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSDictionary *userInfo = @{kImportedVaultPathKey : newVaultPath};
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidFinishImportVaultNotification
                                                        object:nil
                                                      userInfo:userInfo];
    [self onFinishExport];
}


- (IBAction)onMergeVault:(UIButton *)sender {
    MainViewController *mainVC = (MainViewController *)[[[UIApplication sharedApplication].delegate window] rootViewController];
    if (!mainVC.vault) {
        [self showAlertMessage:@"Can not find current vault, please try replace vault."];
        return;
    }
    
    VaultManager *currentVault = mainVC.vault;
    if ([currentVault isLocked]) {
        // check if current vault is locked
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"You need to unlock current vault to continue merging" message:[NSString stringWithFormat:@"Enter password for vault: %@", currentVault.name] preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.secureTextEntry = YES;
        }];
        UIAlertAction *confrimAction = [UIAlertAction actionWithTitle:@"Unlock" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alertController dismissViewControllerAnimated:YES completion:nil];
            
            if (![currentVault unlockWithPassword:[alertController.textFields[0] text]]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showAlertMessage:[NSString stringWithFormat:@"Invalid password for vault: %@, please try again.", currentVault.name]];
                });
                
            } else {
                [self mergeWithVault:currentVault];
            }
        }];
        [alertController addAction:confrimAction];
        [self presentViewController:alertController animated:YES completion:nil];
    
    } else {
        [self mergeWithVault:currentVault];
    }
}


- (void)mergeWithVault:(VaultManager *)vault {
    NSLog(@"%s", __FUNCTION__);
    VaultManager *importedVault = [[VaultManager alloc] initWithVaultPath:_unzipFilePath];
    if (![importedVault unlockWithPassword:self.passwordTextField.text]) {
        NSLog(@"Fail to unlock temp vault");
        [self showAlertMessage:@"Fail to unlock vault file, this vault has inconsistent password."];
        [[NSFileManager defaultManager] removeItemAtPath:_unzipFilePath error:nil];
        _unzipFilePath = nil;
        return;
    }
    
    MergeViewController *mergeVC = [StoryboardLoader loadViewController:@"MergeViewController"
                                                           inStoryboard:@"Login"];
    mergeVC.originalVault = vault;
    mergeVC.mergingVault = importedVault;
    [self.navigationController pushViewController:mergeVC animated:YES];
}


- (void)showAlertMessage:(NSString *)alertMessage {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertMessage message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confrimAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertController addAction:confrimAction];
    [self presentViewController:alertController animated:YES completion:nil];
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
