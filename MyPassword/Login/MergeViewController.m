//
//  MergeViewController.m
//  MyPassword
//
//  Created by chance on 5/11/17.
//  Copyright © 2017 bychance. All rights reserved.
//

#import "MergeViewController.h"
#import "MergeInfoCell.h"

#define kLocalWidth self.view.bounds.size.width
#define kLocalHeight self.view.bounds.size.height

@interface MergeViewController ()<MergeInfoCellDelegate> {
    NSMutableArray <MergeInfo *> *_infoList;
    __weak UIView *_loadingView;
}

@end

@implementation MergeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *footerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"footer_shadow"]];
    footerView.frame = CGRectMake(0, 0, kLocalWidth, 5);
    self.tableView.tableFooterView = footerView;
    
    if (self.originalVault.isLocked || self.mergingVault.isLocked) {
        NSLog(@"Error: merging vaults are locked");
        return;
    }
    
    CGRect frame = CGRectOffset(self.view.bounds, 0, -64);
    UILabel *loadLabel = [[UILabel alloc] initWithFrame:frame];
    loadLabel.text = @"Calculating...";
    loadLabel.font = [UIFont boldSystemFontOfSize:25];
    loadLabel.textColor = [UIColor grayColor];
    loadLabel.textAlignment = NSTextAlignmentCenter;
    loadLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:loadLabel];
    _loadingView = loadLabel;
    self.tableView.userInteractionEnabled = NO;
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self generateMergeInfoList];
    
    [_loadingView removeFromSuperview];
    _loadingView = nil;
    self.tableView.userInteractionEnabled = YES;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}


- (IBAction)onFinshMerge:(UIBarButtonItem *)sender {
    if (self.navigationController) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


#pragma mark - Generate Merging List
- (void)generateMergeInfoList {
    NSMutableArray *mergeList = [NSMutableArray array];
    NSArray *newIndexInfos = [self.mergingVault indexInfoList];
    NSDictionary *newPasswordDict = [self fetchPasswordDictionaryInVault:self.mergingVault];
    NSArray *originalIndexInfos = [self.originalVault indexInfoList];
    NSDictionary *originalPasswordDict = [self fetchPasswordDictionaryInVault:self.originalVault];
    
    // sort newIndexInfos
    newIndexInfos = [newIndexInfos sortedArrayUsingComparator:^NSComparisonResult(IndexInfo *info1, IndexInfo *info2) {
        return [info1.title compare:info2.title];
    }];
    for (IndexInfo *newIndexInfo in newIndexInfos) {
        BOOL containSameInfo = NO;
        PasswordInfo *similarPasswordInfo = nil;
        for (IndexInfo *originalIndexInfo in originalIndexInfos) {
            if ([originalIndexInfo.title isEqualToString:newIndexInfo.title]) {
                // 如果标题不相同，说明不是同一个项目，直接忽略掉
                PasswordInfo *newPasswordInfo = newPasswordDict[newIndexInfo.passwordUUID];
                PasswordInfo *originalPasswordInfo = originalPasswordDict[originalIndexInfo.passwordUUID];
                if (newPasswordInfo.iconType == originalIndexInfo.iconType &&
                    [newPasswordInfo.account    isEqualToString:originalPasswordInfo.account] &&
                    [newPasswordInfo.password   isEqualToString:originalPasswordInfo.password] &&
                    [newPasswordInfo.notes      isEqualToString:originalPasswordInfo.notes]) {
                    containSameInfo = YES;
                    
                } else {
                    // 标题相同，但其他选项有不同，加入对比
                    similarPasswordInfo = originalPasswordInfo;
                }
                break;
            }
        }
        if (!containSameInfo) {
            MergeInfo *info = [MergeInfo new];
            info.passwordInfo = newPasswordDict[newIndexInfo.passwordUUID];
            info.vault = self.mergingVault;
            info.similarPasswordInfo = similarPasswordInfo;
            [mergeList addObject:info];
        }
    }
    
    _infoList = mergeList;
}


- (NSDictionary <NSString *, PasswordInfo *> *)fetchPasswordDictionaryInVault:(VaultManager *)vault {
    NSArray *indexInfos = [vault indexInfoList];
    NSMutableDictionary *passwordDict = [NSMutableDictionary dictionaryWithCapacity:indexInfos.accessibilityElementCount];
    for (IndexInfo *indexInfo in indexInfos) {
        NSString *uuid = indexInfo.passwordUUID;
        PasswordInfo *password = [vault passwordInfoWithUUID:uuid];
        if (uuid && password) {
            passwordDict[uuid] = password;
        }
    }
    return [passwordDict copy];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _infoList.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    MergeInfo *info = _infoList[indexPath.row];
    return info.displayMode == MergeCellDisplayNew ? 120 : 150;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MergeInfoCell *cell = (MergeInfoCell *)[tableView dequeueReusableCellWithIdentifier:@"MergeInfoCell" forIndexPath:indexPath];
    cell.mergeInfo = _infoList[indexPath.row];
    cell.delegate = self;
    return cell;
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
    
    [_infoList removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}


#pragma mark - MergeInfoCellDelegate
- (void)mergeInfoCell:(MergeInfoCell *)cell didChangeDisplayMode:(MergeCellDisplayMode)displayMode {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (!indexPath) {
        NSLog(@"Fail to find cell!!!");
        return;
    }
    
    UITableViewRowAnimation animation = displayMode == MergeCellDisplaySimilar ? UITableViewRowAnimationLeft : UITableViewRowAnimationRight;
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
}


@end



