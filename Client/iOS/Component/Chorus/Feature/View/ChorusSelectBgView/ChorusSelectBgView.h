// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChorusSelectBgView : UIView

@property (nonatomic, copy) void (^clickBlock)(NSString *imageName,
                                               NSString *smallImageName);

- (NSString *)getDefaults;

@end

NS_ASSUME_NONNULL_END
