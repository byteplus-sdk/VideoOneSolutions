// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

#import "TTVideoEngineSourceCategory.h"
#import "BaseVideoModel.h"
#import <Foundation/Foundation.h>
#import <YYModel/YYModel.h>

NS_ASSUME_NONNULL_BEGIN

@class VECommentModel;

@interface VEVideoModel : BaseVideoModel <YYModel>

@property (nonatomic, copy) NSString* playType;

@end

NS_ASSUME_NONNULL_END
