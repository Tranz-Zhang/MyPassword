//
//  PasswordItem.m
//  MyPassword
//
//  Created by chance on 24/12/2016.
//  Copyright © 2016 bychance. All rights reserved.
//

#import "PasswordItem.h"

@implementation PasswordItem

- (id)copyWithZone:(NSZone *)zone {
    PasswordItem *item = [[PasswordItem allocWithZone:zone] init];
    item.UUID = [_UUID copy];
    item.title = [_title copy];
    item.website = [_website copy];
    item.account = [_account copy];
    item.password = [_password copy];
    item.updatedDate = _updatedDate;
    item.createdDate = _createdDate;
    
    return item;
}


- (BOOL)isEqual:(PasswordItem *)object {
    return [_UUID isEqualToString:object.UUID];
}


- (NSUInteger)hash {
    return [_UUID hash];
}


@end
