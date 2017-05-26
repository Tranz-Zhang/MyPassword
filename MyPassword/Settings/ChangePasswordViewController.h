//
//  ChangePasswordViewController.h
//  MyPassword
//
//  Created by chance on 26/5/2017.
//  Copyright © 2017 bychance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VaultManager.h"

extern NSNotificationName const kDidChangedPasswordNotification;

@interface ChangePasswordViewController : UIViewController

@property (nonatomic, strong) VaultManager *vault;

@end
