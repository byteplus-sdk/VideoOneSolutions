// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import <UIKit/UIKit.h>
@class LiveHostMediaView;
typedef NS_ENUM(NSInteger, LiveHostMediaStatus) {
    LiveHostMediaStatusFilp = 0,
    LiveHostMediaStatusMic,
    LiveHostMediaStatusCamera,
    LiveHostMediaStatusInfo,
};

NS_ASSUME_NONNULL_BEGIN

@protocol LiveHostMediaViewDelegate <NSObject>

- (void)hostMediaView:(LiveHostMediaView *)hostMediaView
          clickButton:(LiveHostMediaStatus)status
             isStart:(BOOL)isStart;

@end

@interface LiveHostMediaView : UIView

@property (nonatomic, weak) id<LiveHostMediaViewDelegate> delegate;

- (void)updateButtonStatus:(LiveHostMediaStatus)status
                   isStart:(BOOL)isStart;

- (void)updateFlipImage:(LiveHostMediaStatus)status
                    currentFlipImage:(BOOL)currentFlipImage;

@end

NS_ASSUME_NONNULL_END
