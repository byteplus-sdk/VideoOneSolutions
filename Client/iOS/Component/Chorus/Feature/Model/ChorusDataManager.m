// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import "ChorusDataManager.h"
#import "ChorusRTCManager.h"

@implementation ChorusDataManager

static ChorusDataManager *manager = nil;
static dispatch_once_t onceToken;

+ (instancetype)shared {
    dispatch_once(&onceToken, ^{
        manager = [[ChorusDataManager alloc] init];
    });
    return manager;
}

+ (void)destroyDataManager {
    [[self shared] resetDataManager];
    manager = nil;
    onceToken = 0;
}

- (BOOL)isHost {
    return [self.roomModel.hostUid isEqualToString:[LocalUserComponent userModel].uid];
}

- (BOOL)isLeadSinger {
    return [self.leadSingerUserModel.uid isEqualToString:[LocalUserComponent userModel].uid];
}

- (BOOL)isSuccentor {
    return [self.succentorUserModel.uid isEqualToString:[LocalUserComponent userModel].uid];
}

- (void)resetDataManager {
    self.leadSingerUserModel = nil;
    self.succentorUserModel = nil;
    self.currentSongModel = nil;
}


@end
