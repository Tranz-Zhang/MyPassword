//
//  ContentViewController.m
//  MyPassword
//
//  Created by chance on 1/18/17.
//  Copyright © 2017 bychance. All rights reserved.
//

#import "ContentViewController.h"
#import "EditViewController.h"
#import "PasswordInfoCell.h"
#import "PasswordDetailCell.h"
#import "VaultManager.h"

@interface ContentViewController () <UITableViewDelegate, UITableViewDataSource,
EditViewControllerDelegate, PasswordDetailCellDelegate> {
    NSIndexPath *_detailIndexPath;
    NSArray *_infoList;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end


@implementation ContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (void)refreshList {
    if (!_vault || _vault.isLocked) {
        return;
    }
    
    _infoList = [self.vault indexInfoList];
    // adjust footer view
    if (_infoList.count && !_tableView.tableFooterView) {
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 0.5)];
        footerView.backgroundColor = [UIColor lightGrayColor];
        _tableView.tableFooterView = footerView;
        
    } else if (!_infoList.count && _tableView.tableFooterView ) {
        _tableView.tableFooterView = nil;
    }
    
    [_tableView reloadData];
}


#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _infoList.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_detailIndexPath isEqual:indexPath]) {
        return 148;
    } else {
        return 60;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if ([indexPath isEqual:_detailIndexPath]) {
        PasswordDetailCell *detailCell = [tableView dequeueReusableCellWithIdentifier:@"PasswordDetailCell"
                                                                         forIndexPath:indexPath];
        detailCell.delegate = self;
        cell = detailCell;
        
    } else {
        PasswordInfoCell *infoCell = [tableView dequeueReusableCellWithIdentifier:@"PasswordInfoCell"];
        IndexInfo *info = _infoList[indexPath.row];
        infoCell.itemTitleLabel.text = info.title;
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
    [tableView reloadRowsAtIndexPaths:reloadRows withRowAnimation:UITableViewRowAnimationFade];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowPasswordDetail"]) {
        segue.destinationViewController.title = @"Detail";
        
    } else if ([segue.identifier isEqualToString:@"AddPassword"]) {
        UINavigationController *nv = segue.destinationViewController;
        EditViewController *editVC = nv.viewControllers[0];
        editVC.delegate = self;
    }
}


#pragma mark - PasswordDetailCellDelegate
- (void)passwordDetailCellDidClickEdit:(PasswordDetailCell *)cell {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    EditViewController *editVC = [storyBoard instantiateViewControllerWithIdentifier:@"EditViewController"];
    UINavigationController *nv = [[UINavigationController alloc] initWithRootViewController:editVC];
    [self presentViewController:nv animated:YES completion:nil];
}


#pragma mark - EditViewControllerDelegate

- (void)editViewController:(EditViewController *)vc didAddPassword:(PasswordInfo *)password {
    BOOL isOK = [self.vault addPasswordInfo:password];
    if (isOK) {
        _infoList = [self.vault indexInfoList];
        [_tableView reloadData];
    }
    
    NSLog(@"Add password: %@", isOK ? [password toDictionary] : @"Fail");
}


- (void)editViewController:(EditViewController *)vc didUpdatePassword:(PasswordInfo *)password {
    BOOL isOK = [self.vault updatePasswordInfo:password];
    if (isOK) {
        _infoList = [self.vault indexInfoList];
        [_tableView reloadData];
    }
    
    NSLog(@"Update password: %@", isOK ? [password toDictionary] : @"Fail");
}




@end