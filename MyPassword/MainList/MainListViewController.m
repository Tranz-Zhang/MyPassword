//
//  MainListViewController.m
//  MyPassword
//
//  Created by chance on 1/18/17.
//  Copyright © 2017 bychance. All rights reserved.
//

#import "MainListViewController.h"
#import "EditViewController.h"
#import "SettingsViewController.h"
#import "PasswordInfoCell.h"
#import "PasswordDetailCell.h"
#import "VaultManager.h"
#import "StoryboardLoader.h"


#define kLocalWidth self.view.bounds.size.width
#define kLocalHeight self.view.bounds.size.height

@interface MainListViewController () <UITableViewDelegate, UITableViewDataSource,
EditViewControllerDelegate, PasswordDetailCellDelegate> {
    NSIndexPath *_detailIndexPath;
    NSArray *_infoList;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end


@implementation MainListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)onAddNewPassword:(id)sender {
    UINavigationController *editNC = [StoryboardLoader loadViewController:@"EditNavigationController" inStoryboard:@"MainList"];
    EditViewController *editVC = editNC.viewControllers[0];
    editVC.delegate = self;
    [self presentViewController:editNC animated:YES completion:nil];
}


- (IBAction)onShowSettings:(id)sender {
    UINavigationController *settingsNC = [StoryboardLoader loadViewController:@"SettingsNavigationController" inStoryboard:@"Setting"];
    SettingsViewController *settingsVC = settingsNC.viewControllers[0];
    settingsVC.currentVault = self.vault;
    [self presentViewController:settingsNC animated:YES completion:nil];
}


- (void)refreshList {
    if (!_vault || _vault.isLocked) {
        _infoList = nil;
        [self.tableView reloadData];
        return;
    }
    
    _detailIndexPath = nil;
    _infoList = [self.vault indexInfoList];
    // adjust footer view
    if (_infoList.count && !self.tableView.tableFooterView) {
        UIView *footerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"footer_shadow"]];
        footerView.frame = CGRectMake(0, 0, kLocalWidth, 5);
        self.tableView.tableFooterView = footerView;
        
    } else if (!_infoList.count && self.tableView.tableFooterView ) {
        self.tableView.tableFooterView = nil;
    }
    
    [self.tableView reloadData];
}


#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _infoList.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_detailIndexPath isEqual:indexPath]) {
        return 158;
        
    } else {
        return 60;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if ([indexPath isEqual:_detailIndexPath]) {
        PasswordDetailCell *detailCell = [tableView dequeueReusableCellWithIdentifier:@"PasswordDetailCell" forIndexPath:indexPath];
        detailCell.delegate = self;
        IndexInfo *indexInfo = _infoList[indexPath.row];
        detailCell.passwordInfo = [_vault passwordInfoWithUUID:indexInfo.passwordUUID];
        cell = detailCell;
        
    } else {
        PasswordInfoCell *infoCell = [tableView dequeueReusableCellWithIdentifier:@"PasswordInfoCell"];
        infoCell.indexInfo = _infoList[indexPath.row];;
        cell = infoCell;
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *reloadRows = nil;
    if ([_detailIndexPath isEqual:indexPath]) {
        _detailIndexPath = nil;
        reloadRows = @[indexPath];
        
    } else {
        reloadRows = _detailIndexPath ? @[indexPath, _detailIndexPath] : @[indexPath];
        _detailIndexPath = indexPath;
    }
    [tableView reloadRowsAtIndexPaths:reloadRows withRowAnimation:UITableViewRowAnimationAutomatic];
}


#pragma mark - Table view deletion
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle != UITableViewCellEditingStyleDelete) {
        return;
    }
    
    IndexInfo *deletedIndex = _infoList[indexPath.row];
    if ([self.vault deletePasswordWithUUID:deletedIndex.passwordUUID]) {
        if ([indexPath isEqual:_detailIndexPath]) {
            _detailIndexPath = nil;
        }
        _infoList = [self.vault indexInfoList];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}


//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if ([segue.identifier isEqualToString:@"AddOrEditPassword"]) {
//        UINavigationController *nv = segue.destinationViewController;
//        EditViewController *editVC = nv.viewControllers[0];
//        editVC.delegate = self;
//        
//    } else if ([segue.identifier isEqualToString:@"ShowSettingsVC"]) {
//        UINavigationController *nv = segue.destinationViewController;
//        SettingsViewController *editVC = nv.viewControllers[0];
//        editVC.currentVault = self.vault;
//    }
//}


#pragma mark - PasswordDetailCellDelegate
- (void)passwordDetailCellDidClickEdit:(PasswordDetailCell *)cell {
    UINavigationController *editNC = [StoryboardLoader loadViewController:@"EditNavigationController" inStoryboard:@"MainList"];
    EditViewController *editVC = editNC.viewControllers[0];
    editVC.password = cell.passwordInfo;
    editVC.delegate = self;
    [self presentViewController:editNC animated:YES completion:nil];
}


#pragma mark - EditViewControllerDelegate

- (void)editViewController:(EditViewController *)vc didAddPassword:(PasswordInfo *)password {
    BOOL isOK = [self.vault addPasswordInfo:password];
    if (isOK) {
        [self refreshList];
    }
    
    NSLog(@"Add password: %@", isOK ? [password toDictionary] : @"Fail");
}


- (void)editViewController:(EditViewController *)vc didUpdatePassword:(PasswordInfo *)password {
    BOOL isOK = [self.vault updatePasswordInfo:password];
    if (isOK) {
        [self refreshList];
    }
    
    NSLog(@"Update password: %@", isOK ? [password toDictionary] : @"Fail");
}

//add empty view and footer view


@end
