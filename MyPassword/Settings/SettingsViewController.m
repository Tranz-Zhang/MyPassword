//
//  SettingsViewController.m
//  MyPassword
//
//  Created by chance on 6/5/2017.
//  Copyright © 2017 bychance. All rights reserved.
//

#import "SettingsViewController.h"
#import "ExportViewController.h"

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
    
//    if (indexPath.section == 1 && indexPath.row == 0) {
//        [self onExportVaultData];
//    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowExportVC"]) {
        ExportViewController *exportVC = segue.destinationViewController;
        exportVC.exportVault = self.currentVault;
    }
}

@end






