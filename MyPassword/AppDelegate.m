//
//  AppDelegate.m
//  MyPassword
//
//  Created by chance on 29/11/2016.
//  Copyright © 2016 bychance. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // custom theme
    UIColor *themeColor = [UIColor colorWithHue:214 / 360.0f saturation:0.41 brightness:0.33 alpha:1];
//    self.window.tintColor = themeColor;
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : themeColor}];
    
    return YES;
}


@end
