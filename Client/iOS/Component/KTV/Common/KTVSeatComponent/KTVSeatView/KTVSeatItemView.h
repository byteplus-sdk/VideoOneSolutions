// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>
@class KTVSeatModel;
@class KTVSongModel;

@interface KTVSeatItemView : UIView

@property (nonatomic, assign) NSInteger index;

@property (nonatomic, strong) KTVSeatModel *seatModel;

@property (nonatomic, copy) void (^clickBlock)(KTVSeatModel *seatModel);

- (void)updateCurrentSongModel:(KTVSongModel *)songModel;

@end
