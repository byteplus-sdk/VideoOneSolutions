// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>
#import "VELFileConfig.h"
NS_ASSUME_NONNULL_BEGIN

@interface VELFileWritter : NSObject
@property (nonatomic, copy, nullable) NSString *fileNamePrefix;
@property (nonatomic, strong, nullable) VELFileConfig *fileConfig;
- (instancetype)initWithFileConfig:(nullable VELFileConfig *)fileConfig;
- (void)writeData:(NSData *)data;
- (void)writeBuffer:(const char *)buffer length:(int)length;
- (void)close;
@end

NS_ASSUME_NONNULL_END
