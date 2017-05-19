//
//  VaultManagerTest.m
//  MyPassword
//
//  Created by chance on 12/26/16.
//  Copyright © 2016 bychance. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VaultManager.h"

@interface VaultManagerTest : XCTestCase

@end

@implementation VaultManagerTest  {
    NSString *_password;
}

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    _password = [[[NSUUID UUID] UUIDString] substringToIndex:8];
    BOOL isOK = [VaultManager createVaultWithName:@"DefaultTest" atPath:documentPath usingPassword:_password];
//    NSLog(@"Create default test vault: %@", isOK ? @"OK" : @"Fail");
    XCTAssert(isOK, @"Fail to create default test vault");
}


- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *vaultPath = [documentPath stringByAppendingFormat:@"/DefaultTest.%@", kVaultExtension];
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:vaultPath error:&error];
    if (error) {
        NSLog(@"Fail to tearDown: %@", error);
    }
    [super tearDown];
}


- (void)testDefaultVaultCreation {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *vaultName = [[[NSUUID UUID] UUIDString] substringToIndex:8];
    BOOL isOK = [VaultManager createVaultWithName:vaultName atPath:documentPath usingPassword:@"mypassword123"];
    XCTAssert(isOK, @"Fail to create vault");
    
    NSString *vaultPath = [documentPath stringByAppendingFormat:@"/%@.%@", vaultName, kVaultExtension];
    BOOL isDirectory = NO;
    BOOL fileExisted = [[NSFileManager defaultManager] fileExistsAtPath:vaultPath isDirectory:&isDirectory];
    XCTAssert(fileExisted && isDirectory, @"Invalid vault directory");
    
    // check vault info
    BOOL isVaild = [VaultManager verifyVaultWithPath:vaultPath];
    XCTAssert(isVaild, @"Verity fail");
}


- (void)testErrorVaultCreation {
    BOOL isOK = NO;
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *vaultName = [[[NSUUID UUID] UUIDString] substringToIndex:8];
    isOK = [VaultManager createVaultWithName:nil atPath:documentPath usingPassword:@"mypassword123"];
    XCTAssertFalse(isOK);
    isOK = [VaultManager createVaultWithName:vaultName atPath:@"" usingPassword:@"mypassword123"];
    XCTAssertFalse(isOK);
    isOK = [VaultManager createVaultWithName:vaultName atPath:documentPath usingPassword:@""];
    XCTAssertFalse(isOK);
}


- (void)testDuplicatedVaultCreation {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *vaultPath = [documentPath stringByAppendingFormat:@"/DefaultTest.%@", kVaultExtension];
    XCTAssert([VaultManager verifyVaultWithPath:vaultPath], @"Default test vault is no ready");
    
    BOOL isOK = [VaultManager createVaultWithName:@"DefaultTest" atPath:documentPath usingPassword:_password];
    XCTAssertFalse(isOK, @"Can not create duplicated vault");
}


- (void)testVaultLocking {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *vaultPath = [documentPath stringByAppendingFormat:@"/DefaultTest.%@", kVaultExtension];
    XCTAssert([VaultManager verifyVaultWithPath:vaultPath], @"Default test vault is no ready");
    
    VaultManager *vault = [[VaultManager alloc] initWithVaultPath:vaultPath];
    XCTAssertFalse([vault unlockWithPassword:nil], @"Should not unlock with nil password");
    XCTAssertTrue(vault.isLocked);
    XCTAssertFalse([vault unlockWithPassword:@""], @"Should not unlock with empty password");
    XCTAssertTrue(vault.isLocked);
    XCTAssertFalse([vault unlockWithPassword:@"hello"], @"Should not unlock with wrong password");
    XCTAssertTrue(vault.isLocked);
    XCTAssertTrue([vault unlockWithPassword:_password]);
    XCTAssertFalse(vault.isLocked);
    XCTAssertTrue([vault unlockWithPassword:nil]);
    XCTAssertFalse(vault.isLocked);
    
    // lock and unlock
    [vault lock];
    XCTAssertTrue(vault.isLocked);
    XCTAssertTrue([vault unlockWithPassword:_password]);
    XCTAssertFalse(vault.isLocked);
    
    NSString *invalidVaultPath = [documentPath stringByAppendingFormat:@"/InvalidVault.%@", kVaultExtension];
    VaultManager *invalidVault = [[VaultManager alloc] initWithVaultPath:invalidVaultPath];
    XCTAssertTrue(invalidVault.isLocked);
    XCTAssertFalse([invalidVault unlockWithPassword:_password]);
    XCTAssertTrue(invalidVault.isLocked);
}


