// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface ChorusDataManager : NSObject

@property (nonatomic, strong) ChorusRoomModel *roomModel;
@property (nonatomic, strong) ChorusUserModel *_Nullable leadSingerUserModel;
@property (nonatomic, strong) ChorusUserModel *_Nullable succentorUserModel;
@property (nonatomic, strong) ChorusSongModel *_Nullable currentSongModel;
@property (nonatomic, assign, readonly) BOOL isHost;
@property (nonatomic, assign, readonly) BOOL isLeadSinger;
@property (nonatomic, assign, readonly) BOOL isSuccentor;

+ (instancetype)shared;

+ (void)destroyDataManager;

- (void)resetDataManager;

@end

NS_ASSUME_NONNULL_END
