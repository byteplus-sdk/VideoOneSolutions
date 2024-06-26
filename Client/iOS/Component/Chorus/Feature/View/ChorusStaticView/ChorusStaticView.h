// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import <UIKit/UIKit.h>
@class ChorusRoomModel;
@class ChorusRoomParamInfoModel;

NS_ASSUME_NONNULL_BEGIN
@interface ChorusStaticView : UIView

@property (nonatomic, copy) void(^closeButtonDidClickBlock)(void);

@property (nonatomic, strong) ChorusRoomModel *roomModel;

- (void)updatePeopleNum:(NSInteger)count;

@end

NS_ASSUME_NONNULL_END
