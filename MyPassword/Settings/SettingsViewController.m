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

@property (weak, nonatomic) IBOutlet UISwitch *sortByGroupSwitcher;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSNumber *enableSort = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultKey_EnableSortByGroup];
    self.sortByGroupSwitcher.on = [enableSort boolValue];
    
    self.versionLabel.text = [NSString stringWithFormat:@"Version: %@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
}


- (void)dealloc {
    NSLog(@"SettingsViewController dealloc");
}


- (IBAction)onClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)onGroupSortingSwitherChanged:(UISwitch *)switcher {
    NSLog(@"onGroupSortingSwitherChanged: %@", switcher.on ? @"ON" : @"OFF");
    [[NSUserDefaults standardUserDefaults] setObject:@(switcher.on)
                                              forKey:kUserDefaultKey_EnableSortByGroup];
    [[NSUserDefaults standardUserDefaults] synchronize];
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






