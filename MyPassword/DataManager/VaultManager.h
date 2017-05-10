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

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *vaultPath;
@property (nonatomic, readonly) BOOL isLocked;

- (instancetype)initWithVaultPath:(NSString *)vaultPath;

- (BOOL)changePassword:(NSString *)newPassword;

- (BOOL)unlockWithPassword:(NSString *)password;
- (void)lock;
- (BOOL)verifyPassword:(NSString *)password;

- (NSArray <IndexInfo *>*)indexInfoList;

- (PasswordInfo *)passwordInfoWithUUID:(NSString *)passwordUUID;
- (BOOL)addPasswordInfo:(PasswordInfo *)passwordInfo;
- (BOOL)updatePasswordInfo:(PasswordInfo *)passwordInfo;
- (BOOL)deletePasswordWithUUID:(NSString *)passwordUUID;


/** Vault Management **/

// vault creation
+ (BOOL)createVaultWithName:(NSString *)vaultName
                     atPath:(NSString *)vaultPath
              usingPassword:(NSString *)password;

// check if the vault at specific path is vaild
+ (BOOL)verifyVaultWithPath:(NSString *)vaultPath;


@end





