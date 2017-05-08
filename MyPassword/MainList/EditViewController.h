//
//  EditViewController.h
//  MyPassword
//
//  Created by chance on 12/16/16.
//  Copyright © 2016 bychance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PasswordInfo.h"

@protocol EditViewControllerDelegate;
@interface EditViewController : UIViewController

@property (nonatomic, strong) PasswordInfo *password;
@property (nonatomic, weak) id<EditViewControllerDelegate> delegate;

@end


@protocol EditViewControllerDelegate  <NSObject>

- (void)editViewController:(EditViewController *)vc didAddPassword:(PasswordInfo *)password;
- (void)editViewController:(EditViewController *)vc didUpdatePassword:(PasswordInfo *)password;

@end
