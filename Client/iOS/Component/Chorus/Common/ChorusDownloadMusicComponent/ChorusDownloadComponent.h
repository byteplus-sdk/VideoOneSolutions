// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChorusDownloadComponent : NSObject

+ (void)downloadWithURL:(NSString *)urlString 
               filePath:(NSString *)filePath
               progress:(void (^)(NSProgress *downloadProgress))downloadProgressBlock
               complete:(void(^)(NSError *error))complete;

+ (NSString *)getMP3FilePath:(NSString *)musicID;

+ (NSString *)getLRCFilePath:(NSString *)musicID;

+ (NSString *)basePathString;

@end

NS_ASSUME_NONNULL_END
