//
//  IndexInfo.m
//  MyPassword
//
//  Created by chance on 24/12/2016.
//  Copyright © 2016 bychance. All rights reserved.
//

#import "IndexInfo.h"

@implementation IndexInfo

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    if ([propertyName isEqualToString:@"passwordUUID"]) {
        return NO;
    }
    return YES;
}

@end