- (void)testChangePassword {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *vaultPath = [documentPath stringByAppendingFormat:@"/DefaultTest.%@", kVaultExtension];
    XCTAssert([VaultManager verifyVaultWithPath:vaultPath], @"Default test vault is no ready");
    
    // unlock
    VaultManager *vault = [[VaultManager alloc] initWithVaultPath:vaultPath];
    XCTAssertTrue([vault unlockWithPassword:_password]);
    XCTAssertFalse(vault.isLocked);
    
    NSString *newPassword = @"New Password";
    XCTAssertFalse([vault changePassword:nil]);
    XCTAssertFalse([vault changePassword:@""]);
    XCTAssertTrue([vault changePassword:newPassword]);
    
    XCTAssertTrue(vault.isLocked);
    XCTAssertFalse([vault unlockWithPassword:_password]);
    XCTAssertTrue(vault.isLocked);
    XCTAssertTrue([vault unlockWithPassword:newPassword]);
    XCTAssertFalse(vault.isLocked);
    
    // reopen vault
    vault = nil;
    vault = [[VaultManager alloc] initWithVaultPath:vaultPath];
    XCTAssertTrue([vault unlockWithPassword:newPassword]);
}


- (void)testIndexInfoList {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *vaultPath = [documentPath stringByAppendingFormat:@"/DefaultTest.%@", kVaultExtension];
    XCTAssert([VaultManager verifyVaultWithPath:vaultPath], @"Default test vault is no ready");
    
    // unlock
    VaultManager *vault = [[VaultManager alloc] initWithVaultPath:vaultPath];
    XCTAssertNil(vault.indexInfoList);
    XCTAssertTrue([vault unlockWithPassword:_password]);
    XCTAssertNotNil(vault.indexInfoList);
    
    // lock
    [vault lock];
    XCTAssertNil(vault.indexInfoList);
}


- (void)testGetPasswordInfo {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *vaultPath = [documentPath stringByAppendingFormat:@"/DefaultTest.%@", kVaultExtension];
    XCTAssert([VaultManager verifyVaultWithPath:vaultPath], @"Default test vault is no ready");
    
    PasswordInfo *password = [PasswordInfo new];
    password.account = @"chance";
    password.password = @"Test Password";
    
    VaultManager *vault = [[VaultManager alloc] initWithVaultPath:vaultPath];
    [vault unlockWithPassword:_password];
    XCTAssertTrue([vault addPasswordInfo:password]);
    XCTAssertTrue(vault.indexInfoList.count == 1);
    
    // close and reopen vault
    vault = nil;
    vault = [[VaultManager alloc] initWithVaultPath:vaultPath];
    
    // unlock
    [vault unlockWithPassword:_password];
    IndexInfo *idxInfo = vault.indexInfoList[0];
    XCTAssertNil([vault passwordInfoWithUUID:@""]);
    XCTAssertNil([vault passwordInfoWithUUID:nil]);
    PasswordInfo *info = [vault passwordInfoWithUUID:idxInfo.passwordUUID];
    XCTAssertNotNil(info);
    XCTAssertEqualObjects(info.account, password.account);
    XCTAssertEqualObjects(info.password, password.password);
    
    [vault lock];
    XCTAssertNil([vault passwordInfoWithUUID:idxInfo.passwordUUID]);
}


