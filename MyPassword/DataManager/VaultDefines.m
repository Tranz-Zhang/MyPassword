//
//  VaultDefines.m
//  MyPassword
//
//  Created by chance on 5/5/2017.
//  Copyright © 2017 bychance. All rights reserved.
//

#import "VaultDefines.h"

UIImage *IconImageWithType(PasswordIconType type) {
    switch (type) {
        case PasswordIconLogin:
            return [UIImage imageNamed:@"item_icon_login"];
        case PasswordIconCreditCard:
            return [UIImage imageNamed:@"item_icon_card"];
        case PasswordIconOthers:
            return [UIImage imageNamed:@"item_icon_others"];
        default:
            return [UIImage imageNamed:@"item_icon_default"];
    }
}


UIImage *SmallIconImageWithType(PasswordIconType type) {
    switch (type) {
        case PasswordIconLogin:
            return [UIImage imageNamed:@"item_icon_login"];
        case PasswordIconCreditCard:
            return [UIImage imageNamed:@"item_icon_card"];
        case PasswordIconOthers:
            return [UIImage imageNamed:@"item_icon_others_small"];
        default:
            return [UIImage imageNamed:@"item_icon_default_small"];
    }
}


NSString *GeneratePasswordUUID() {
    CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidString = CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuidRef));
    CFRelease(uuidRef);
    uuidString = [[uuidString uppercaseString] stringByReplacingOccurrencesOfString:@"-" withString:@""];
    return uuidString;
}



