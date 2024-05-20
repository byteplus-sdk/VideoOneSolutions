// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KTVSeatView : UIView

@property (nonatomic, copy) void (^clickBlock)(KTVSeatModel *seatModel);

@property (nonatomic, copy) NSArray<KTVSeatModel *> *seatList;

- (void)addSeatModel:(KTVSeatModel *)seatModel;

- (void)removeUserModel:(KTVUserModel *)userModel;

- (void)updateSeatModel:(KTVSeatModel *)seatModel;

- (void)updateSeatVolume:(NSDictionary *)volumeDic;

- (void)updateCurrentSongModel:(KTVSongModel *)songModel;

@end

NS_ASSUME_NONNULL_END
