//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LiveSettingQualityView : UIView

- (instancetype)initWithKey:(NSString *)key;

@property (nonatomic, copy) void (^clickBackBlock)(void);

@property (nonatomic, copy) void (^clickItemBlock)(NSString *key);

@end

NS_ASSUME_NONNULL_END
