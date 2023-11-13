//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LivePKCell.h"
#import <UIKit/UIKit.h>
@class LivePKListsView;

NS_ASSUME_NONNULL_BEGIN

@protocol LivePKListsViewDelegate <NSObject>

- (void)LivePKListsView:(LivePKListsView *)LivePKListsView
            clickButton:(LiveUserModel *)model;

@end

@interface LivePKListsView : UIView

@property (nonatomic, copy) NSArray<LiveUserModel *> *dataLists;

@property (nonatomic, weak) id<LivePKListsViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
