//
//  ViewController.h
//  MyPassword
//
//  Created by chance on 29/11/2016.
//  Copyright © 2016 bychance. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VaultManager;
@interface MainViewController : UIViewController

@property (nonatomic, readonly) VaultManager *vault;

@end

