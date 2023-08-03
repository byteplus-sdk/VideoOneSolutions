// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import <UIKit/UIKit.h>
@class LiveAddGuestsTopView;

NS_ASSUME_NONNULL_BEGIN

@protocol LiveAddGuestsTopViewDelegate <NSObject>

- (void)LiveAddGuestsTopView:(LiveAddGuestsTopView *)LiveAddGuestsTopView clickSwitchItem:(NSInteger)index;

@end

@interface LiveAddGuestsTopView : UIView

@property (nonatomic, weak) id<LiveAddGuestsTopViewDelegate> delegate;

@property (nonatomic, assign) BOOL isUnread;

- (void)simulateClick:(NSInteger)row;

@end

NS_ASSUME_NONNULL_END
