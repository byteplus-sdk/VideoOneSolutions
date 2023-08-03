// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import <Foundation/Foundation.h>
#import "LiveSettingCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface LiveSettingData : NSObject

@property (class, nonatomic, assign) BOOL rtmPullStreaming;
@property (class, nonatomic, assign) BOOL rtmPushStreaming;
@property (class, nonatomic, assign) BOOL abr;

+ (BOOL)boolValueForKey:(LiveSettingCellType)key;
@end

NS_ASSUME_NONNULL_END
