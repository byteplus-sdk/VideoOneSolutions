// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>
#import "KTVSheetView.h"
@class KTVSeatComponent;

NS_ASSUME_NONNULL_BEGIN

@protocol KTVSeatDelegate <NSObject>

- (void)seatComponent:(KTVSeatComponent *)seatComponent
          clickButton:(KTVSeatModel *)seatModel
          sheetStatus:(KTVSheetStatus)sheetStatus;

@end

@interface KTVSeatComponent : NSObject

@property (nonatomic, weak) id<KTVSeatDelegate> delegate;

- (instancetype)initWithSuperView:(UIView *)superView;

- (void)showSeatView:(NSArray<KTVSeatModel *> *)seatList
      loginUserModel:(KTVUserModel *)loginUserModel;

- (void)addSeatModel:(KTVSeatModel *)seatModel;

- (void)removeUserModel:(KTVUserModel *)userModel;

- (void)updateSeatModel:(KTVSeatModel *)seatModel;

- (void)updateSeatVolume:(NSDictionary *)volumeDic;

- (void)updateCurrentSongModel:(KTVSongModel *)songModel;

- (void)dismissSheetView;

- (void)dismissSheetViewWithSeatId:(NSString *)seatId;

@end

NS_ASSUME_NONNULL_END
