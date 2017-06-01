//
//  VaultDefines.h
//  MyPassword
//
//  Created by chance on 5/5/2017.
//  Copyright © 2017 bychance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PasswordType) {
    PasswordTypeLogin = 0,
    PasswordTypeBankAccount,
    PasswordTypeOthers,
    
    PasswordTypeCount,
};

UIImage *IconImageWithType(PasswordType type);
UIImage *SmallIconImageWithType(PasswordType type);
UIColor *StyleColorWithType(PasswordType type);


NSString *GeneratePasswordUUID();


#define kVaultExtension @"vault"
#define kUserDefaultKey_DefaultVaultName @"default_vault_name"
