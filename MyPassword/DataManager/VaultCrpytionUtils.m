//
//  VaultCrpytionUtils.m
//  MyPassword
//
//  Created by chance on 12/26/16.
//  Copyright © 2016 bychance. All rights reserved.
//

#import <CommonCrypto/CommonCrypto.h>
#import "VaultCrpytionUtils.h"

#define kDefaultPBKDFRounds 30000
const RNCryptorSettings kMyPasswordAES256Settings = {
    .algorithm = kCCAlgorithmAES128,
    .blockSize = kCCBlockSizeAES128,
    .IVSize = kCCBlockSizeAES128,
    .options = kCCOptionPKCS7Padding,
    .HMACAlgorithm = kCCHmacAlgSHA256,
    .HMACLength = CC_SHA256_DIGEST_LENGTH,
    
    .keySettings = {
        .keySize = kCCKeySizeAES256,
        .saltSize = 16,
        .PBKDFAlgorithm = kCCPBKDF2,
        .PRF = kCCPRFHmacAlgSHA1,
        .rounds = kDefaultPBKDFRounds
    },
    
    .HMACKeySettings = {
        .keySize = kCCKeySizeAES256,
        .saltSize = 16,
        .PBKDFAlgorithm = kCCPBKDF2,
        .PRF = kCCPRFHmacAlgSHA1,
        .rounds = kDefaultPBKDFRounds
    }
};



NSString *GenerateMasterKey(NSString *password) {
    RNCryptorKeyDerivationSettings settings = kMyPasswordAES256Settings.keySettings;
    NSData *salt = [RNCryptor randomDataOfLength:settings.saltSize];
    NSData *masterKeyData = [RNCryptor keyForPassword:password salt:salt settings:settings];
    return [masterKeyData base64EncodedStringWithOptions:0];
}


NSData *DecryptFile(NSString *filePath, NSString *password ) {
    if (!filePath.length || !password.length) {
        return nil;
    }
    
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    if (!fileData.length) {
        NSLog(@"Empty file data");
        return nil;
    }
    
    NSError *error;
    NSData *decrpytedData = [RNDecryptor decryptData:fileData
                                        withSettings:kMyPasswordAES256Settings
                                            password:password
                                               error:&error];
    if (!decrpytedData || error) {
        NSLog(@"Fail to decrypt data: %@", error);
        return nil;
    }
    
    return decrpytedData;
}


BOOL EncryptDataToFile(NSData *data, NSString *filePath, NSString *password) {
    if (!data || !filePath.length || !password.length) {
        return NO;
    }
    
    NSError *error;
    NSData *encryptedData = [RNEncryptor encryptData:data
                                        withSettings:kMyPasswordAES256Settings
                                            password:password
                                               error:&error];
    if (!encryptedData.length || error) {
        NSLog(@"Fail to encrypt empty vault data: %@", error);
        return NO;
    }
    
    if (![encryptedData writeToFile:filePath atomically:YES]) {
        NSLog(@"Fail to write encrypted data");
        return NO;
    }
    
    return YES;
}