- (void)testAddPassword {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *vaultPath = [documentPath stringByAppendingFormat:@"/DefaultTest.%@", kVaultExtension];
    XCTAssert([VaultManager verifyVaultWithPath:vaultPath], @"Default test vault is no ready");
    
    PasswordInfo *password = [PasswordInfo new];
    password.title = @"my password";
//    password.UUID = [[NSUUID UUID] UUIDString];
    password.account = @"chance";
    password.password = @"Test Password";
    password.iconType = PasswordTypeLogin;
    password.createdDate = [[NSDate date] timeIntervalSince1970];
    password.updatedDate = [[NSDate date] timeIntervalSince1970];
    
    VaultManager *vault = [[VaultManager alloc] initWithVaultPath:vaultPath];
    XCTAssertFalse([vault addPasswordInfo:password]);
    [vault unlockWithPassword:_password];
    XCTAssertTrue([vault addPasswordInfo:password]);
    XCTAssertTrue(vault.indexInfoList.count == 1);
    
    // close and reopen vault
    vault = nil;
    vault = [[VaultManager alloc] initWithVaultPath:vaultPath];
    [vault unlockWithPassword:_password];
    NSArray *indexInfoList = vault.indexInfoList;
    XCTAssertTrue(indexInfoList.count == 1);
    
    IndexInfo *idxInfo = indexInfoList[0];
    PasswordInfo *getPassword = [vault passwordInfoWithUUID:idxInfo.passwordUUID];
    XCTAssertNotNil(getPassword);
    
    XCTAssertTrue([getPassword.title isEqualToString:password.title]);
    XCTAssertTrue([getPassword.UUID isEqualToString:password.UUID]);
    XCTAssertTrue([getPassword.account isEqualToString:password.account]);
    XCTAssertTrue([getPassword.password isEqualToString:password.password]);
    XCTAssertTrue(getPassword.iconType == password.iconType);
    XCTAssertTrue(getPassword.createdDate == password.createdDate);
    XCTAssertTrue(getPassword.updatedDate == password.updatedDate);
}


- (void)testAddInvalidPassword {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *vaultPath = [documentPath stringByAppendingFormat:@"/DefaultTest.%@", kVaultExtension];
    XCTAssert([VaultManager verifyVaultWithPath:vaultPath], @"Default test vault is no ready");
    
    PasswordInfo *invalidPwd01 = [PasswordInfo new];
    invalidPwd01.account = @"";
    invalidPwd01.password = @"";
    
    PasswordInfo *invalidPwd02 = [PasswordInfo new];
    invalidPwd02.account = nil;
    invalidPwd02.password = @"haha";

    
    PasswordInfo *invalidPwd03 = [PasswordInfo new];
    invalidPwd02.account = @"chance";
    invalidPwd02.password = nil;
    
    PasswordInfo *validPwd = [PasswordInfo new];
    validPwd.account = @"chance";
    validPwd.password = @"my pwd";
    
    VaultManager *vault = [[VaultManager alloc] initWithVaultPath:vaultPath];
    XCTAssertFalse([vault addPasswordInfo:invalidPwd01]);
    [vault unlockWithPassword:_password];
    XCTAssertFalse([vault addPasswordInfo:invalidPwd01]);
    XCTAssertFalse([vault addPasswordInfo:invalidPwd02]);
    XCTAssertFalse([vault addPasswordInfo:invalidPwd03]);
    XCTAssertTrue([vault addPasswordInfo:validPwd]);
    
    PasswordInfo *duplidatePwd = [PasswordInfo new];
    duplidatePwd.UUID = validPwd.UUID;
    duplidatePwd.account = @"hah";
    duplidatePwd.password = @"psd";
    XCTAssertFalse([vault addPasswordInfo:duplidatePwd]);
    
}


