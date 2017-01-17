//
//  ViewController.m
//  MyPassword
//
//  Created by chance on 29/11/2016.
//  Copyright © 2016 bychance. All rights reserved.
//

#import <CommonCrypto/CommonCrypto.h>
#import "MainViewController.h"
#import "PasswordInfoCell.h"
#import "PasswordDetailCell.h"
#import "EditViewController.h"
#import "VaultManager.h"
#import "LoginViewController.h"

@interface MainViewController ()<UITableViewDelegate, UITableViewDataSource,
PasswordDetailCellDelegate, EditViewControllerDelegate, LoginViewControllerDelegate> {
    LoginViewController *_loginVC;
    __weak IBOutlet UITableView *_tableView;
    NSIndexPath *_detailIndexPath;
    NSArray *_infoList;
}

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    footerView.backgroundColor = [UIColor lightGrayColor];
    _tableView.tableFooterView = footerView;
    
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
    [_vault unlockWithPassword:@"MyPassword"];
    _infoList = [self.vault indexInfoList];
    
    NSLog(@"Vault %@", _vault.isLocked ? @"Locked" : @"Unlock!!!");
    
    _loginVC = [[LoginViewController alloc] init];
    _loginVC.view.frame = self.view.frame;
    _loginVC.delegate = self;
    [self.view addSubview:_loginVC.view];
}


#pragma mark - LoginViewController
- (void)loginViewControllerDidFinishLogin:(LoginViewController *)loginVC {
    [UIView animateWithDuration:0.5f animations:^{
        _loginVC.view.alpha = 0;
        
    } completion:^(BOOL finished) {
        [_loginVC.view removeFromSuperview];
        _loginVC = nil;
    }];
}


#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _infoList.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_detailIndexPath isEqual:indexPath]) {
        return 148;
    } else {
        return 60;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if ([indexPath isEqual:_detailIndexPath]) {
        PasswordDetailCell *detailCell = [tableView dequeueReusableCellWithIdentifier:@"PasswordDetailCell"
                                                                         forIndexPath:indexPath];
        detailCell.delegate = self;
        cell = detailCell;
        
    } else {
        PasswordInfoCell *infoCell = [tableView dequeueReusableCellWithIdentifier:@"PasswordInfoCell"];
        IndexInfo *info = _infoList[indexPath.row];
        infoCell.itemTitleLabel.text = info.title;
        cell = infoCell;
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *reloadRows = nil;
    if ([_detailIndexPath isEqual:indexPath]) {
        _detailIndexPath = nil;
        reloadRows = @[indexPath];
        
    } else {
        reloadRows = _detailIndexPath ? @[indexPath, _detailIndexPath] : @[indexPath];
        _detailIndexPath = indexPath;
    }
    [tableView reloadRowsAtIndexPaths:reloadRows withRowAnimation:UITableViewRowAnimationFade];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowPasswordDetail"]) {
         segue.destinationViewController.title = @"Detail";
        
    } else if ([segue.identifier isEqualToString:@"AddPassword"]) {
        UINavigationController *nv = segue.destinationViewController;
        EditViewController *editVC = nv.viewControllers[0];
        editVC.delegate = self;
    }
}


#pragma mark - PasswordDetailCellDelegate
- (void)passwordDetailCellDidClickEdit:(PasswordDetailCell *)cell {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    EditViewController *editVC = [storyBoard instantiateViewControllerWithIdentifier:@"EditViewController"];
    UINavigationController *nv = [[UINavigationController alloc] initWithRootViewController:editVC];
    [self presentViewController:nv animated:YES completion:nil];
}


#pragma mark - EditViewControllerDelegate

- (void)editViewController:(EditViewController *)vc didAddPassword:(PasswordInfo *)password {
    BOOL isOK = [self.vault addPasswordInfo:password];
    if (isOK) {
        _infoList = [self.vault indexInfoList];
        [_tableView reloadData];
    }
    
    NSLog(@"Add password: %@", isOK ? [password toDictionary] : @"Fail");
}


- (void)editViewController:(EditViewController *)vc didUpdatePassword:(PasswordInfo *)password {
    BOOL isOK = [self.vault updatePasswordInfo:password];
    if (isOK) {
        _infoList = [self.vault indexInfoList];
        [_tableView reloadData];
    }
    
    NSLog(@"Update password: %@", isOK ? [password toDictionary] : @"Fail");
}


#pragma mark - Test

- (IBAction)onTest:(id)sender {
//    [self testJsonModel];
//    [self testVaultManager];
//    [self testJsonModel];
//    [self testEditing];
    
}

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
