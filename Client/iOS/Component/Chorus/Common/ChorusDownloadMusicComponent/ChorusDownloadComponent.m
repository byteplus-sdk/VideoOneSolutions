// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "ChorusDownloadComponent.h"
#import "AFNetworking.h"

@interface ChorusDownloadComponent ()

@property (nonatomic, strong) AFURLSessionManager *manager;

@end

@implementation ChorusDownloadComponent

+ (instancetype)shared {
    static ChorusDownloadComponent *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ChorusDownloadComponent alloc] init];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        self.manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    }
    return self;
}

+ (void)downloadWithURL:(NSString *)urlString filePath:(NSString *)filePath progress:(void (^)(NSProgress *downloadProgress))downloadProgressBlock complete:(void(^)(NSError *error))complete {
    if (!urlString) {
        NSError *error = [[NSError alloc] initWithDomain:@"Address does not exist" code:-1 userInfo:nil];
        !complete? :complete(error);
        return;
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        !complete? :complete(nil);
        return;
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [[[ChorusDownloadComponent shared].manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
        !downloadProgressBlock? :downloadProgressBlock(downloadProgress);
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return [NSURL fileURLWithPath:filePath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        !complete? :complete(error);
    }] resume];
}

+ (NSString *)getMP3FilePath:(NSString *)musicID {
    NSString *filePath = [[self basePathString] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", musicID]];
    return filePath;
}

+ (NSString *)getLRCFilePath:(NSString *)musicID {
    NSString *filePath = [[self basePathString] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", musicID, @"lrc"]];
    return filePath;
}

+ (NSString *)basePathString {
    NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSString *basePath = [cachePath stringByAppendingPathComponent:@"music"];
    
    BOOL isDir = NO;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:basePath isDirectory:&isDir];
    if (!(isDir && exists)) {
        [[NSFileManager defaultManager] createDirectoryAtPath:basePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return basePath;
}

@end
