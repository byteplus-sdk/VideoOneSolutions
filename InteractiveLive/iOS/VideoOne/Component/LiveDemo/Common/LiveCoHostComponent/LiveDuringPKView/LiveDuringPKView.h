// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LiveDuringPKView : UIView

- (instancetype)initWithUserList:(NSArray<LiveUserModel *> *)userList;

@property (nonatomic, copy) void (^clickEndBlock)(void);

@end

NS_ASSUME_NONNULL_END
