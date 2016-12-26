//
//  PasswordInfo.m
//  MyPassword
//
//  Created by chance on 24/12/2016.
//  Copyright © 2016 bychance. All rights reserved.
//

#import "PasswordInfo.h"

@implementation PasswordInfo

- (id)copyWithZone:(NSZone *)zone {
    PasswordInfo *item = [[PasswordInfo allocWithZone:zone] init];
    item.UUID = [_UUID copy];
    item.title = [_title copy];
    item.website = [_website copy];
    item.account = [_account copy];
    item.password = [_password copy];
    item.updatedDate = _updatedDate;
    item.createdDate = _createdDate;
    
    return item;
}


- (BOOL)isEqual:(PasswordInfo *)object {
    return [_UUID isEqualToString:object.UUID];
}


- (NSUInteger)hash {
    return [_UUID hash];
}


@end
