//
//  VaultManager.h
//  MyPassword
//
//  Created by chance on 12/20/16.
//  Copyright © 2016 bychance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PasswordInfo.h"

@interface VaultManager : NSObject

@property (nonatomic, readonly) NSString *vaultPath;
@property (nonatomic, readonly) BOOL islocked;

- (instancetype)initWithVault:(NSString *)vaultPath;

- (BOOL)unlockWithPassword:(NSString *)password;
- (void)lock;

- (NSArray <PasswordInfo *>*)allPasswordInfos;
- (void)addPasswordInfo:(PasswordInfo *)passwordInfo;
- (void)deletePasswordInfo:(PasswordInfo *)passwordInfo;

- (NSString *)decrpytPassword:(PasswordInfo *)passwordInfo;

@end

