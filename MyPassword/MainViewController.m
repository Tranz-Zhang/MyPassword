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
#import "MainListViewController.h"
#import "ImportViewController.h"
#import "ChangePasswordViewController.h"
#import "VaultManager.h"
#import "StoryboardLoader.h"

#define kUserDefaultKey_LastExitTime @"LastExitTime"
#define kDurationToLockVault 120

@interface MainViewController () <RegistViewControllerDelegate, LoginViewControllerDelegate, UIAlertViewDelegate> {
    UINavigationController *_loginNC;
    UINavigationController *_registNC;
    UINavigationController *_mainListNC;
    UINavigationController *_importNC;
    
    NSString *_documentPath;
}

@end


@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *vaultName = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultKey_DefaultVaultName];
    NSString *vaultPath = [_documentPath stringByAppendingFormat:@"/%@.%@", vaultName, kVaultExtension];
    UIViewController *loginInterfaceVC = nil;
    if (vaultName && [VaultManager verifyVaultWithPath:vaultPath]) {
        // show login interface
        _vault = [[VaultManager alloc] initWithVaultPath:vaultPath];
        _loginNC = [StoryboardLoader loadViewController:@"LoginNavigationController"
                                           inStoryboard:@"Login"];
        if (_loginNC) {
            LoginViewController *loginVC = (LoginViewController *)_loginNC.viewControllers[0];
            loginVC.accountName = vaultName;
            loginVC.vault = _vault;
            loginVC.delegate = self;
        }
        loginInterfaceVC = _loginNC;
        
    } else  {
        // show regist interface
        _registNC = [StoryboardLoader loadViewController:@"RegistNavigationController"
                                            inStoryboard:@"Login"];
        if (_registNC) {
            RegistViewController *registVC = (RegistViewController *)_registNC.viewControllers[0];
            registVC.delegate = self;
        }
        loginInterfaceVC = _registNC;
    }
    
    if (! loginInterfaceVC) {
        NSLog(@"Fail to setup login interface");
        return;
    }
    
    // show first view
    [self addChildViewController:loginInterfaceVC];
    loginInterfaceVC.view.frame = self.view.bounds;
    loginInterfaceVC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:loginInterfaceVC.view];
    
    // setup content view
    _mainListNC = [StoryboardLoader loadViewController:@"MainListNavigationController"
                                          inStoryboard:@"MainList"];
    if (!_mainListNC) {
        NSLog(@"Error: Fail to load main list view");
        return;
    }
    [self addChildViewController:_mainListNC];
    _mainListNC.view.frame = self.view.bounds;
    _mainListNC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view insertSubview:_mainListNC.view atIndex:0];
    
    
    // add notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onDidFinishImportVault:)
                                                 name:kDidFinishImportVaultNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onChangePassword:)
                                                 name:kDidChangedPasswordNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onApplicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onApplicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}


- (void)onApplicationDidEnterBackground:(NSNotification *)notification {
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date]
                                              forKey:kUserDefaultKey_LastExitTime];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)onApplicationWillEnterForeground:(NSNotification *)notification {
    NSDate *lastExitDate = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultKey_LastExitTime];
    NSLog(@"%.2f", [lastExitDate timeIntervalSinceNow]);
    if ([[NSDate date] timeIntervalSinceDate:lastExitDate] > kDurationToLockVault) {
        [self logout];
    }
}


