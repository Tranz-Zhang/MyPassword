//
//  IconManager.m
//  MyPassword
//
//  Created by chance on 1/20/17.
//  Copyright © 2017 bychance. All rights reserved.
//

#import "IconManager.h"

#define kIconDirectoryName @"password_icons"

@implementation IconManager {
    NSString *_cacheDirectory;
}


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


- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        cachePath = [cachePath stringByAppendingPathComponent:kIconDirectoryName];
        if (![[NSFileManager defaultManager] fileExistsAtPath:cachePath]) {
            NSError *error;
            BOOL isOK = [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:&error];
            if (!isOK || error) {
                NSLog(@"Fail to create icon directory: %@", error);
                
            } else {
                _cacheDirectory = cachePath;
            }
            
        } else {
            _cacheDirectory = cachePath;
        }
        
    }
    return self;
}


- (void)fetchIconWithURLString:(NSString *)urlString
                    completion:(IconManagerFetchCompletion)completion {
    if (!urlString.length) {
        if (completion) {
            completion([UIImage imageNamed:@"item_placeholder"]);
        }
        return;
    }
    NSLog(@"name: %@", [self fileNameForURLString:urlString]);
    
    return;
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


- (UIImage *)localImageWithURLString:(NSString *)urlString {
    if (!urlString.length || !_cacheDirectory.length) {
        return nil;
    }
    // check file location
    NSString *fileName = [self fileNameForURLString:urlString];
    NSString *filePath = [_cacheDirectory stringByAppendingPathComponent:fileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return nil;
    }
    
    UIImage *image = [UIImage imageWithContentsOfFile:filePath];
    return image;
}


- (BOOL)cacheImageData:(NSData *)imageData forURLString:(NSString *)urlString {
    return NO;
}


- (NSString *)fileNameForURLString:(NSString *)urlString {
    return [NSString stringWithFormat:@"%lX", (unsigned long)[urlString hash]];
}


@end




