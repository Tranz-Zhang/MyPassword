//
//  LoginViewController.h
//  MyPassword
//
//  Created by chance on 1/17/17.
//  Copyright © 2017 bychance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VaultManager.h"

@protocol LoginViewControllerDelegate;
@interface LoginViewController : UIViewController

@property (nonatomic, strong) VaultManager *vault;
@property (nonatomic, copy) NSString *accountName;
@property (nonatomic, weak) id<LoginViewControllerDelegate> delegate;

@end


@protocol LoginViewControllerDelegate <NSObject>

- (void)loginViewControllerDidFinishLogin:(LoginViewController *)loginVC;

@end
