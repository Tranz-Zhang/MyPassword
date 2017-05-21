//
//  AppDelegate.m
//  MyPassword
//
//  Created by chance on 29/11/2016.
//  Copyright © 2016 bychance. All rights reserved.
//

#import "AppDelegate.h"
#import "StoryboardLoader.h"
#import "ImportViewController.h"
#import "VaultDefines.h"

#import "SSZipArchive.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"%s", __FUNCTION__);
//    for (NSString *family in [UIFont familyNames]) {
//        NSLog(@"%@ - %@", family, [UIFont fontNamesForFamilyName:family]);
//    }
    
    char indexAlphabet = 'v';
    int range = 'a' - 'A';
    if ((indexAlphabet >= 'a' && indexAlphabet <= 'z') ||
        (indexAlphabet >= 'A' && indexAlphabet <= 'Z')) {
        NSLog(@"test: %@",[NSString stringWithFormat:@"%c", indexAlphabet > 'Z' ? indexAlphabet - 32 : indexAlphabet]);
    }
    
    // custom theme
    UIColor *themeColor = [UIColor colorWithHue:214 / 360.0f saturation:0.41 brightness:0.33 alpha:1];
    self.window.tintColor = themeColor;
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : themeColor,
                                                           NSFontAttributeName:[UIFont fontWithName:@"Copperplate" size:21]}];
    
    // move file to temporary directory
//    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"merge_one" withExtension:@"vault"];
//    NSError *error = nil;
//    NSString *toFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileURL.lastPathComponent];
//    BOOL isOK = NO;
//    if (![[NSFileManager defaultManager] fileExistsAtPath:toFilePath]) {
//        isOK = [[NSFileManager defaultManager] copyItemAtURL:fileURL
//                                                            toURL:[NSURL fileURLWithPath:toFilePath]
//                                                            error:&error];
//        NSLog(@"Move File %@: %@", fileURL.lastPathComponent, isOK ? @"OK" : error);
//        
//    } else {
//        isOK = YES;
//    }
//    
//    if (isOK) {
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            UINavigationController *importNV = [StoryboardLoader loadViewController:@"ImportNavigationController"
//                                                                       inStoryboard:@"Login"];
//            ImportViewController *importVC = importNV.viewControllers[0];
//            importVC.importFilePath = toFilePath;
//            [self.window.rootViewController presentViewController:importNV
//                                                         animated:YES
//                                                       completion:nil];
//        });
//    }
    
    return YES;
}


- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    NSLog(@"%s", __FUNCTION__);
    return [self onReceiveFile:url];
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    NSLog(@"%s", __FUNCTION__);
    return [self onReceiveFile:url];
}


- (BOOL)onReceiveFile:(NSURL *)fileURL {
    if (![[fileURL pathExtension] isEqualToString:kVaultExtension]) {
        NSLog(@"Invalid file extension: %@", fileURL);
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtURL:fileURL error:nil];
        NSLog(@"Remove file: %@", error ?: @"OK");
        return NO;
    }
    
    // move file to temporary directory
    NSError *error = nil;
    NSString *toFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileURL.lastPathComponent];
    BOOL isOK = [[NSFileManager defaultManager] moveItemAtURL:fileURL
                                                        toURL:[NSURL fileURLWithPath:toFilePath]
                                                        error:&error];
    NSLog(@"Move File %@: %@", fileURL.lastPathComponent, isOK ? @"OK" : error);
    
    UINavigationController *importNV = [StoryboardLoader loadViewController:@"ImportNavigationController"
                                                               inStoryboard:@"Login"];
    ImportViewController *importVC = importNV.viewControllers[0];
    importVC.importFilePath = toFilePath;
    [self.window.rootViewController presentViewController:importNV
                                                 animated:YES
                                               completion:nil];
    return YES;
}


@end