- (void)testDeletePasswordInfo {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *vaultPath = [documentPath stringByAppendingFormat:@"/DefaultTest.%@", kVaultExtension];
    XCTAssert([VaultManager verifyVaultWithPath:vaultPath], @"Default test vault is no ready");
    
    PasswordInfo *password = [PasswordInfo new];
    password.account = @"chance";
    password.password = @"Test Password";
    
    VaultManager *vault = [[VaultManager alloc] initWithVaultPath:vaultPath];
    [vault unlockWithPassword:_password];
    XCTAssertTrue([vault addPasswordInfo:password]);
    XCTAssertTrue(vault.indexInfoList.count == 1);
    
    // close and reopen vault
    vault = nil;
    vault = [[VaultManager alloc] initWithVaultPath:vaultPath];
    
    [vault unlockWithPassword:_password];
    IndexInfo *idxInfo = vault.indexInfoList[0];
    XCTAssertNotNil([vault passwordInfoWithUUID:idxInfo.passwordUUID]);
    XCTAssertFalse([vault deletePasswordWithUUID:@""]);
    XCTAssertFalse([vault deletePasswordWithUUID:nil]);
    
    // lock and delete
    [vault lock];
    XCTAssertFalse([vault deletePasswordWithUUID:idxInfo.passwordUUID]);
    
    // unlock and delete
    [vault unlockWithPassword:_password];
    XCTAssertTrue([vault deletePasswordWithUUID:idxInfo.passwordUUID]);
    XCTAssert(vault.indexInfoList.count == 0);
    
    // close and reopen
    vault = [[VaultManager alloc] initWithVaultPath:vaultPath];
    [vault unlockWithPassword:_password];
    XCTAssert(vault.indexInfoList.count == 0);
}


- (void)testUpdatePasswordInfo {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *vaultPath = [documentPath stringByAppendingFormat:@"/DefaultTest.%@", kVaultExtension];
    XCTAssert([VaultManager verifyVaultWithPath:vaultPath], @"Default test vault is no ready");
    
    PasswordInfo *password = [PasswordInfo new];
    password.account = @"chance";
    password.password = @"Test Password";
    
    VaultManager *vault = [[VaultManager alloc] initWithVaultPath:vaultPath];
    [vault unlockWithPassword:_password];
    XCTAssertTrue([vault addPasswordInfo:password]);
    XCTAssertTrue(vault.indexInfoList.count == 1);
    
    // close and reopen vault
    vault = nil;
    vault = [[VaultManager alloc] initWithVaultPath:vaultPath];
    [vault unlockWithPassword:_password];
    
    IndexInfo *idxInfo = vault.indexInfoList[0];
    PasswordInfo *updatedPassword = [vault passwordInfoWithUUID:idxInfo.passwordUUID];
    XCTAssertNotNil(updatedPassword, @"Fail to get password");
    
    // lock and update
    [vault lock];
    XCTAssertFalse([vault updatePasswordInfo:password]);
    
    // test invalid updates
    [vault unlockWithPassword:_password];
    XCTAssertTrue([vault updatePasswordInfo:updatedPassword]);
    XCTAssertFalse([vault updatePasswordInfo:nil]);
    XCTAssertFalse([vault updatePasswordInfo:[PasswordInfo new]]);
    updatedPassword.account = @"";
    XCTAssertFalse([vault updatePasswordInfo:updatedPassword]);
    updatedPassword.account = @"chance";
    updatedPassword.password = @"";
    XCTAssertFalse([vault updatePasswordInfo:updatedPassword]);
    updatedPassword.password = @"hallo";
    NSString *originalUUID = updatedPassword.UUID;
    updatedPassword.UUID = [[NSUUID UUID] UUIDString];
    XCTAssertFalse([vault updatePasswordInfo:updatedPassword]);
    
    // actual update
    updatedPassword.UUID = originalUUID;
    updatedPassword.title = @"Changed password title";
    updatedPassword.account = @"another account";
    updatedPassword.password = @"another Password";
    updatedPassword.iconType = PasswordTypeCreditCard;
    XCTAssertTrue([vault updatePasswordInfo:[updatedPassword copy]]);
    // check actual update
    vault = nil;
    vault = [[VaultManager alloc] initWithVaultPath:vaultPath];
    [vault unlockWithPassword:_password];
    idxInfo = vault.indexInfoList[0];
    PasswordInfo *updatedPassword2 = [vault passwordInfoWithUUID:idxInfo.passwordUUID];
    XCTAssertTrue([updatedPassword2.title isEqualToString:updatedPassword.title]);
    XCTAssertTrue([updatedPassword2.UUID isEqualToString:updatedPassword.UUID]);
    XCTAssertTrue([updatedPassword2.account isEqualToString:updatedPassword.account]);
    XCTAssertTrue([updatedPassword2.password isEqualToString:updatedPassword.password]);
    XCTAssertTrue(updatedPassword2.iconType == updatedPassword.iconType);
    XCTAssertTrue(updatedPassword2.createdDate == updatedPassword.createdDate);
    XCTAssertTrue(updatedPassword2.updatedDate > updatedPassword.updatedDate);
    XCTAssertTrue([idxInfo.title isEqualToString:@"Changed password title"]);
    XCTAssertTrue(idxInfo.iconType == PasswordTypeCreditCard);
    
    // set nil update
    updatedPassword2.title = nil;
    updatedPassword2.iconType = 0;
    XCTAssertTrue([vault updatePasswordInfo:[updatedPassword2 copy]]);
    // check set nil update
    vault = nil;
    vault = [[VaultManager alloc] initWithVaultPath:vaultPath];
    [vault unlockWithPassword:_password];
    idxInfo = vault.indexInfoList[0];
    PasswordInfo *updatedPassword3 = [vault passwordInfoWithUUID:idxInfo.passwordUUID];
    XCTAssertNil(updatedPassword3.title);
    XCTAssertTrue(updatedPassword3.iconType == 0);
    XCTAssertTrue(updatedPassword3.updatedDate > updatedPassword2.updatedDate);
    XCTAssertNil(idxInfo.title);
    XCTAssertTrue(idxInfo.iconType == 0);
}


