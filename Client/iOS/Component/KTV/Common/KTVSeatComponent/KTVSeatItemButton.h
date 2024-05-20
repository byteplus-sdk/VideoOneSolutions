// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "BaseButton.h"

typedef NS_ENUM(NSInteger, KTVSheetStatus) {
    KTVSheetStatusInvite = 0,
    KTVSheetStatusKick,
    KTVSheetStatusOpenMic,
    KTVSheetStatusCloseMic,
    KTVSheetStatusLock,
    KTVSheetStatusUnlock,
    KTVSheetStatusApply,
    KTVSheetStatusLeave,
};

NS_ASSUME_NONNULL_BEGIN

@interface KTVSeatItemButton : BaseButton

@property (nonatomic, copy) NSString *desTitle;

@property (nonatomic, assign) KTVSheetStatus sheetState;

@end

NS_ASSUME_NONNULL_END
