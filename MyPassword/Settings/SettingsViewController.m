//
//  SettingsViewController.m
//  MyPassword
//
//  Created by chance on 6/5/2017.
//  Copyright © 2017 bychance. All rights reserved.
//

#import "SettingsViewController.h"
#import "ExportViewController.h"
#import "ChangePasswordViewController.h"

#define kLocalWidth self.view.bounds.size.width
#define kLocalHeight self.view.bounds.size.height

@interface SettingsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.versionLabel.text = [NSString stringWithFormat:@"Version: %@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
}


- (void)dealloc {
    NSLog(@"SettingsViewController dealloc");
}


- (IBAction)onClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"%s", __FUNCTION__);
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowExportVC"]) {
        ExportViewController *exportVC = segue.destinationViewController;
        exportVC.exportVault = self.currentVault;
    }
    if ([segue.identifier isEqualToString:@"ShowChangePasswordVC"]) {
        ChangePasswordViewController *changePasswordVC = segue.destinationViewController;
        changePasswordVC.vault = self.currentVault;
    }
}

@end






