// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELFileDownloader.h"
#import "VELAlertManager.h"
#import "VELCommonDefine.h"
#import "VELUIToast.h"
#import <AFNetworking/AFNetworking.h>
#import <CommonCrypto/CommonDigest.h>
#import <ToolKit/Localizator.h>
static NSMapTable *vel_file_download_loading_toast = nil;
@interface VELFileDownloadItem ()
@property (nonatomic, copy) NSString *identifier;
@property (atomic, copy) void (^progressBlock)(CGFloat progress);
@property (atomic, copy) void (^completionBlock)(VELFileDownloadItem *,BOOL, NSError * _Nullable);
@property (nonatomic, copy, readwrite) NSString *url;
@property (nonatomic, strong) NSURLSessionDownloadTask *task;
@property (nonatomic, strong, readwrite) NSProgress *progress;
@property (nonatomic, copy, readwrite) NSString *filePath;
@property (nonatomic, copy, readwrite) NSString *fileName;
@property (nonatomic, strong) NSError *error;
@end

@implementation VELFileDownloadItem
+ (instancetype)itemWithUrl:(NSString *)url fileName:(NSString *)fileName {
    VELFileDownloadItem *item = [[self alloc] init];
    item.url = url;
    item.fileName = fileName;
    return item;
}

- (void)setProgress:(NSProgress *)progress {
    [self removeProgressObserver:_progress];
    _progress = progress;
    [self addProgressObserver:_progress];
}

- (void)removeProgressObserver:(NSProgress *)progress {
    if (progress == nil) {
        return;
    }
    [progress removeObserver:self forKeyPath:@"fractionCompleted"];
}

- (void)addProgressObserver:(NSProgress *)progress {
    if (progress == nil) {
        return;
    }
    [progress addObserver:self forKeyPath:@"fractionCompleted" options:(NSKeyValueObservingOptionNew) context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"fractionCompleted"]) {
        if (self.progressBlock) {
            self.progressBlock([change[NSKeyValueChangeNewKey] floatValue]);
        }
    }
}
- (void)dealloc {
    [self removeProgressObserver:_progress];
    _progress = nil;
}
@end

@interface VELFileDownloader ()
@property (nonatomic, copy) NSString *rootDir;
@property (nonatomic, strong) NSMutableDictionary <NSString *, id> *downloadItems;
@property (nonatomic, strong) AFURLSessionManager *sessionManager;
@end
@implementation VELFileDownloader
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static VELFileDownloader *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
        
        instance.downloadItems = [[NSMutableDictionary alloc] initWithCapacity:10];
        instance.sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:nil];
    });
    return instance;
}
+ (NSString *)filePathWithFileName:(NSString *)fileName {
    return [[self sharedInstance] filePathWithFileName:fileName];
}
+ (BOOL)fileExistWithFileName:(NSString *)fileName {
    return [[self sharedInstance] fileExistWithFileName:fileName];
}
- (NSString *)filePathWithFileName:(NSString *)fileName {
    return [self.rootDir stringByAppendingPathComponent:fileName];
}
- (BOOL)fileExistWithFileName:(NSString *)fileName {
    return [NSFileManager.defaultManager fileExistsAtPath:[self filePathWithFileName:fileName]];
}

+ (void)checkUrl:(NSString *)url hostIsValid:(void (^)(BOOL isValid))completion {
    [[self sharedInstance] checkUrl:url hostIsValid:completion];
}

- (void)checkUrl:(NSString *)url hostIsValid:(void (^)(BOOL isValid))completion {
    [self getHead:url completion:^(NSInteger size, BOOL isValid) {
        if (completion) {
            completion(isValid);
        }
    }];
}

- (void)getHead:(NSString *)url completion:(void (^)(NSInteger size, BOOL isValid))completion {
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    req.HTTPMethod = @"HEAD";
    [[NSURLSession.sharedSession dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            NSNumber *lengthObj =  [httpResponse.allHeaderFields valueForKey:@"Content-Length"];
            long long contentLength = lengthObj ? [lengthObj longLongValue] : httpResponse.expectedContentLength;
            if (completion) {
                if (error != nil || ![httpResponse isKindOfClass:NSHTTPURLResponse.class] || httpResponse.statusCode != 200) {
                    completion(contentLength, NO);
                } else {
                    completion(contentLength, YES);
                }
            }
        });
    }] resume];
}

+ (void)downloadUrl:(NSString *)url fileName:(NSString *)fileName progressBlock:(void (^)(CGFloat))progressBlock completionBlock:(void (^)(VELFileDownloadItem *, BOOL, NSError * _Nullable))completionBlock {
    vel_sync_main_queue(^{
        if (vel_file_download_loading_toast == nil) {
            vel_file_download_loading_toast = [NSMapTable strongToWeakObjectsMapTable];
        }
    });
    [[self sharedInstance] downloadUrl:url showTipAlert:YES fileName:fileName progressBlock:progressBlock completionBlock:completionBlock];
}

