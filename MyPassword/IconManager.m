//
//  IconManager.m
//  MyPassword
//
//  Created by chance on 1/20/17.
//  Copyright © 2017 bychance. All rights reserved.
//

#import "IconManager.h"

#define kIconDirectoryName @"password_icons"

#define kIconEdge 36

@implementation IconManager {
    dispatch_queue_t _iconProcessQueue;
    NSString *_cacheDirectory;
    NSURLSession *_urlSession;
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
        
        _urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        _iconProcessQueue = dispatch_queue_create("com.MyPassword.IconProcessQueue", DISPATCH_QUEUE_SERIAL);
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
    
    dispatch_async(_iconProcessQueue, ^{
        // get from local
//        UIImage *localImage = [self localImageWithURLString:urlString];
//        if (localImage) {
//            if (completion) {
//                NSLog(@"Get icon from local: %@", urlString);
//                completion(localImage);
//            }
//            return;
//        }
        
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
        
        NSLog(@"Get icon from network: %@", urlString);
        NSURL *iconURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/favicon.ico", [baseURL host]]];
        NSURLRequest *request = [NSURLRequest requestWithURL:iconURL];
        NSURLSessionDataTask *task = [_urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (!data.length || error) {
                NSLog(@"Fail to fetch icon: %@", error);
                return;
            }
            
            UIImage *iconImage = [self processImageWithData:UIImagePNGRepresentation([UIImage imageWithData:data])];
            BOOL isOK =[self cacheImageData:UIImagePNGRepresentation(iconImage) forURLString:urlString];
            
            NSLog(@"Cache image %@: %@", isOK ? @"OK" : @"Fail", isOK ? [NSString stringWithFormat:@"%.0fx%.0f", iconImage.size.width, iconImage.size.height] : urlString);
            if (completion) {
                dispatch_async(_iconProcessQueue, ^{
                    completion(iconImage);
//                    completion([UIImage imageWithData:data]);
                });
            }
        }];
        [task resume];
    });
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
    if (!imageData.length || !urlString.length) {
        return NO;
    }
    NSString *fileName = [self fileNameForURLString:urlString];
    NSString *filePath = [_cacheDirectory stringByAppendingPathComponent:fileName];
    
    BOOL isOK = [imageData writeToFile:filePath atomically:YES];
    return isOK;
}


- (NSString *)fileNameForURLString:(NSString *)urlString {
    return [NSString stringWithFormat:@"%lX", (unsigned long)[urlString hash]];
}


- (UIImage *)processImageWithData:(NSData *)imageData {
    if (!imageData.length) {
        return nil;
    }
    UIImage *originalImage = [UIImage imageWithData:imageData];
    UIImage *backgroundImage = [UIImage imageNamed:@"icon_background"];
    CGRect canvasRect = CGRectMake(0, 0, kIconEdge, kIconEdge);
    UIGraphicsBeginImageContextWithOptions(canvasRect.size, NO, [UIScreen mainScreen].scale);
    [backgroundImage drawInRect:canvasRect];
    CGRect iconRect = CGRectInset(canvasRect, 4, 4);
    [originalImage drawInRect:iconRect];
    UIImage *processedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return processedImage;
}



@end




