// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>
#import "KTVRoomItemButton.h"
@class KTVRoomBottomView;

typedef NS_ENUM(NSInteger, KTVRoomBottomStatus) {
    KTVRoomBottomStatusPhone = 0,
    KTVRoomBottomStatusLocalMic,
    KTVRoomBottomStatusInput,
    KTVRoomBottomStatusPickSong,
};

@protocol KTVRoomBottomViewDelegate <NSObject>

- (void)KTVRoomBottomView:(KTVRoomBottomView *_Nonnull)KTVRoomBottomView
                     itemButton:(KTVRoomItemButton *_Nullable)itemButton
                didSelectStatus:(KTVRoomBottomStatus)status;

@end

NS_ASSUME_NONNULL_BEGIN

@interface KTVRoomBottomView : UIView

@property (nonatomic, weak) id<KTVRoomBottomViewDelegate> delegate;

- (void)updateBottomLists:(KTVUserModel *)userModel;

- (void)updateButtonStatus:(KTVRoomBottomStatus)status isSelect:(BOOL)isSelect;

- (void)updateButtonStatus:(KTVRoomBottomStatus)status isRed:(BOOL)isRed;

- (void)updatePickedSongCount:(NSInteger)count;

@end

NS_ASSUME_NONNULL_END
