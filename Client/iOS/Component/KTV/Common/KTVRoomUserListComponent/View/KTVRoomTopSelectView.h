// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>
@class KTVRoomTopSelectView;

NS_ASSUME_NONNULL_BEGIN

@protocol KTVRoomTopSelectViewDelegate <NSObject>

- (void)KTVRoomTopSelectView:(KTVRoomTopSelectView *)KTVRoomTopSelectView clickCancelAction:(id)model;

- (void)KTVRoomTopSelectView:(KTVRoomTopSelectView *)KTVRoomTopSelectView clickSwitchItem:(BOOL)isAudience;

@end

@interface KTVRoomTopSelectView : UIView

@property (nonatomic, weak) id<KTVRoomTopSelectViewDelegate> delegate;

@property (nonatomic, copy) NSString *titleStr;

- (void)updateWithRed:(BOOL)isRed;

- (void)updateSelectItem:(BOOL)isLeft;

@end

NS_ASSUME_NONNULL_END
