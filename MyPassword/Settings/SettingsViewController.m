//
//  SettingsViewController.m
//  MyPassword
//
//  Created by chance on 6/5/2017.
//  Copyright © 2017 bychance. All rights reserved.
//

#import "SettingsViewController.h"
#import "SSZipArchive.h"

#define kLocalWidth self.view.bounds.size.width
#define kLocalHeight self.view.bounds.size.height

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (void)dealloc {
    NSLog(@"SettingsViewController dealloc");
}


- (IBAction)onClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)onGroupSortingSwitherChanged:(UISwitch *)switcher {
    NSLog(@"%s", __FUNCTION__);
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"%s", __FUNCTION__);
    
    if (indexPath.section == 1 && indexPath.row == 0) {
        [self onExportVaultData];
    }
}


- (void)onExportVaultData {
    if (!self.currentVault) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"Can not find your valut" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confrimAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alertController dismissViewControllerAnimated:YES completion:nil];
        }];
        [alertController addAction:confrimAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    NSString *vaultName = [self.currentVault.vaultPath lastPathComponent];
    NSString *zipFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:vaultName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:zipFilePath]) {
        NSError *error;
        BOOL isOK = [[NSFileManager defaultManager] removeItemAtPath:zipFilePath error:nil];
        NSLog(@"Remove existed zip file: %@", isOK ? @"OK" : error);
    }
    
    BOOL isOK = [SSZipArchive createZipFileAtPath:zipFilePath
                          withContentsOfDirectory:self.currentVault.vaultPath];
    NSLog(@"Create zip %@", isOK ? @"Success!" : @"Fail");
    
    // show share UI
    dispatch_async(dispatch_get_main_queue(), ^{
        NSURL *fileUrl = [NSURL fileURLWithPath:zipFilePath];
        UIActivityViewController *avc = [[UIActivityViewController alloc] initWithActivityItems:
                                         @[fileUrl] applicationActivities:nil];
        if ([avc respondsToSelector:@selector(popoverPresentationController)]) {
            avc.popoverPresentationController.sourceView = self.view;
            avc.popoverPresentationController.sourceRect = CGRectMake(0, kLocalHeight - 1, kLocalWidth, 1);
        }
        [self presentViewController:avc animated:YES completion:nil];
    });
}


@end






