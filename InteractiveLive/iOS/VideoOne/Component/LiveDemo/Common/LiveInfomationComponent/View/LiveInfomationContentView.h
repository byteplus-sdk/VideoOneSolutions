// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import <UIKit/UIKit.h>
#import "LiveInfomationModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LiveInfomationContentView : UIView

@property (nonatomic, copy) NSArray<LiveInfomationModel *> *basicDataLists;

@property (nonatomic, copy) NSArray<LiveInfomationModel *> *realTimeDataLists;

- (void)refresh;

@end

NS_ASSUME_NONNULL_END
