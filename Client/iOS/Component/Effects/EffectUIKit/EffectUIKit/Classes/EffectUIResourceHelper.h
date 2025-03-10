// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#ifndef EffectUIResourceHelper_h
#define EffectUIResourceHelper_h

#import <Foundation/Foundation.h>

@interface EffectUIResourceHelper : NSObject
/// Root path, default NSBundle.mainBundle.bundlePath
@property (nonatomic, copy) NSString *rootDir;

/// The found model path
@property (nonatomic, copy) NSString *modelPath;


// Find the path according to the filter name
// @param filterName filter name
- (NSString *)filterPath:(NSString *)filterName;

// Find the path according to the sticker name
// @param stickerNamesticker name
- (NSString *)stickerPath:(NSString *)stickerName;

// Find the path according to the name of the special effect material
// @param nodeName Effect name
- (NSString *)composerNodePath:(NSString *)nodeName;

/// node exist
/// - Parameter nodePath: nodepaht
- (BOOL)composerNodePathExist:(NSString *)nodePath;

/// file is exist
- (BOOL)isFileExistAt:(NSString *)path isDir:(BOOL)isDir;

/// Find the license file with the same bundleID
- (NSString *)findLicenseFileInDir:(NSString *)dir licenseName:(NSString **)licenseName;

/// Find the license file with the same BundleID in the MainBundle
/// First look in MainBundle, if not found, it will look in LicenseBag.bundle
- (NSString *)findLicenseInMainBundleLicenseName:(NSString **)licenseName;
@end


#endif
