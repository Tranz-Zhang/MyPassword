//
//  RegistViewController.h
//  MyPassword
//
//  Created by chance on 1/18/17.
//  Copyright © 2017 bychance. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RegistViewControllerDelegate;
@interface RegistViewController : UIViewController

@property (nonatomic, weak) id<RegistViewControllerDelegate> delegate;

@end


@protocol RegistViewControllerDelegate <NSObject>

- (void)registViewController:(RegistViewController *)registVC
            didCreateAccount:(NSString *)accountName
                    password:(NSString *)password;

@end

