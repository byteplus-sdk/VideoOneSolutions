// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import <UIKit/UIKit.h>
@class LiveGuestsMediaView;
typedef NS_ENUM(NSInteger, LiveGuestsMediaViewStatus) {
    LiveGuestsMediaViewStatusFilp = 0,
    LiveGuestsMediaViewStatusMic,
    LiveGuestsMediaViewStatusCamera,
    LiveGuestsMediaViewStatusDisconnect,
    LiveGuestsMediaViewStatusCancel,
};

NS_ASSUME_NONNULL_BEGIN

@protocol LiveGuestsMediaViewDelegate <NSObject>

- (void)guestsMediaView:(LiveGuestsMediaView *)guestsMediaView
            clickButton:(LiveGuestsMediaViewStatus)status
                isStart:(BOOL)isStart;

@end

@interface LiveGuestsMediaView : UIView

@property (nonatomic, weak) id<LiveGuestsMediaViewDelegate> delegate;

- (void)updateButtonStatus:(LiveGuestsMediaViewStatus)status
                   isStart:(BOOL)isStart;

@end

NS_ASSUME_NONNULL_END
