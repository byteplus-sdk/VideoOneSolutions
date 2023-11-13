//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveUserModel.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RoomStatusModel : NSObject

@property (nonatomic, assign) LiveInteractStatus interactStatus;

@property (nonatomic, copy) NSArray<LiveUserModel *> *interactUserList;

@end

NS_ASSUME_NONNULL_END
