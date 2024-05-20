// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import "VELFileConfig.h"
NS_ASSUME_NONNULL_BEGIN
typedef void (^VELFileDataBlock)(NSData *_Nullable data, CMTime pts);
typedef void (^FLEFileReadCompletionBlock)(NSError *_Nullable error, BOOL isEnd);
@interface VELFileReader : NSObject
@property (atomic, assign) BOOL repeat;
+ (instancetype)readerWithConfig:(__kindof VELFileConfig *)config;
- (void)startWithDataCallBack:(VELFileDataBlock)dataCallBack completion:(FLEFileReadCompletionBlock)completion;
- (void)stop;
- (void)pause;
- (void)resume;
@end

NS_ASSUME_NONNULL_END
