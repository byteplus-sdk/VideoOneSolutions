//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveEndLiveModel.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LiveEndViewController : UIViewController

- (instancetype)initWithModel:(LiveEndLiveModel *)endLiveModel;

@property (nonatomic, copy) void (^backBlock)(void);

@end

NS_ASSUME_NONNULL_END
