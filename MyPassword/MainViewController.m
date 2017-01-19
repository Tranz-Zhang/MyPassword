//
//  ViewController.m
//  MyPassword
//
//  Created by chance on 29/11/2016.
//  Copyright © 2016 bychance. All rights reserved.
//

#import <CommonCrypto/CommonCrypto.h>
#import "MainViewController.h"
#import "LoginViewController.h"
#import "RegistViewController.h"
#import "ContentViewController.h"
#import "VaultManager.h"

#define kUserDefaultKey_DefaultVaultName @"default_vault_name"


@interface MainViewController () <RegistViewControllerDelegate, LoginViewControllerDelegate, UIAlertViewDelegate> {
    ContentViewController *_contentVC;
    LoginViewController *_loginVC;
    
    NSString *_documentPath;
    VaultManager *_vault;
}

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *registView;
@property (weak, nonatomic) IBOutlet UIView *loginView;

@end


@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *vaultName = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultKey_DefaultVaultName];
    NSString *vaultPath = [_documentPath stringByAppendingFormat:@"/%@.%@", vaultName, kVaultExtension];
    if (vaultName && [VaultManager verifyVaultWithPath:vaultPath]) {
        // show login interface
        LoginViewController *loginVC = (LoginViewController *)[self childViewControllerWithClass:[LoginViewController class]];
        loginVC.accountName = vaultName;
        loginVC.vault = [[VaultManager alloc] initWithVaultPath:vaultPath];
        loginVC.delegate = self;
        
        [_registView removeFromSuperview];
        _registView = nil;
        [self removeChildViewControllerWithClass:[RegistViewController class]];
        
    } else  {
        // show regist interface
        RegistViewController *registVC = (RegistViewController *)[self childViewControllerWithClass:[RegistViewController class]];
        registVC.delegate = self;
        
        [_loginView removeFromSuperview];
        _loginView = nil;
        [self removeChildViewControllerWithClass:[LoginViewController class]];
    }
    
    _contentVC = (ContentViewController *)[self childViewControllerWithClass:[ContentViewController class]];
    
    /*
    if (!_vault) {
        NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *vaultPath = [documentPath stringByAppendingFormat:@"/%@.%@", @"chance", kVaultExtension];
        if (![VaultManager verifyVaultWithPath:vaultPath]) {
            BOOL isOK = [VaultManager createVaultWithName:@"chance" atPath:documentPath usingPassword:@"MyPassword"];
            if (isOK) {
                _vault = [[VaultManager alloc] initWithVaultPath:vaultPath];
            }
            
        } else {
            _vault = [[VaultManager alloc] initWithVaultPath:vaultPath];
        }
    }
    //*/
}


- (UIViewController *)childViewControllerWithClass:(Class)clazz {
    for (UIViewController *childVC in self.childViewControllers) {
        if ([childVC isKindOfClass:[clazz class]]) {
            return childVC;
        }
        if ([childVC isKindOfClass:[UINavigationController class]]) {
            UIViewController *rootVC = [[(UINavigationController *)childVC viewControllers] objectAtIndex:0];
            if ([rootVC isKindOfClass:[clazz class]]) {
                return rootVC;
            }
        }
    }
    
    return nil;
}


- (void)removeChildViewControllerWithClass:(Class)clazz {
    for (UIViewController *childVC in self.childViewControllers) {
        BOOL shouldRemove = NO;
        if ([childVC isKindOfClass:[clazz class]]) {
            shouldRemove = YES;
        }
        if ([childVC isKindOfClass:[UINavigationController class]]) {
            UIViewController *rootVC = [[(UINavigationController *)childVC viewControllers] objectAtIndex:0];
            if ([rootVC isKindOfClass:[clazz class]]) {
                shouldRemove = YES;
            }
        }
        if (shouldRemove) {
            [childVC removeFromParentViewController];
            break;
        }
    }
}


