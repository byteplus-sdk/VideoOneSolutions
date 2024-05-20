// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>
@class KTVRoomModel;
@class KTVRoomParamInfoModel;

NS_ASSUME_NONNULL_BEGIN

@interface KTVStaticView : UIView

@property (nonatomic, strong) KTVRoomModel *roomModel;

@property (nonatomic, copy) void (^clickEndBlock)(void);

- (void)updatePeopleNum:(NSInteger)count;

- (void)updateParamInfoModel:(KTVRoomParamInfoModel *)paramInfoModel;

@end

NS_ASSUME_NONNULL_END
