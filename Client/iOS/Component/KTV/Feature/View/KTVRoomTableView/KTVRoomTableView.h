// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>
#import "KTVRoomCell.h"
@class KTVRoomTableView;

NS_ASSUME_NONNULL_BEGIN

@protocol KTVRoomTableViewDelegate <NSObject>

- (void)KTVRoomTableView:(KTVRoomTableView *)KTVRoomTableView didSelectRowAtIndexPath:(KTVRoomModel *)model;

@end

@interface KTVRoomTableView : UIView

@property (nonatomic, copy) NSArray *dataLists;

@property (nonatomic, weak) id<KTVRoomTableViewDelegate> delegate;


@end

NS_ASSUME_NONNULL_END
