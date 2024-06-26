// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>
@class KTVPickSongComponent;

NS_ASSUME_NONNULL_BEGIN

@protocol KTVPickSongComponentDelegate <NSObject>

- (void)ktvPickSongComponent:(KTVPickSongComponent *)component pickedSongCountChanged:(NSInteger)count;

@end

@interface KTVPickSongComponent : NSObject

@property (nonatomic, weak) id<KTVPickSongComponentDelegate> delegate;

- (instancetype)initWithSuperView:(UIView *)superView roomID:(NSString *)roomID;

- (void)show;

- (void)dismissView;

- (void)showPickedSongList;

- (void)requestMusicListWithBlock:(void(^)(NSArray <KTVSongModel *> *musicList))complete;

/// Update pieked song list
- (void)updatePickedSongList;

@end

NS_ASSUME_NONNULL_END
