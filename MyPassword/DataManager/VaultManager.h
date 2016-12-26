//
//  VaultManager.h
//  MyPassword
//
//  Created by chance on 12/20/16.
//  Copyright © 2016 bychance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PasswordInfo.h"
#import "IndexInfo.h"

#define kVaultExtension @"vault"

@interface VaultManager : NSObject

@property (nonatomic, readonly) NSString *vaultPath;
@property (nonatomic, readonly) BOOL isLocked;

- (instancetype)initWithVaultPath:(NSString *)vaultPath;

- (BOOL)changePassword:(NSString *)newPassword;

- (BOOL)unlockWithPassword:(NSString *)password;
- (void)lock;

- (NSArray <IndexInfo *>*)indexInfoList;

- (PasswordInfo *)passwordInfoWithUUID:(NSString *)passwordUUID;
- (void)addPasswordInfo:(PasswordInfo *)passwordInfo;
- (void)updatePasswordInfo:(PasswordInfo *)passwordInfo;
- (void)deletePasswordInfo:(PasswordInfo *)passwordInfo;


/** Vault Management **/

// vault creation
+ (BOOL)createVaultWithName:(NSString *)vaultName
                     atPath:(NSString *)vaultPath
              usingPassword:(NSString *)password;

// check if the vault at specific path is vaild
+ (BOOL)verifyVaultWithPath:(NSString *)vaultPath;


@end





