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
    __weak UIView *_emptyView;
    
    NSArray *_infoList;
    NSIndexPath *_detailIndexPath;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end


@implementation MainListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *footerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"footer_shadow"]];
    footerView.frame = CGRectMake(0, 0, kLocalWidth, 5);
    self.tableView.tableFooterView = footerView;
    
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
    [self.tableView reloadData];
    [self updateEmptyView];
}


- (void)updateEmptyView {
    if (_infoList.count && _emptyView) {
        [_emptyView removeFromSuperview];
        _emptyView = nil;
        self.tableView.userInteractionEnabled = YES;
        
    } else if (!_infoList.count && !_emptyView) {
        UINib *nib = [UINib nibWithNibName:@"MainListEmptyView" bundle:[NSBundle mainBundle]];
        UIView *emptyView = [[nib instantiateWithOwner:self options:nil] lastObject];
        emptyView.frame = self.view.bounds;
        [self.view addSubview:emptyView];
        _emptyView = emptyView;
        
        _emptyView.alpha = 0;
        [UIView animateWithDuration:0.3 animations:^{
            _emptyView.alpha = 1;
        }];
        
        self.tableView.userInteractionEnabled = NO;
    }
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
        [self updateEmptyView];
    }
}


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
