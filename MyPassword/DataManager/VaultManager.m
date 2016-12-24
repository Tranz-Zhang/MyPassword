//
//  VaultManager.m
//  MyPassword
//
//  Created by chance on 12/20/16.
//  Copyright © 2016 bychance. All rights reserved.
//

#import "VaultManager.h"
#import "RNCryptor_iOS.h"

#define kIndexInfoFileName @"index_info_list"

@implementation VaultManager {
    NSArray *_indexInfoList;
}

- (instancetype)initWithVaultPath:(NSString *)vaultPath {
    self = [super init];
    if (self) {
        _vaultPath = [vaultPath copy];
    }
    return self;
}


- (BOOL)unlockWithPassword:(NSString *)password {
    if (!password.length || !_vaultPath.length) {
        return NO;
    }
    
    NSString *indexInfoFilePath = [_vaultPath stringByAppendingPathComponent:kIndexInfoFileName];
    NSData *indexData = [NSData dataWithContentsOfFile:indexInfoFilePath];
    if (!indexData.length) {
        return NO;
    }
    NSError *error;
    indexData = [RNDecryptor decryptData:indexData withPassword:password error:&error];
    if (!indexData.length) {
        NSLog(@"Fail to decrypt index info: %@", error);
        return NO;
    }
    
    NSArray *indexList = [IndexInfo arrayOfModelsFromData:indexData error:nil];
    _indexInfoList = [NSArray arrayWithArray:indexList];
    return YES;
}


- (void)lock {
    _isLocked = YES;
    _indexInfoList = nil;
}



#pragma mark - Vault Management

+ (BOOL)createVaultWithName:(NSString *)vaultName
                     atPath:(NSString *)vaultPath
              usingPassword:(NSString *)password {
    if (!vaultPath.length || !password.length || !vaultName.length) {
        NSLog(@"Fail to create vault: invalid param");
        return NO;
    }
    
    NSString *vaultDirectory = [vaultPath stringByAppendingFormat:@"/%@.%@", vaultName, kVaultExtension];
    if ([VaultManager verifyVaultWithPath:vaultDirectory]) {
        NSLog(@"Fail to create vault: vault is existed");
        return NO;
    }
    
    // check directory
    BOOL isDirectory = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:vaultDirectory isDirectory:&isDirectory]) {
        if (!isDirectory) {
            return NO;
        }
        
    } else {
        NSError *error;
        BOOL isOK = [[NSFileManager defaultManager] createDirectoryAtPath:vaultDirectory withIntermediateDirectories:YES attributes:nil error:&error];
        if (!isOK || error) {
            NSLog(@"Fail to create vault directory : %@", error);
            return NO;
        }
    }
    
    // create empty index info
    NSError *error;
    NSData *emptyIndexData = [NSJSONSerialization dataWithJSONObject:@[] options:0 error:&error];
    if (!emptyIndexData) {
        NSLog(@"Fail to create empty index data: %@", error);
        return NO;
    }
    
    // encrypt index data
    error = nil;
    NSData *encryptedData = [RNEncryptor encryptData:emptyIndexData withSettings:kRNCryptorAES256Settings password:password error:&error];
    if (!encryptedData.length || error) {
        NSLog(@"Fail to encrypt empty index data: %@", error);
        return NO;
    }
    
    NSString *indexInfoFilePath = [vaultDirectory stringByAppendingPathComponent:kIndexInfoFileName];
    if ([encryptedData writeToFile:indexInfoFilePath atomically:YES]) {
        NSLog(@"Create vault success !!!");
        return YES;
        
    } else {
        NSLog(@"Fail to create vault !");
        return NO;
    }
}


+ (BOOL)verifyVaultWithPath:(NSString *)vaultPath {
    if (!vaultPath.length) {
        return NO;
    }
    
    BOOL isDirectory = NO;
    if (![[NSFileManager defaultManager] fileExistsAtPath:vaultPath isDirectory:&isDirectory]) {
        NSLog(@"vault directory is not existed");
        return NO;
    }
    if (!isDirectory) {
        return NO;
    }
    
    NSString *indexFilePath = [vaultPath stringByAppendingPathComponent:kIndexInfoFileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:indexFilePath]) {
        NSLog(@"index file is not existed");
        return NO;
    }
    
    unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:indexFilePath error:nil] fileSize];
    if (fileSize <= 0) {
        NSLog(@"Invalid file size: %llu", fileSize);
        return NO;
    }
    
    return YES;
}


@end






