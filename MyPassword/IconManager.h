//
//  IconManager.h
//  MyPassword
//
//  Created by chance on 1/20/17.
//  Copyright © 2017 bychance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^IconManagerFetchCompletion) (UIImage *iconImage);

@interface IconManager : NSObject

+ (instancetype)shareManager;

- (void)fetchIconWithURLString:(NSString *)urlString
                    completion:(IconManagerFetchCompletion)completion;

@end
