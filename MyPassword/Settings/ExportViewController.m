//
//  ExportViewController.m
//  MyPassword
//
//  Created by chance on 8/5/2017.
//  Copyright © 2017 bychance. All rights reserved.
//

#import "ExportViewController.h"
#import "SSZipArchive.h"


#define kLocalWidth self.view.bounds.size.width
#define kLocalHeight self.view.bounds.size.height

@interface ExportViewController ()<UITextFieldDelegate> {
    UIButton *_confirmButton;
}

@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UILabel *accountNameLabel;

@end


@implementation ExportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.accountNameLabel.text = self.exportVault.name;
    
}


- (void)dealloc {
    NSLog(@"ExportViewController dealloc");
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.passwordTextField becomeFirstResponder];
}


- (void)onExportButtonClicked:(UIButton *)sender {
    [self onExportVaultData];
}


- (BOOL)onExportVaultData {
    if (!self.exportVault) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"Can not find your vault" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confrimAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alertController dismissViewControllerAnimated:YES completion:nil];
        }];
        [alertController addAction:confrimAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return NO;
    }
    
    NSString *verifiedPassword = self.passwordTextField.text;
    BOOL isPasswordOK = [self.exportVault verifyPassword:verifiedPassword];
    if (!isPasswordOK) {
        _passwordTextField.text = nil;
        // show fail animation
        [self showInputErrorBoundaryInView:self.passwordTextField];
        return NO;
    }
    
    NSString *vaultName = [self.exportVault.vaultPath lastPathComponent];
    NSString *zipFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:vaultName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:zipFilePath]) {
        NSError *error;
        BOOL isOK = [[NSFileManager defaultManager] removeItemAtPath:zipFilePath error:nil];
        NSLog(@"Remove existed zip file: %@", isOK ? @"OK" : error);
    }
    
    BOOL isOK = [SSZipArchive createZipFileAtPath:zipFilePath
                          withContentsOfDirectory:self.exportVault.vaultPath
                                     withPassword:verifiedPassword];
    NSLog(@"Create zip %@", isOK ? @"Success!" : @"Fail");
    
    if (isOK) {
        NSURL *fileUrl = [NSURL fileURLWithPath:zipFilePath];
        UIActivityViewController *avc = [[UIActivityViewController alloc] initWithActivityItems:
                                         @[fileUrl] applicationActivities:nil];
        [avc setCompletionWithItemsHandler:^(UIActivityType __nullable activityType, BOOL completed, NSArray * __nullable returnedItems, NSError * __nullable activityError) {
            NSError *error;
            BOOL isOK = [[NSFileManager defaultManager] removeItemAtPath:zipFilePath error:nil];
            NSLog(@"Clean zip file: %@", isOK ? @"OK" : error);
        }];
        
        if ([avc respondsToSelector:@selector(popoverPresentationController)]) {
            avc.popoverPresentationController.sourceView = self.view;
            avc.popoverPresentationController.sourceRect = CGRectMake(0, kLocalHeight - 1, kLocalWidth, 1);
        }
        [self presentViewController:avc animated:YES completion:nil];
    }
    return isOK;
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
        [_confirmButton setTitle:@"Export" forState:UIControlStateNormal];
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
    if ([self onExportVaultData]) {
        [textField resignFirstResponder];
        return YES;
        
    } else {
        return NO;
    }
}


@end




