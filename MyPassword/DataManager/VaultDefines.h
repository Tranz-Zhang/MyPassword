//
//  VaultDefines.h
//  MyPassword
//
//  Created by chance on 5/5/2017.
//  Copyright © 2017 bychance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PasswordIconType) {
    PasswordIconLogin = 0,
    PasswordIconCreditCard,
    PasswordIconOthers,
    
    PasswordIconCount,
};

UIImage *IconImageWithType(PasswordIconType type);
UIImage *SmallIconImageWithType(PasswordIconType type);


NSString *GeneratePasswordUUID();

