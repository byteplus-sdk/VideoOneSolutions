// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>
#import "KTVRoomAudienceListsView.h"
#import "KTVRoomRaiseHandListsView.h"

NS_ASSUME_NONNULL_BEGIN

@interface KTVRoomUserListComponent : NSObject

- (void)showRoomModel:(KTVRoomModel *)roomModel
               seatID:(NSString *)seatID
         dismissBlock:(void (^)(void))dismissBlock;

- (void)update;

- (void)updateWithRed:(BOOL)isRed;

@end

NS_ASSUME_NONNULL_END
