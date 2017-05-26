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
#define kTableViewHeaderIdentifier @"MainListHeader"
#define kIndexStringOthers @"#"

@interface IndexInfoGroup : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSMutableArray *indexList;

@end


@implementation IndexInfoGroup
@end


@interface MainListViewController () <UITableViewDelegate, UITableViewDataSource,
EditViewControllerDelegate, PasswordDetailCellDelegate> {
    __weak UIView *_emptyView;
    
    NSArray *_infoGroupList;
    NSArray *_sectionIndexTitles;
    NSIndexPath *_detailIndexPath;
    NSInteger _itemCount;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *footerLabel;

@end


@implementation MainListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bar_title"]];
    UINib *headerNib = [UINib nibWithNibName:@"MainListTableHeader3" bundle:[NSBundle mainBundle]];
    [self.tableView registerNib:headerNib forHeaderFooterViewReuseIdentifier:kTableViewHeaderIdentifier];
    self.tableView.sectionHeaderHeight = 30;
    self.tableView.sectionIndexTrackingBackgroundColor = [UIColor colorWithWhite:0.9 alpha:0.5];
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)awakeFromNib {
    [super awakeFromNib];
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
        _infoGroupList = nil;
        [self.tableView reloadData];
        return;
    }
    
    _detailIndexPath = nil;
    _sectionIndexTitles = nil;
    _infoGroupList = nil;
    NSArray *indexList = [self.vault indexInfoList];
    if (indexList.count) {
        NSMutableDictionary *groupDict = [NSMutableDictionary dictionary];
        for (IndexInfo *info in indexList) {
            NSString *indexAlphabet = [self indexAlphabetWithString:info.title];
            IndexInfoGroup *group = groupDict[indexAlphabet];
            if (!group) {
                group = [IndexInfoGroup new];
                group.title = indexAlphabet;
                group.indexList = [NSMutableArray array];
                groupDict[indexAlphabet] = group;
            }
            [group.indexList addObject:info];
        }
        _sectionIndexTitles = [[groupDict allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        NSMutableArray *groupList = [NSMutableArray arrayWithCapacity:groupDict.count];
        for (NSString *key in _sectionIndexTitles) {
            [groupList addObject:groupDict[key]];
        }
        _infoGroupList = [groupList copy];
    }
    _itemCount = indexList.count;
    self.footerLabel.text = [NSString stringWithFormat:@"%lu item%s", (unsigned long)_itemCount, _itemCount > 1 ? "s" : ""];
    
    [self.tableView reloadData];
    [self updateEmptyView];
}


- (void)updateEmptyView {
    if (_infoGroupList.count && _emptyView) {
        [_emptyView removeFromSuperview];
        _emptyView = nil;
        self.tableView.userInteractionEnabled = YES;
        
    } else if (!_infoGroupList.count && !_emptyView) {
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


- (NSString *)indexAlphabetWithString:(NSString *)contentString {
    unichar indexAlphabet = -1;
    NSMutableString *transformStr = [[NSMutableString alloc] initWithString:contentString];
    if (CFStringTransform((__bridge CFMutableStringRef)transformStr, 0, kCFStringTransformToLatin, NO)) {
        if (CFStringTransform((__bridge CFMutableStringRef)transformStr, 0, kCFStringTransformStripDiacritics, NO)) {
            indexAlphabet = [transformStr characterAtIndex:0];
        }
    }
    // from A to Z
    if ((indexAlphabet >= 'a' && indexAlphabet <= 'z') ||
        (indexAlphabet >= 'A' && indexAlphabet <= 'Z')) {
        return [NSString stringWithFormat:@"%c", indexAlphabet > 'Z' ? indexAlphabet - ('a' - 'A') : indexAlphabet];
        
    } else {
        return kIndexStringOthers;
    }
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _infoGroupList.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kTableViewHeaderIdentifier];
    UILabel *titleLabel = [headerView viewWithTag:123];
    if (titleLabel) {
        IndexInfoGroup *group = _infoGroupList[section];
        titleLabel.text = group.title;
    }
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    IndexInfoGroup *group = _infoGroupList[section];
    return group.indexList.count;
}


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return _sectionIndexTitles;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_detailIndexPath isEqual:indexPath]) {
        return 180;
        
    } else {
        return 60;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    IndexInfoGroup *group = _infoGroupList[indexPath.section];
    IndexInfo *indexInfo = group.indexList[indexPath.row];
    if ([indexPath isEqual:_detailIndexPath]) {
        PasswordDetailCell *detailCell = [tableView dequeueReusableCellWithIdentifier:@"PasswordDetailCell2" forIndexPath:indexPath];
        detailCell.delegate = self;
        detailCell.passwordInfo = [_vault passwordInfoWithUUID:indexInfo.passwordUUID];
        cell = detailCell;
        
    } else {
        PasswordInfoCell *infoCell = [tableView dequeueReusableCellWithIdentifier:@"PasswordInfoCell"];
        infoCell.indexInfo = indexInfo;
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
    
    if (_detailIndexPath) {
        [self.tableView scrollToRowAtIndexPath:_detailIndexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
    }
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
    
    IndexInfoGroup *group = _infoGroupList[indexPath.section];
    IndexInfo *deletedIndex = group.indexList[indexPath.row];
    if ([self.vault deletePasswordWithUUID:deletedIndex.passwordUUID]) {
        if ([indexPath isEqual:_detailIndexPath]) {
            _detailIndexPath = nil;
        }
        [group.indexList removeObjectAtIndex:indexPath.row];
        if (group.indexList.count) {
            // remove row
            [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
            
        } else {
            // remove section
            NSMutableArray *tmp = [_infoGroupList mutableCopy];
            [tmp removeObjectAtIndex:indexPath.section];
            _infoGroupList = [tmp copy];
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section]
                          withRowAnimation:UITableViewRowAnimationFade];
            
            // remove section index title
            tmp = [_sectionIndexTitles mutableCopy];
            [tmp removeObjectAtIndex:indexPath.section];
            _sectionIndexTitles = [tmp copy];
            [self.tableView reloadSectionIndexTitles];
        }
        
        // update item count
        _itemCount--;
        self.footerLabel.text = [NSString stringWithFormat:@"%lu item%s", (unsigned long)_itemCount, _itemCount > 1 ? "s" : ""];
        
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



@end




