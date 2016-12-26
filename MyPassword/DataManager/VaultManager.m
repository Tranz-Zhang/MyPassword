//
//  VaultManager.m
//  MyPassword
//
//  Created by chance on 12/20/16.
//  Copyright © 2016 bychance. All rights reserved.
//


#import "VaultManager.h"
#import "VaultCrpytionUtils.h"
#import "VaultInfo.h"

#define kCurrentVaultVersion 1
#define kVaultInfoFileName @"vault_info"
#define kIndexInfoFileName @"index_info"
#define kPasswordDataDirectoryName @"data"


@implementation VaultManager {
    VaultInfo *_vaultInfo;
    NSString *_dataDirectory;
    NSArray<IndexInfo *> *_indexInfoList;
}


- (instancetype)initWithVaultPath:(NSString *)vaultPath {
    self = [super init];
    if (self) {
        _isLocked = YES;
        _vaultPath = [vaultPath copy];
    }
    return self;
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


#pragma mark - lock & unlock

- (BOOL)unlockWithPassword:(NSString *)password {
    if (!_isLocked) {
        return YES;
    }
    if (!password.length || !_vaultPath.length) {
        return NO;
    }
    
    // get vault info
    NSString *vaultInfoFilePath = [_vaultPath stringByAppendingPathComponent:kVaultInfoFileName];
    NSData *vaultInfoData = DecryptFile(vaultInfoFilePath, password);
    if (!vaultInfoData) {
        return NO;
    }
    NSError *error;
    VaultInfo *vaultInfo = [[VaultInfo alloc] initWithData:vaultInfoData error:&error];
    if (error) {
        NSLog(@"Fail to parse vault info: %@", error);
        return NO;
    }
    _vaultInfo = vaultInfo;
    
    // get index info list
    NSString *indexInfoFilePath = [_vaultPath stringByAppendingPathComponent:kIndexInfoFileName];
    NSData *indexData = DecryptFile(indexInfoFilePath ,_vaultInfo.masterKey);
    if (indexData.length) {
        NSArray *indexList = [IndexInfo arrayOfModelsFromData:indexData error:nil];
        _indexInfoList = [NSArray arrayWithArray:indexList];
    }
    
    _isLocked = NO;
    return YES;
}


- (void)lock {
    _isLocked = YES;
    _indexInfoList = nil;
    _vaultInfo = nil;
    
}

#pragma mark - data

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


- (BOOL)addPasswordInfo:(PasswordInfo *)passwordInfo {
    if (!passwordInfo.account.length || !passwordInfo.password.length) {
        NSLog(@"Fail to add password info: invalid password info");
        return NO;
    }
    
    // check passwordInfo
    if (!passwordInfo.UUID) {
        passwordInfo.UUID = [self generateUUID];
    }
    if (passwordInfo.createdDate <= 0) {
        passwordInfo.createdDate = [[NSDate date] timeIntervalSince1970];
        passwordInfo.updatedDate = passwordInfo.createdDate;
    }
    
    NSData *passwordData = [passwordInfo toJSONData];
    NSString *filePath = [[self dataDirectory] stringByAppendingPathComponent:passwordInfo.UUID];
    BOOL isOK = EncryptDataToFile(passwordData, filePath, _vaultInfo.masterKey);
    
    // add index info
    if (isOK) {
        IndexInfo *indexInfo = [IndexInfo new];
        indexInfo.title = passwordInfo.title;
        indexInfo.passwordUUID = passwordInfo.UUID;
        indexInfo.iconURL = passwordInfo.iconURL;
        NSMutableArray *tempList = [NSMutableArray arrayWithArray:_indexInfoList];
        [tempList addObject:indexInfo];
        _indexInfoList = tempList.copy;
        
        NSData *indexListData = [NSJSONSerialization dataWithJSONObject:_indexInfoList options:0 error:nil];
        NSString *indexInfoFilePath = [_vaultPath stringByAppendingPathComponent:kIndexInfoFileName];
        isOK = EncryptDataToFile(indexListData, indexInfoFilePath, _vaultInfo.masterKey);
    }
    
    NSLog(@"add password: %@", isOK ? @"OK" : @"Fail");
    return isOK;
}


- (BOOL)updatePasswordInfo:(PasswordInfo *)passwordInfo {
    return NO;
}


- (BOOL)deletePasswordInfo:(PasswordInfo *)passwordInfo {
    return NO;
}


- (NSString *)generateUUID {
    NSString *uuidString = [[NSUUID UUID] UUIDString];
    return [uuidString stringByReplacingOccurrencesOfString:@"-" withString:@""];
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
    
    // create vault info
    VaultInfo *vaultInfo = [VaultInfo new];
    vaultInfo.name = vaultName;
    vaultInfo.createdDate = [[NSDate date] timeIntervalSince1970];
    vaultInfo.version = kCurrentVaultVersion;
    vaultInfo.masterKey = GenerateMasterKey(password);
    
    // write to file
    NSData *vaultData = [vaultInfo toJSONData];
    NSString *vaultInfoFilePath = [vaultDirectory stringByAppendingPathComponent:kVaultInfoFileName];
    BOOL isOK = EncryptDataToFile(vaultData, vaultInfoFilePath, password);
    
    // write test index
    if (isOK) {
        IndexInfo *info = [IndexInfo new];
        info.title = @"hello me";
        info.iconURL = @"www.??";
        info.passwordUUID = @"1234325";
        NSLog(@"info: %@", [info toJSONString]);
        
        NSArray *jsonList = @[info, info];
        NSArray *dirList = [JSONModel arrayOfDictionariesFromModels:jsonList];
        
        NSData *indexListData = [NSJSONSerialization dataWithJSONObject:dirList options:0 error:nil];
        NSString *indexInfoFilePath = [vaultDirectory stringByAppendingPathComponent:kIndexInfoFileName];
        BOOL ok = EncryptDataToFile(indexListData, indexInfoFilePath, vaultInfo.masterKey);
        NSLog(@"Write test index info: %@", ok ? @"Success" : @"Fail !!!");
    }
    
    NSLog(@"Create vault: %@", isOK ? @"Success" : @"Fail !!!");
    return isOK;
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
    
    NSString *infoFilePath = [vaultPath stringByAppendingPathComponent:kVaultInfoFileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:infoFilePath]) {
        NSLog(@"vault info file is not existed");
        return NO;
    }
    
    unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:infoFilePath error:nil] fileSize];
    if (fileSize <= 0) {
        NSLog(@"Invalid file size: %llu", fileSize);
        return NO;
    }
    
    return YES;
}



@end






