//
//  ImportViewController.h
//  MyPassword
//
//  Created by chance on 8/5/2017.
//  Copyright © 2017 bychance. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSNotificationName const kDidFinishImportVaultNotification;
extern NSNotificationName const kImportedVaultPathKey;

@interface ImportViewController : UIViewController

@property (nonatomic, copy) NSString *importFilePath;

@end
