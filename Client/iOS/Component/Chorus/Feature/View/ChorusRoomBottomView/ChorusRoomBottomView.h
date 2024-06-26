// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import <UIKit/UIKit.h>
#import "ChorusRoomItemButton.h"
@class ChorusRoomBottomView;

typedef NS_ENUM(NSInteger, ChorusRoomBottomStatus) {
    ChorusRoomBottomStatusLocalMic = 0,
    ChorusRoomBottomStatusInput,
    ChorusRoomBottomStatusPickSong,
    ChorusRoomBottomStatusLocalCamera,
    KTVRoomBottomStatusPickSong,
};

@protocol ChorusRoomBottomViewDelegate <NSObject>

- (void)chorusRoomBottomView:(ChorusRoomBottomView *_Nonnull)ChorusRoomBottomView
                     itemButton:(ChorusRoomItemButton *_Nullable)itemButton
                didSelectStatus:(ChorusRoomBottomStatus)status;

@end

NS_ASSUME_NONNULL_BEGIN

@interface ChorusRoomBottomView : UIView

@property (nonatomic, weak) id<ChorusRoomBottomViewDelegate> delegate;

- (void)updateBottomLists;

- (void)updateBottomStatus:(ChorusRoomBottomStatus)status isActive:(BOOL)isActive;

- (void)updatePickedSongCount:(NSInteger)count;

@end

NS_ASSUME_NONNULL_END
