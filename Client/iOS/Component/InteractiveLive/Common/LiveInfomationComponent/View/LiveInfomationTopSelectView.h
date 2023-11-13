//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <UIKit/UIKit.h>
@class LiveInfomationTopSelectView;

NS_ASSUME_NONNULL_BEGIN

@protocol LiveInfomationTopSelectViewDelegate <NSObject>

- (void)LiveInfomationTopSelectView:(LiveInfomationTopSelectView *)LiveInfomationTopSelectView clickSwitchItem:(NSInteger)index;

@end

@interface LiveInfomationTopSelectView : UIView

@property (nonatomic, weak) id<LiveInfomationTopSelectViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
