//
//  MergeViewController.h
//  MyPassword
//
//  Created by chance on 5/11/17.
//  Copyright © 2017 bychance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VaultManager.h"

@interface MergeViewController : UITableViewController

@property (nonatomic, strong) VaultManager *originalVault;
@property (nonatomic, strong) VaultManager *mergingVault;

@end
