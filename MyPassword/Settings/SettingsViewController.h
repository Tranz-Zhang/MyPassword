//
//  SettingsViewController.h
//  MyPassword
//
//  Created by chance on 6/5/2017.
//  Copyright © 2017 bychance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VaultManager.h"

/**
 Functions:
 - Export
 - SortList
 - Version
 */

@interface SettingsViewController : UITableViewController

@property (nonatomic, strong) VaultManager *currentVault;

@end