- (void)downloadUrl:(NSString *)url showTipAlert:(BOOL)showAlert fileName:(NSString *)fileName progressBlock:(void (^)(CGFloat))progressBlock completionBlock:(void (^)(VELFileDownloadItem *, BOOL, NSError * _Nullable))completionBlock {
    
    if (showAlert) {
        [self getHead:url completion:^(NSInteger size, BOOL isValid) {
            [VELFileDownloader showDownloadAlertTip:fileName
                                               size:size
                                         completion:^(BOOL allowed) {
                if (!allowed) {
                    if (completionBlock) {
                        completionBlock(nil, NO, [NSError errorWithDomain:NSURLErrorDomain code:-10086 userInfo:@{
                            NSLocalizedDescriptionKey : @"user not allowed"
                        }]);
                    }
                } else {
                    [self _downloadUrl:url showTipAlert:showAlert fileName:fileName progressBlock:progressBlock completionBlock:completionBlock];
                }
            }];
        }];
    } else {
        [self _downloadUrl:url showTipAlert:showAlert fileName:fileName progressBlock:progressBlock completionBlock:completionBlock];
    }
}

- (VELFileDownloadItem *)_downloadUrl:(NSString *)url showTipAlert:(BOOL)showAlert fileName:(NSString *)fileName progressBlock:(void (^)(CGFloat))progressBlock completionBlock:(void (^)(VELFileDownloadItem *, BOOL, NSError * _Nullable))completionBlock {
    NSString *identifier = [self getIdentifier:url fileName:fileName];
    VELFileDownloadItem *item = nil;
    @synchronized (self) {
        item = (VELFileDownloadItem *)[self.downloadItems objectForKey:identifier];
    }
    if (item != nil) {
        item.progressBlock = progressBlock;
        item.completionBlock = completionBlock;
        return item;
    }
    item = [VELFileDownloadItem itemWithUrl:url fileName:fileName];
    item.progressBlock = progressBlock;
    item.completionBlock = completionBlock;
    item.identifier = identifier;
    item.filePath = [self.rootDir stringByAppendingPathComponent:fileName];
    if ([NSFileManager.defaultManager fileExistsAtPath:item.filePath]) {
        if (completionBlock) {
            completionBlock(item, YES, nil);
        }
        return item;
    }
    
    @synchronized (self) {
        [self.downloadItems setObject:item forKey:identifier];
    }
    __weak __typeof__(item)weakItem = item;
    NSString *tmpFile = [item.filePath stringByAppendingPathExtension:@".temp"];
    void(^DownloadCompletion)(NSURL *filePath, NSError *error) =
    ^(NSURL *filePath, NSError *error) {
        __strong __typeof__(weakItem)item = weakItem;
        if (error == nil) {
            [NSFileManager.defaultManager moveItemAtPath:tmpFile toPath:item.filePath error:&error];
        }
        item.error = error;
        if (item.completionBlock) {
            item.completionBlock(item, error == nil, error);
        }
        @synchronized (self) {
            [self.downloadItems removeObjectForKey:item.identifier];
        }
    };
    item.task = [self.sessionManager downloadTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] progress:^(NSProgress * _Nonnull downloadProgress) {
        __strong __typeof__(weakItem)item = weakItem;
        item.progress = downloadProgress;
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return [NSURL fileURLWithPath:tmpFile];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        VELUIToast *toast = [vel_file_download_loading_toast objectForKey:url];
        [vel_file_download_loading_toast removeObjectForKey:url];
        [toast hideWithAnimated:YES];
        DownloadCompletion(filePath, error);
    }];
    VELUIToast *toast = [vel_file_download_loading_toast objectForKey:url];
    if (toast == nil) {
           toast = [VELUIToast showLoading:@""];
           [vel_file_download_loading_toast setObject:toast forKey:url];
       }
    toast.contentView.text = LocalizedStringFromBundle(@"medialive_downloading", @"MediaLive") ;
    toast.contentView.detailText = fileName;
    [item.task resume];
    return item;
}

+ (void)showDownloadAlertTip:(NSString *)fileName size:(NSInteger)size completion:(void (^)(BOOL allowed))completion {
    NSString *message = [NSString stringWithFormat:@"%@ %@（%.2fMB）?", LocalizedStringFromBundle(@"medialive_whether_download", @"MediaLive"),fileName, size / 1024.0 / 1024.0];
    [[VELAlertManager shareManager] showWithMessage:message
                                            actions:@[
        [VELAlertAction actionWithTitle:LocalizedStringFromBundle(@"medialive_confirm", @"MediaLive") block:^(UIAlertAction * _Nonnull action) {
        completion(YES);
    }],
        [VELAlertAction actionWithTitle:LocalizedStringFromBundle(@"medialive_cancel", @"MediaLive") block:^(UIAlertAction * _Nonnull action) {
        completion(NO);
    }]]];
}

- (NSString *)md5ForString:(NSString *)string {
    const char* input = [string UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(input, (CC_LONG)strlen(input), result);
    NSMutableString *digest = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [digest appendFormat:@"%02x", result[i]];
    }
    return digest;
}

- (NSString *)getIdentifier:(NSString *)urlStr fileName:(NSString *)fileName {
    NSURL *url = [NSURL URLWithString:urlStr];
    return [self md5ForString:[NSString stringWithFormat:@"%@://%@/%@_%@", url.scheme, url.host, url.path, fileName]];
}

- (NSString *)rootDir {
    if (!_rootDir) {
        NSString *rootDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
        rootDir = [rootDir stringByAppendingPathComponent:@"VeLive"];
        BOOL isDir = NO;
        if (![NSFileManager.defaultManager fileExistsAtPath:rootDir isDirectory:&isDir]
            || !isDir) {
            [NSFileManager.defaultManager createDirectoryAtPath:rootDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        _rootDir = rootDir;
    }
    return _rootDir;
}
@end