- (void)testPasswordWithCustomUUID {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *vaultPath = [documentPath stringByAppendingFormat:@"/DefaultTest.%@", kVaultExtension];
    XCTAssert([VaultManager verifyVaultWithPath:vaultPath], @"Default test vault is no ready");
    
    NSString *customUUID = @"AAABBB";
    PasswordInfo *password = [PasswordInfo new];
    password.title = @"my password";
    password.UUID = customUUID;
    password.account = @"chance";
    password.password = @"Test Password";
    password.iconType = PasswordTypeCreditCard;
    password.createdDate = [[NSDate date] timeIntervalSince1970];
    password.updatedDate = [[NSDate date] timeIntervalSince1970];
    
    VaultManager *vault = [[VaultManager alloc] initWithVaultPath:vaultPath];
    [vault unlockWithPassword:_password];
    XCTAssertTrue([vault addPasswordInfo:password]);
    
    vault = nil;
    vault = [[VaultManager alloc] initWithVaultPath:vaultPath];
    XCTAssertTrue([vault unlockWithPassword:_password]);
    
    // test get
    PasswordInfo *getPassword = [vault passwordInfoWithUUID:customUUID];
    XCTAssertNotNil(getPassword);
    
    // test update
    getPassword.title = @"comston Title";
    XCTAssertTrue([vault updatePasswordInfo:getPassword]);
    
    // test delete
    XCTAssertTrue([vault deletePasswordWithUUID:customUUID]);
}


- (void)testDuplicatedUUID {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *vaultPath = [documentPath stringByAppendingFormat:@"/DefaultTest.%@", kVaultExtension];
    XCTAssert([VaultManager verifyVaultWithPath:vaultPath], @"Default test vault is no ready");
    
    NSString *customUUID = @"AAABBB";
    PasswordInfo *password = [PasswordInfo new];
    password.UUID = customUUID;
    password.account = @"chance";
    password.password = @"Test Password";
    
    VaultManager *vault = [[VaultManager alloc] initWithVaultPath:vaultPath];
    [vault unlockWithPassword:_password];
    XCTAssertTrue([vault addPasswordInfo:password]);
    
    // password2
    PasswordInfo *password2 = [password copy];
    XCTAssertTrue(password != password2);
    XCTAssertFalse([vault addPasswordInfo:password2]);
    
    // duplicate update
    password2.account = @"new account";
    XCTAssertTrue([vault updatePasswordInfo:password2]);
    
    // delete
    XCTAssertTrue([vault deletePasswordWithUUID:customUUID]);
    XCTAssertTrue([vault deletePasswordWithUUID:customUUID]);
}


@end



