//
//  VaultDefines.m
//  MyPassword
//
//  Created by chance on 5/5/2017.
//  Copyright © 2017 bychance. All rights reserved.
//

#import "VaultDefines.h"

UIImage *IconImageWithType(PasswordType type) {
    switch (type) {
        case PasswordTypeLogin:
            return [UIImage imageNamed:@"item_icon_login"];
        case PasswordTypeBankAccount:
            return [UIImage imageNamed:@"item_icon_card"];
        case PasswordTypeOthers:
            return [UIImage imageNamed:@"item_icon_others"];
        default:
            return [UIImage imageNamed:@"default_boundary"];
    }
}


UIImage *SmallIconImageWithType(PasswordType type) {
    switch (type) {
        case PasswordTypeLogin:
            return [UIImage imageNamed:@"item_icon_login_small"];
        case PasswordTypeBankAccount:
            return [UIImage imageNamed:@"item_icon_card_small"];
        case PasswordTypeOthers:
            return [UIImage imageNamed:@"item_icon_others_small"];
        default:
            return [UIImage imageNamed:@"default_boundary"];
    }
}


UIColor *StyleColorWithType(PasswordType type) {
    switch (type) {
        case PasswordTypeLogin:
            return [UIColor colorWithHue:203/360.f saturation:0.57 brightness:0.70 alpha:1];
            
        case PasswordTypeBankAccount:
            return [UIColor colorWithHue:13/360.f saturation:62 brightness:0.78 alpha:1];
            
        case PasswordTypeOthers:
            return [UIColor darkGrayColor];
            
        default:
            return [UIColor darkGrayColor];
    }
}


NSString *GeneratePasswordUUID() {
    CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidString = CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuidRef));
    CFRelease(uuidRef);
    uuidString = [[uuidString uppercaseString] stringByReplacingOccurrencesOfString:@"-" withString:@""];
    return uuidString;
}



