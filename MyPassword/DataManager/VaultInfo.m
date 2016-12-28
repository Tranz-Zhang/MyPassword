//
//  VaultInfo.m
//  MyPassword
//
//  Created by chance on 12/26/16.
//  Copyright © 2016 bychance. All rights reserved.
//

#import "VaultInfo.h"

@implementation VaultInfo

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    if ([propertyName isEqualToString:@"name"] ||
        [propertyName isEqualToString:@"masterKey"]) {
        return NO;
    }
    return YES;
}

@end
