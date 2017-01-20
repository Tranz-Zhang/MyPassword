//
//  IconManager.m
//  MyPassword
//
//  Created by chance on 1/20/17.
//  Copyright © 2017 bychance. All rights reserved.
//

#import "IconManager.h"

@implementation IconManager

+ (instancetype)shareManager {
    static IconManager *_shareInstance;
    if (!_shareInstance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _shareInstance = [[[self class] alloc] init];
        });
    }
    return _shareInstance;
}


- (void)fetchIconWithURLString:(NSString *)urlString
                    completion:(IconManagerFetchCompletion)completion {
    if (!urlString.length) {
        if (completion) {
            completion([UIImage imageNamed:@"item_placeholder"]);
        }
        return;
    }
    
    // get from local
    
    
    // get from network
    NSURL *baseURL;
    if (![urlString hasPrefix:@"http://"] &&
        ![urlString hasPrefix:@"https://"]) {
        baseURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", urlString]];
    } else {
        baseURL = [NSURL URLWithString:urlString];
    }
    if (![baseURL host]) {
        if (completion) {
            completion([UIImage imageNamed:@"item_placeholder"]);
        }
        return;
    }
    
    NSURL *iconURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/favicon.ico", [baseURL host]]];
    
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.google.com/favicon.ico"]];
    
    NSURLSessionDataTask *task = [urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"");
        
    }];
    [task resume];
}



@end



