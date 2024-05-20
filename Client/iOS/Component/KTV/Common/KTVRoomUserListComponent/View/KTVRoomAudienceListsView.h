// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>
#import "KTVRoomUserListtCell.h"
@class KTVRoomAudienceListsView;

NS_ASSUME_NONNULL_BEGIN

@protocol KTVRoomAudienceListsViewDelegate <NSObject>

- (void)KTVRoomAudienceListsView:(KTVRoomAudienceListsView *)KTVRoomAudienceListsView clickButton:(KTVUserModel *)model;

@end


@interface KTVRoomAudienceListsView : UIView

@property (nonatomic, copy) NSArray<KTVUserModel *> *dataLists;

@property (nonatomic, weak) id<KTVRoomAudienceListsViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
