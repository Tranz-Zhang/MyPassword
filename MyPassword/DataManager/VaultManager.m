//
//  VaultManager.m
//  MyPassword
//
//  Created by chance on 12/20/16.
//  Copyright © 2016 bychance. All rights reserved.
//

#import <CommonCrypto/CommonCrypto.h>

#import "VaultManager.h"
#import "RNCryptor_iOS.h"
#import "VaultInfo.h"

#define kCurrentVaultVersion 1
#define kVaultInfoFileName @"vault_info"
#define kIndexInfoFileName @"index_info"
#define kPasswordDataDirectoryName @"data"

@implementation VaultManager {
    VaultInfo *_vaultInfo;
    NSString *_dataDirectory;
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
    _isLocked = NO;
    return YES;
}


- (void)lock {
    _isLocked = YES;
    _indexInfoList = nil;
}


- (NSArray<IndexInfo *> *)indexInfoList {
    return _indexInfoList;
}


- (PasswordInfo *)passwordInfoWithUUID:(NSString *)passwordUUID {
    if (_isLocked) {
        return nil;
    }
    
    NSString *filePath = [[self dataDirectory] stringByAppendingPathComponent:passwordUUID];
    NSData *passwordData = [NSData dataWithContentsOfFile:filePath];
    if (passwordData.length) {
        return nil;
    }
    
    // should keep password by text ???
    
    // password -> masterkey -> every password info
    // so should i add vault info ???
    
    return nil;
}


- (void)addPasswordInfo:(PasswordInfo *)passwordInfo {
    
}


- (void)updatePasswordInfo:(PasswordInfo *)passwordInfo {
    
}


- (void)deletePasswordInfo:(PasswordInfo *)passwordInfo {
    
}


- (NSString *)dataDirectory {
    @synchronized (self) {
        if (_dataDirectory.length) {
            return _dataDirectory;
        }
        
        // create password data directory
        NSError *error;
        NSString *dataDirectory = [_vaultPath stringByAppendingPathComponent:kPasswordDataDirectoryName];
        if (![[NSFileManager defaultManager] createDirectoryAtPath:dataDirectory withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSLog(@"Fail to create data directory: %@", error);
            return nil;
        }
        _dataDirectory = [dataDirectory copy];
        return _dataDirectory;
    }
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
    
    // create master key
    RNCryptorKeyDerivationSettings masterKeySettings = {
        .keySize = kCCKeySizeAES256,
        .saltSize = 32,
        .PBKDFAlgorithm = kCCPBKDF2,
        .PRF = kCCPRFHmacAlgSHA512,
        .rounds = 10000
    };
    NSData *salt = [RNCryptor randomDataOfLength:masterKeySettings.saltSize];
    NSData *masterKey = [RNCryptor keyForPassword:password salt:salt settings:masterKeySettings];
    
    // create vault info
    VaultInfo *vaultInfo = [VaultInfo new];
    vaultInfo.name = vaultName;
    vaultInfo.createdDate = [[NSDate date] timeIntervalSince1970];
    vaultInfo.version = kCurrentVaultVersion;
    vaultInfo.masterKey = masterKey;
    
    NSError *error = nil;
    NSData *encryptedData = [RNEncryptor encryptData:[vaultInfo toJSONData]
                                        withSettings:kRNCryptorAES256Settings
                                            password:password
                                               error:&error];
    if (!encryptedData.length || error) {
        NSLog(@"Fail to encrypt empty vault data: %@", error);
        return NO;
    }
    
    NSString *vaultInfoFilePath = [vaultDirectory stringByAppendingPathComponent:kVaultInfoFileName];
    if ([encryptedData writeToFile:vaultInfoFilePath atomically:YES]) {
        NSLog(@"Create vault success !!!");
        return YES;
        
    } else {
        NSLog(@"Fail to create vault !");
        return NO;
    }
    
//    // create empty index info
//    NSError *error = nil;
//    NSData *emptyIndexData = [NSJSONSerialization dataWithJSONObject:@[] options:0 error:&error];
//    if (!emptyIndexData) {
//        NSLog(@"Fail to create empty index data: %@", error);
//        return NO;
//    }
//    
//    // encrypt index data
//    error = nil;
//    NSData *encryptedData = [RNEncryptor encryptData:emptyIndexData withSettings:kRNCryptorAES256Settings password:password error:&error];
//    if (!encryptedData.length || error) {
//        NSLog(@"Fail to encrypt empty index data: %@", error);
//        return NO;
//    }
//    
//    NSString *indexInfoFilePath = [vaultDirectory stringByAppendingPathComponent:kIndexInfoFileName];
//    if ([encryptedData writeToFile:indexInfoFilePath atomically:YES]) {
//        NSLog(@"Create vault success !!!");
//        return YES;
//        
//    } else {
//        NSLog(@"Fail to create vault !");
//        return NO;
//    }
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






