// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>
#import "VEVideoModel.h"


@interface VEVideoUrlParser : NSObject

+ (NSArray<VEVideoModel *> *)parseUrl:(NSString *)urlString;

@end


