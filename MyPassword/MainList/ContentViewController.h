//
//  ContentViewController.h
//  MyPassword
//
//  Created by chance on 1/18/17.
//  Copyright © 2017 bychance. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VaultManager;
@interface ContentViewController : UIViewController

@property (nonatomic, weak) VaultManager *vault;

- (void)refreshList;

@end
