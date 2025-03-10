// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#ifndef BoardBottomView_h
#define BoardBottomView_h

#import <UIKit/UIKit.h>

@class BoardBottomView;
@protocol BoardBottomViewDelegate <NSObject>

- (void)boardBottomView:(BoardBottomView *)view didTapClose:(UIView *)sender;
- (void)boardBottomView:(BoardBottomView *)view didTapRecord:(UIView *)sender;
@optional
- (BOOL)boardBottomViewShowReset:(BoardBottomView *)view;
- (void)boardBottomView:(BoardBottomView *)view didTapReset:(UIView *)sender;

@end

@interface BoardBottomView : UIView

@property (nonatomic, weak) id<BoardBottomViewDelegate> delegate;
@property (nonatomic, strong) UIButton *btnRecord;

@end


#endif /* BoardBottomView_h */
