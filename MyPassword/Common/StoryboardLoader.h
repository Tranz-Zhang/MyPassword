//
//  StoryboardLoader.h
//  MyPassword
//
//  Created by chance on 8/5/2017.
//  Copyright © 2017 bychance. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StoryboardLoader : NSObject

+ (__kindof UIViewController *)loadViewController:(NSString *)viewControllerIdentifier
                                     inStoryboard:(NSString *)storyboardName;

@end
