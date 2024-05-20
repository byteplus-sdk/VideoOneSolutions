// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface VELFileDownloadItem : NSObject
@property (nonatomic, strong, readonly) NSProgress *progress;
@property (nonatomic, copy, readonly) NSString *url;
@property (nonatomic, copy, readonly) NSString *filePath;
@property (nonatomic, copy, readonly) NSString *fileName;
@end

@interface VELFileDownloader : NSObject
+ (NSString *)filePathWithFileName:(NSString *)fileName;
+ (BOOL)fileExistWithFileName:(NSString *)fileName;
+ (void)downloadUrl:(NSString *)url
           fileName:(NSString *)fileName
      progressBlock:(void (^_Nullable)(CGFloat progress))progressBlock
    completionBlock:(void (^_Nullable)(VELFileDownloadItem *item, BOOL success, NSError *_Nullable error))completionBlock;
+ (void)checkUrl:(NSString *)url hostIsValid:(void (^)(BOOL isValid))completion;
@end

NS_ASSUME_NONNULL_END