#pragma mark - regist
- (void)registViewController:(RegistViewController *)registVC
            didCreateAccount:(NSString *)accountName
                    password:(NSString *)password {
    NSString *vaultPath = [_documentPath stringByAppendingFormat:@"/%@.%@", accountName, kVaultExtension];
    // check duplicated names
    if ([VaultManager verifyVaultWithPath:vaultPath]) {
        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"MainList.AlertMessage.DuplicatedVault", nil), accountName];
        NSString *alertTitle = NSLocalizedString(@"MainList.AlertTitle.DuplicatedVault", nil);
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:alertTitle message:message preferredStyle:UIAlertControllerStyleAlert];
        NSString *actionTitle = NSLocalizedString(@"MainList.AlertButton01.DuplicatedVault", nil);
        UIAlertAction *ok = [UIAlertAction actionWithTitle:actionTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"overwrite");
            [[NSFileManager defaultManager] removeItemAtPath:vaultPath error:nil];
            if ([self createVaultWithName:accountName password:password]) {
                MainListViewController *mainListVC = _mainListNC.viewControllers[0];
                mainListVC.vault = _vault;
                [mainListVC refreshList];
                [self dismissRegistView];
            }
        }];
        NSString *cancelTitle = NSLocalizedString(@"MainList.AlertButton02.DuplicatedVault", nil);
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:ok];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    if ([self createVaultWithName:accountName password:password]) {
        MainListViewController *mainListVC = _mainListNC.viewControllers[0];
        mainListVC.vault = _vault;
        [mainListVC refreshList];
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
        NSString *alertTitle = NSLocalizedString(@"MainList.AlertTitle.CreateVault", nil);
        NSString *alertMessage = NSLocalizedString(@"MainList.AlertMessage.CreateVault", nil);
        NSString *buttonTitle = NSLocalizedString(@"MainList.AlertButton.CreateVault", nil);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle message:alertMessage delegate:nil cancelButtonTitle:buttonTitle otherButtonTitles:nil];
        [alert show];
    }
    NSLog(@"Create vault: %@", isOK ? @"OK" : @"Fail");
    return isOK;
}


- (void)dismissRegistView {
    if (!_registNC) {
        return;
    }
    [UIView animateWithDuration:0.3 animations:^{
        _registNC.view.frame = CGRectOffset(_registNC.view.frame, 0, CGRectGetHeight(_registNC.view.frame));
        
    } completion:^(BOOL finished) {
        [_registNC.view removeFromSuperview];
        [_registNC removeFromParentViewController];
        _registNC = nil;
    }];
}


#pragma mark - Login
- (void)loginViewControllerDidFinishLogin:(LoginViewController *)loginVC {
    MainListViewController *mainListVC = _mainListNC.viewControllers[0];
    mainListVC.vault = _vault;
    [mainListVC refreshList];
    [self dismissLoginView];
}


- (void)dismissLoginView {
    if (!_loginNC) {
        return;
    }
    [UIView animateWithDuration:0.3 animations:^{
        _loginNC.view.alpha = 0;
        
    } completion:^(BOOL finished) {
        [_loginNC.view removeFromSuperview];
        [_loginNC removeFromParentViewController];
        _loginNC = nil;
    }];
}


#pragma mark - Logout
- (void)logout {
    [_vault lock];
    if (!_loginNC) {
        _loginNC = [StoryboardLoader loadViewController:@"LoginNavigationController"
                                           inStoryboard:@"Login"];
        // show first view
        [self addChildViewController:_loginNC];
        _loginNC.view.frame = self.view.bounds;
        _loginNC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:_loginNC.view];
    }
    LoginViewController *loginVC = (LoginViewController *)_loginNC.viewControllers[0];
    loginVC.accountName = _vault.name;
    loginVC.vault = _vault;
    loginVC.delegate = self;
    
    MainListViewController *mainListVC = _mainListNC.viewControllers[0];
    mainListVC.vault = nil;
    [mainListVC refreshList];
    
    if (self.presentedViewController) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}


#pragma mark - OnImport
- (void)onDidFinishImportVault:(NSNotification *)notification {
    if (_registNC) {
        [_registNC.view removeFromSuperview];
        [_registNC removeFromParentViewController];
        _registNC = nil;
    }
    
    NSString *importedVaultPath = notification.userInfo[kImportedVaultPathKey];
    // update vault
    if (!_vault || ![_vault.vaultPath isEqualToString:importedVaultPath]) {
        _vault = [[VaultManager alloc] initWithVaultPath:importedVaultPath];
        
    } else {
        [_vault lock];
    }
    
    if (!_loginNC) {
        _loginNC = [StoryboardLoader loadViewController:@"LoginNavigationController"
                                           inStoryboard:@"Login"];
        // show first view
        [self addChildViewController:_loginNC];
        _loginNC.view.frame = self.view.bounds;
        _loginNC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:_loginNC.view];
    }
    LoginViewController *loginVC = (LoginViewController *)_loginNC.viewControllers[0];
    loginVC.accountName = _vault.name;
    loginVC.vault = _vault;
    loginVC.delegate = self;
    
    MainListViewController *mainListVC = _mainListNC.viewControllers[0];
    mainListVC.vault = nil;
    [mainListVC refreshList];
}


#pragma mark - OnChangePassword
- (void)onChangePassword:(NSNotification *)notification {
    [self logout];
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
