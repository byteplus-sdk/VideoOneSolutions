// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "EffectUIResourceHelper.h"

static NSString *LICENSE_PATH = @"LicenseBag";
static NSString *COMPOSER_PATH = @"ComposeMakeup";
static NSString *FILTER_PATH = @"FilterResource";
static NSString *STICKER_PATH = @"StickerResource";
static NSString *MODEL_PATH = @"ModelResource";
static NSString *VIDEOSR_PATH = @"videovrsr";

static NSString *BUNDLE = @"bundle";
#define _CHECK_EFFECT_PATH(nodeName) \
if ([nodeName hasPrefix:NSHomeDirectory()] \
|| [nodeName hasPrefix:NSBundle.mainBundle.bundlePath] \
|| (self.rootDir && [nodeName hasPrefix:self.rootDir])) { \
    return nodeName; \
}

@interface EffectUIResourceHelper () {
    NSString            *_licensePrefix;
    NSString            *_composerPrefix;
    NSString            *_filterPrefix;
    NSString            *_stickerPrefix;
}

@end

@implementation EffectUIResourceHelper

- (BOOL)composerNodePathExist:(NSString *)nodeName {
    NSString *path = [self composerNodePath:nodeName];
    return path != nil && [NSFileManager.defaultManager fileExistsAtPath:path];
}

- (NSString *)composerNodePath:(NSString *)nodeName {
    _CHECK_EFFECT_PATH(nodeName);
    if (!_composerPrefix) {
        _composerPrefix = [[self resourcePathForBundle:COMPOSER_PATH] stringByAppendingPathComponent:@"ComposeMakeup"];
    }
    return [_composerPrefix stringByAppendingPathComponent:nodeName];
}

- (NSString *)filterPath:(NSString *)filterName {
    _CHECK_EFFECT_PATH(filterName);
    if (!_filterPrefix) {
        _filterPrefix = [[self resourcePathForBundle:FILTER_PATH] stringByAppendingPathComponent:@"Filter"];
    }
    return [_filterPrefix stringByAppendingPathComponent:filterName];
}

- (NSString *)stickerPath:(NSString *)stickerName {
    _CHECK_EFFECT_PATH(stickerName);
    if (!_stickerPrefix) {
        _stickerPrefix = [[self resourcePathForBundle:STICKER_PATH] stringByAppendingPathComponent:@"stickers"];
    }
    NSString *path = [_stickerPrefix stringByAppendingPathComponent:stickerName];
    if ([NSFileManager.defaultManager fileExistsAtPath:path]) {
        return path;
    }
    return [[self resourcePathForBundle:STICKER_PATH] stringByAppendingPathComponent:stickerName];
}

- (NSString *)composerDirPath {
    if (!_composerPrefix) {
        _composerPrefix = [[self resourcePathForBundle:COMPOSER_PATH] stringByAppendingPathComponent:@"ComposeMakeup"];
    }
    return [_composerPrefix stringByAppendingPathComponent:@"composer"];
}

- (NSString *)resourcePathForBundle:(NSString *)bundleName {
    _CHECK_EFFECT_PATH(bundleName);
    if ([self rootDir] == nil) {
        return [[NSBundle mainBundle] pathForResource:bundleName ofType:BUNDLE];
    }
    return [[self rootDir] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", bundleName, BUNDLE]];
}

- (NSString *)modelPath {
    if (!_modelPath) {
        _modelPath = [self resourcePathForBundle:MODEL_PATH];
    }
    return _modelPath;
}

- (NSString *)rootDir {
    if (!_rootDir) {
        _rootDir = NSBundle.mainBundle.bundlePath;
    }
    return _rootDir;
}

- (NSString *)videoSRModelPath {
    return [self resourcePathForBundle:VIDEOSR_PATH];
}

- (BOOL)isFileExistAt:(NSString *)path isDir:(BOOL)isDir {
    BOOL fileIsDir = NO;
    return path != nil
    && [NSFileManager.defaultManager fileExistsAtPath:path isDirectory:&fileIsDir]
    && fileIsDir == isDir;
}

- (NSString *)findLicenseFileInDir:(NSString *)dir licenseName:(NSString *__autoreleasing *)licenseName {
    BOOL isDir = NO;
    if (dir == nil || ![NSFileManager.defaultManager fileExistsAtPath:dir isDirectory:&isDir] || !isDir) {
        return nil;
    }
    NSArray <NSString *>* allLicense = [[[NSFileManager defaultManager] enumeratorAtPath:dir] allObjects];
    NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
    NSString *subLineBundleID = [bundleID stringByReplacingOccurrencesOfString:@"." withString:@"_"];
    __block NSString *licName = nil;
    [allLicense enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj containsString:bundleID] || [obj containsString:subLineBundleID]) {
            licName = obj;
            *stop = YES;
        }
    }];
    if (licName == nil) {
        return nil;
    }
    if (licenseName != nil) {
        *licenseName = licName;
    }
    return [dir stringByAppendingPathComponent:licName];
}

- (NSString *)findLicenseInMainBundleLicenseName:(NSString *__autoreleasing *)licenseName {
    NSString *path = [self findLicenseFileInDir:NSBundle.mainBundle.bundlePath licenseName:licenseName];
    if (![self isFileExistAt:path isDir:NO]) {
        NSString *licenseBundle = [NSBundle.mainBundle pathForResource:@"LicenseBag" ofType:@"bundle"];
        path = [self findLicenseFileInDir:licenseBundle licenseName:licenseName];
    }
    return path;
}
@end
