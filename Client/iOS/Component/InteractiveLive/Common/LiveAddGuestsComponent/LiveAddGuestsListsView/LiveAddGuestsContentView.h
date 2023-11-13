//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <UIKit/UIKit.h>
@class LiveAddGuestsContentView;

NS_ASSUME_NONNULL_BEGIN

@protocol LiveAddGuestsDelegate <NSObject>

- (void)liveAddGuests:(LiveAddGuestsContentView *)liveAddGuests
          clickReject:(LiveUserModel *)model;

- (void)liveAddGuests:(LiveAddGuestsContentView *)liveAddGuests
           clickAgree:(LiveUserModel *)model;

- (void)liveAddGuests:(LiveAddGuestsContentView *)liveAddGuests
            clickKick:(LiveUserModel *)model;

- (void)liveAddGuests:(LiveAddGuestsContentView *)liveAddGuests
    clickCloseConnect:(BOOL)isEnd;

- (void)liveAddGuests:(LiveAddGuestsContentView *)liveAddGuests
             clickMic:(LiveUserModel *)model;

- (void)liveAddGuests:(LiveAddGuestsContentView *)liveAddGuests
          clickCamera:(LiveUserModel *)model;

@end

@interface LiveAddGuestsContentView : UIView

@property (nonatomic, assign) id<LiveAddGuestsDelegate> delegate;

@property (nonatomic, copy) NSArray<LiveUserModel *> *onlineDataLists;

@property (nonatomic, copy) NSArray<LiveUserModel *> *applicationDataLists;

@property (nonatomic, assign) BOOL isUnread;

@property (nonatomic, copy) void (^clickMaskBlcok)(void);

@property (nonatomic, copy) void (^requestRefreshBlcok)(void);

- (void)switchApplicationList;

- (BOOL)IsDisplayApplyList;

- (void)updateGuestsMic:(BOOL)mic uid:(NSString *)uid;

- (void)updateGuestsCamera:(BOOL)camera uid:(NSString *)uid;

- (void)updateCoHostStartTime:(NSDate *)time;

@end

NS_ASSUME_NONNULL_END
