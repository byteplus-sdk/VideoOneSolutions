// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>

@class VEVideoModel;
@interface VEVideoUrlParser : NSObject

+ (NSArray<VEVideoModel *> *)parseUrl:(NSString *)urlString;

@end


