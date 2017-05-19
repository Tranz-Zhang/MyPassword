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
        if ([vaultPath hasSuffix:kVaultExtension]) {
            _name = [[vaultPath lastPathComponent] stringByDeletingPathExtension];
        }
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

- (BOOL)changePassword:(NSString *)newPassword {
    if (_isLocked || !newPassword.length) {
        return NO;
    }
    
    // remove old
    NSString *vaultInfoFilePath = [_vaultPath stringByAppendingPathComponent:kVaultInfoFileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:vaultInfoFilePath]) {
        NSError *error;
        BOOL isOK = [[NSFileManager defaultManager] removeItemAtPath:vaultInfoFilePath error:&error];
        NSLog(@"Remove old vault info: %@", isOK ? @"OK" : error);
    }
    
    // write to file
    NSData *vaultData = [_vaultInfo toJSONData];
    BOOL isOK = EncryptDataToFile(vaultData, vaultInfoFilePath, newPassword);
    NSLog(@"change password: %@", isOK ? @"OK" : @"Fail");
    _isLocked = isOK;
    return isOK;
}

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
    NSArray *indexList;
    NSString *indexInfoFilePath = [_vaultPath stringByAppendingPathComponent:kIndexInfoFileName];
    NSData *indexData = DecryptFile(indexInfoFilePath ,_vaultInfo.masterKey);
    if (indexData.length) {
         indexList = [IndexInfo arrayOfModelsFromData:indexData error:nil];
    }
    _indexInfoList = [NSArray arrayWithArray:indexList];
    
#warning TODO: clean up password items which has no index info
    
    _isLocked = NO;
    return YES;
}


- (void)lock {
    _isLocked = YES;
    _indexInfoList = nil;
    _vaultInfo = nil;
    
}


- (BOOL)verifyPassword:(NSString *)password {
    NSString *vaultInfoFilePath = [_vaultPath stringByAppendingPathComponent:kVaultInfoFileName];
    NSData *vaultInfoData = DecryptFile(vaultInfoFilePath, password);
    return vaultInfoData != nil;
}


#pragma mark - data

- (NSArray<IndexInfo *> *)indexInfoList {
    return _indexInfoList;
}


- (PasswordInfo *)passwordInfoWithUUID:(NSString *)passwordUUID {
    if (_isLocked || !passwordUUID.length) {
        return nil;
    }
    
    NSString *filePath = [[self dataDirectory] stringByAppendingPathComponent:passwordUUID];
    NSData *passwordData = DecryptFile(filePath, _vaultInfo.masterKey);
    if (!passwordData.length) {
        NSLog(@"Error: nil password data");
        return nil;
    }
    NSError *error;
    PasswordInfo *info = [[PasswordInfo alloc] initWithData:passwordData error:&error];
    if (error) {
        NSLog(@"Error parsing data: %@", error);
        return nil;
    }
    return info;
}


- (BOOL)addPasswordInfo:(PasswordInfo *)passwordInfo {
    if (!passwordInfo.account.length || !passwordInfo.password.length || _isLocked) {
        NSLog(@"Fail to add password info: invalid password info");
        return NO;
    }
    
    // check passwordInfo
    if (!passwordInfo.UUID) {
        passwordInfo.UUID = [self generateUUID];
        
    } else {
        // check if uuid duplicated
        for (IndexInfo *indexInfo in _indexInfoList) {
            if ([indexInfo.passwordUUID isEqualToString:passwordInfo.UUID]) {
                return NO;
            }
        }
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
        indexInfo.passwordType = passwordInfo.type;
        NSMutableArray *tempList = [NSMutableArray arrayWithArray:_indexInfoList];
        [tempList addObject:indexInfo];
        
        isOK = [self saveIndexInfoList:[tempList copy]];
        if (isOK) {
            _indexInfoList = tempList.copy;
            
        } else {
            // remove password item
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
    }
    
    NSLog(@"add password: %@", isOK ? @"OK" : @"Fail");
    return isOK;
}


- (BOOL)updatePasswordInfo:(PasswordInfo *)passwordInfo {
    if (!passwordInfo.account.length ||
        !passwordInfo.password.length ||
        !passwordInfo.UUID.length ||
        _isLocked) {
        NSLog(@"Fail to update password info: invalid password info");
        return NO;
    }
    
    NSString *filePath = [[self dataDirectory] stringByAppendingPathComponent:passwordInfo.UUID];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSLog(@"Can not find password file");
        return NO;
    }
    
    // save to file
    passwordInfo.updatedDate = [[NSDate date] timeIntervalSince1970];
    NSData *passwordData = [passwordInfo toJSONData];
    BOOL isOK = EncryptDataToFile(passwordData, filePath, _vaultInfo.masterKey);
    if (isOK) {
        // update index info
        for (IndexInfo *info in _indexInfoList) {
            if ([info.passwordUUID isEqualToString:passwordInfo.UUID]) {
                info.title = passwordInfo.title;
                info.passwordType = passwordInfo.type;
            }
        }
        
        isOK = [self saveIndexInfoList:_indexInfoList];
    }
    
    NSLog(@"update password: %@", isOK ? @"OK" : @"Fail");
    return isOK;
}


