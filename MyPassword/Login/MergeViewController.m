//
//  MergeViewController.m
//  MyPassword
//
//  Created by chance on 5/11/17.
//  Copyright © 2017 bychance. All rights reserved.
//

#import "MergeViewController.h"
#import "MergeInfoCell.h"

@interface MergeInfo : NSObject

@property (nonatomic, strong) PasswordInfo *passwordInfo;
@property (nonatomic, strong) VaultManager *vault;
@property (nonatomic, strong) PasswordInfo *similarPasswordInfo;

@end

@implementation MergeInfo
@end



@interface MergeViewController () {
    NSMutableArray <MergeInfo *> *_infoList;
}

@end

@implementation MergeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.originalVault.isLocked || self.mergingVault.isLocked) {
        NSLog(@"Error: merging vaults are locked");
        return;
    }
    
    [self generateMergeInfoList];
    [self.tableView reloadData];
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
    
    _infoList = [mergeList copy];
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
    return 148;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MergeInfoCell *cell = (MergeInfoCell *)[tableView dequeueReusableCellWithIdentifier:@"MergeInfoCell" forIndexPath:indexPath];
    
    MergeInfo *info = _infoList[indexPath.row];
    cell.passwordInfo = info.passwordInfo;
    cell.isNew = (info.similarPasswordInfo != nil);
    
    return cell;
}



@end
