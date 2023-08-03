// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import <UIKit/UIKit.h>
@class LivePKContentView;

NS_ASSUME_NONNULL_BEGIN

@protocol LivePKContentViewDelegate <NSObject>

- (void)livePKContentView:(LivePKContentView *)livePKContentView
              clickButton:(LiveUserModel *)userModel;

@end

@interface LivePKContentView : UIView

@property (nonatomic, copy) NSArray<LiveUserModel *> *dataLists;

@property (nonatomic, weak) id<LivePKContentViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
