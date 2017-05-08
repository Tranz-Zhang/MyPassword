//
//  StoryboardLoader.m
//  MyPassword
//
//  Created by chance on 8/5/2017.
//  Copyright © 2017 bychance. All rights reserved.
//

#import "StoryboardLoader.h"

@implementation StoryboardLoader

+ (UIViewController *)loadViewController:(NSString *)viewControllerIdentifier
                            inStoryboard:(NSString *)storyboardName {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:storyboardName bundle:[NSBundle mainBundle]];
    if (!storyBoard) {
        return nil;
    }
    id viewController = nil;
    @try {
        viewController = [storyBoard instantiateViewControllerWithIdentifier:viewControllerIdentifier];
        
    } @catch (NSException *exception) {
        NSLog(@"StoryboardLoader fail to load : %@", exception);
        
    } @finally {
        return viewController;
    }
}

@end
