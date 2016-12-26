//
//  VaultCrpytionUtils.h
//  MyPassword
//
//  Created by chance on 12/26/16.
//  Copyright © 2016 bychance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RNCryptor_iOS.h"

extern const RNCryptorSettings kMyPasswordAES256Settings;

// Generate master key from user defined password
NSString *GenerateMasterKey(NSString *password);

// Cryptor Methods
NSData *DecryptFile(NSString *filePath, NSString *password );
BOOL EncryptDataToFile(NSData *data, NSString *filePath, NSString *password);