- (BOOL)deletePasswordWithUUID:(NSString *)passwordUUID {
    if (!passwordUUID.length || _isLocked) {
        NSLog(@"Fail to update password info: invalid password info");
        return NO;
    }
    
    IndexInfo *deletedIndexInfo = nil;
    for (IndexInfo *indexInfo in _indexInfoList) {
        if ([indexInfo.passwordUUID isEqualToString:passwordUUID]) {
            deletedIndexInfo = indexInfo;
            break;
        }
    }
    if (deletedIndexInfo) {
        NSMutableArray *tempList = [_indexInfoList mutableCopy];
        [tempList removeObject:deletedIndexInfo];
        
        if ([self saveIndexInfoList:[tempList copy]]) {
            _indexInfoList = tempList.copy;
            
        } else {
            return NO;
        }
    }
    
    NSString *filePath = [[self dataDirectory] stringByAppendingPathComponent:passwordUUID];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSError *error;
        BOOL isOK = [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
        NSLog(@"Remove password file: %@", isOK ? @"OK" : error);
        return isOK;
    }
    
    return YES;
}


- (NSString *)generateUUID {
    NSString *uuidString = [[NSUUID UUID] UUIDString];
    return [uuidString stringByReplacingOccurrencesOfString:@"-" withString:@""];
}


- (BOOL)saveIndexInfoList:(NSArray <IndexInfo *> *)indexList {
    NSArray *jsonIndexList = [IndexInfo arrayOfDictionariesFromModels:indexList];
    NSData *indexListData = [NSJSONSerialization dataWithJSONObject:jsonIndexList options:0 error:nil];
    NSString *indexInfoFilePath = [_vaultPath stringByAppendingPathComponent:kIndexInfoFileName];
    BOOL isOK = EncryptDataToFile(indexListData, indexInfoFilePath, _vaultInfo.masterKey);
    NSLog(@"Save index list data: %@", isOK ? @"OK" : @"Fail");
    return isOK;
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
    
//    // write test index
//    if (isOK) {
//        IndexInfo *info = [IndexInfo new];
//        info.title = @"hello me";
//        info.iconURL = @"www.??";
//        info.passwordUUID = @"1234325";
//        NSLog(@"info: %@", [info toJSONString]);
//        
//        NSArray *jsonList = @[info, info];
//        NSArray *dirList = [JSONModel arrayOfDictionariesFromModels:jsonList];
//        
//        NSData *indexListData = [NSJSONSerialization dataWithJSONObject:dirList options:0 error:nil];
//        NSString *indexInfoFilePath = [vaultDirectory stringByAppendingPathComponent:kIndexInfoFileName];
//        BOOL ok = EncryptDataToFile(indexListData, indexInfoFilePath, vaultInfo.masterKey);
//        NSLog(@"Write test index info: %@", ok ? @"Success" : @"Fail !!!");
//    }
    
    NSLog(@"Create vault: %@", isOK ? @"Success" : @"Fail !!!");
    return isOK;
}


+ (BOOL)verifyVaultWithPath:(NSString *)vaultPath {
    if (![vaultPath hasSuffix:kVaultExtension]) {
        NSLog(@"Invaild vault suffix");
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