#pragma mark - regist
- (void)registViewController:(RegistViewController *)registVC
            didCreateAccount:(NSString *)accountName
                    password:(NSString *)password {
    NSString *vaultPath = [_documentPath stringByAppendingFormat:@"/%@.%@", accountName, kVaultExtension];
    // check duplicated names
    if ([VaultManager verifyVaultWithPath:vaultPath]) {
        NSString *message = [NSString stringWithFormat:@"Account name \'%@\' has already existed. Overwrite existed account?", accountName];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Duplicated Account" message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Overwrite" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"overwrite");
            [[NSFileManager defaultManager] removeItemAtPath:vaultPath error:nil];
            if ([self createVaultWithName:accountName password:password]) {
                _contentVC.vault = _vault;
                [_contentVC refreshList];
                [self dismissRegistView];
            }
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:ok];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    if ([self createVaultWithName:accountName password:password]) {
        _contentVC.vault = _vault;
        [_contentVC refreshList];
        [self dismissRegistView];
    }
}


- (BOOL)createVaultWithName:(NSString *)name password:(NSString *)password {
    NSString *vaultPath = [_documentPath stringByAppendingFormat:@"/%@.%@", name, kVaultExtension];
    BOOL isOK = [VaultManager createVaultWithName:name atPath:_documentPath usingPassword:password];
    if (isOK) {
        _vault = [[VaultManager alloc] initWithVaultPath:vaultPath];
        [_vault unlockWithPassword:password];
        // save vault name
        [[NSUserDefaults standardUserDefaults] setObject:name forKey:kUserDefaultKey_DefaultVaultName];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fail to create Account" message:@"Please try again. Or change another name." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    NSLog(@"Create vault: %@", isOK ? @"OK" : @"Fail");
    return isOK;
}


- (void)dismissRegistView {
    if (!_registView) {
        return;
    }
    [UIView animateWithDuration:0.3 animations:^{
        _registView.frame = CGRectOffset(_registView.frame, 0, CGRectGetHeight(_registView.frame));
        
    } completion:^(BOOL finished) {
        [_registView removeFromSuperview];
        _registView = nil;
        [self removeChildViewControllerWithClass:[RegistViewController class]];
    }];
}


#pragma mark - Login
- (void)loginViewControllerDidFinishLogin:(LoginViewController *)loginVC {
    _contentVC.vault = _vault;
    [_contentVC refreshList];
    [self dismissLoginView];
}


- (void)dismissLoginView {
    if (!_loginView) {
        return;
    }
    [UIView animateWithDuration:0.3 animations:^{
        _loginView.alpha = 0;
        
    } completion:^(BOOL finished) {
        [_loginView removeFromSuperview];
        _loginView = nil;
        [self removeChildViewControllerWithClass:[LoginViewController class]];
    }];
}


#pragma mark - Test



/*
- (void)testVaultManager {
    NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *vaultPath = [document stringByAppendingFormat:@"/chance.vault"];
    if (![VaultManager verifyVaultWithPath:vaultPath]) {
        [VaultManager createVaultWithName:@"chance" atPath:document usingPassword:@"pwd1234"];
        
    } else {
        VaultManager *vaultMgr = [[VaultManager alloc] initWithVaultPath:vaultPath];
        BOOL isOK = [vaultMgr unlockWithPassword:@"pwd1234"];
        NSLog(@"unlock vault: %@", isOK ? @"OK" : @"Fail");
    }
}


- (void)testJsonModel {
    NSString *dataPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    dataPath = [dataPath stringByAppendingFormat:@"/index_info_list"];
    
    IndexInfo *info = [IndexInfo new];
    info.title = @"hello me";
    info.iconURL = @"www.??";
    info.passwordUUID = @"1234325";
    NSLog(@"info: %@", [info toJSONString]);
    
    NSArray *jsonList = @[info, info];
    NSArray *dirList = [JSONModel arrayOfDictionariesFromModels:jsonList];
    
    NSData *indexListData = [NSJSONSerialization dataWithJSONObject:dirList options:0 error:nil];
    indexListData = [RNEncryptor encryptData:indexListData withSettings:kRNCryptorAES256Settings password:@"pwd1234" error:nil];
    
    [indexListData writeToFile:dataPath atomically:YES];
    
    NSData *readData = [NSData dataWithContentsOfFile:dataPath];
    readData = [RNDecryptor decryptData:readData withPassword:@"pwd1234" error:nil];
    NSLog(@"%@", dirList);
    NSArray<IndexInfo *> *models = [IndexInfo arrayOfModelsFromData:readData error:nil];
    NSLog(@"");
}


- (void)testEditing {
    PasswordInfo *item = [PasswordInfo new];
    item.title = @"Facebook";
    item.website = @"www.facebook.com";
    item.account = @"tranz.zhang@gmail.com";
    item.password = @"syncmaster";
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    EditViewController *editVC = [storyBoard instantiateViewControllerWithIdentifier:@"EditViewController"];
    editVC.delegate = self;
    editVC.password = item;
    UINavigationController *nv = [[UINavigationController alloc] initWithRootViewController:editVC];
    [self presentViewController:nv animated:YES completion:nil];
}



- (void)testRNCryptor {
    // ref: https://support.1password.com/1password-security/
    // ref: https://support.1password.com/pbkdf2/
    
    // generate keys
    RNCryptorKeyDerivationSettings keySettings = {
        .keySize = kCCKeySizeAES256,
        .saltSize = 32,
        .PBKDFAlgorithm = kCCPBKDF2,
        .PRF = kCCPRFHmacAlgSHA512,
        .rounds = 10000
    };
    NSData *fixedSalt = [@"XXXXXXXXXX_XXXXXXXXXX_XXXXXXXXXX" dataUsingEncoding:NSUTF8StringEncoding];
    //    NSData *key = [RNCryptor keyForPassword:@"MyPassword1234" salt:fixedSalt settings:keySettings];
    //    NSData *key = [@"MyPassword1234" dataUsingEncoding:NSUTF8StringEncoding];
    
    // encrypt
    NSData *text = [@"hello world" dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSData *encyptedData = [RNEncryptor encryptData:text withSettings:kRNCryptorAES256Settings password:@"MyPassword1234" error:&error];
    if (!error) {
        NSLog(@"EncryptedData: %@", encyptedData);
    } else {
        NSAssert(1, @"Fail to encrypt data");
    }
    
    // decrypt
    NSData *decrpytedData = [RNDecryptor decryptData:encyptedData withPassword:@"MyPassword1234" error:&error];
    if (!error) {
        NSString *decryptedText = [[NSString alloc] initWithData:decrpytedData encoding:NSUTF8StringEncoding];
        NSLog(@"Decrypted text: %@", decryptedText);
    }
}


- (void)oldTestMethods {
    // Make keys!
    NSString* myPass = @"MyPassword1234";
    NSData* myPassData = [myPass dataUsingEncoding:NSUTF8StringEncoding];
    
    NSData *_salt = [self generateSalt256];
    // How many rounds to use so that it takes 0.1s ?
    int rounds = 10000;//CCCalibratePBKDF(kCCPBKDF2, myPassData.length, _salt.length, kCCPRFHmacAlgSHA1, 32, 100);
    NSLog(@"Rounds: %d", rounds);
    // Open CommonKeyDerivation.h for help
    unsigned char key[128];
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    CCKeyDerivationPBKDF(kCCPBKDF2, myPassData.bytes, myPassData.length, _salt.bytes, _salt.length, kCCPRFHmacAlgSHA1, rounds, key, 128);
    NSData *encrpytedPassword = [NSData dataWithBytes:key length:128];
    NSLog(@"Duration: %.5f", CFAbsoluteTimeGetCurrent() - startTime);
    NSLog(@"%@", encrpytedPassword);
}


// Makes a random 256-bit salt
- (NSData*)generateSalt256 {
    unsigned char salt[32];
    for (int i=0; i<32; i++) {
        salt[i] = (unsigned char)arc4random();
    }
    return [NSData dataWithBytes:salt length:32];
}
//*/

@end
