//
//  SettingsViewController.h
//  MyPassword
//
//  Created by chance on 6/5/2017.
//  Copyright © 2017 bychance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VaultManager.h"
#import "SettingDefines.h"

/**
 Functions:
 - Export
 - SortList
 - change password
 - delege account
 - Version
 */

@interface SettingsViewController : UITableViewController

@property (nonatomic, strong) VaultManager *currentVault;

@end
