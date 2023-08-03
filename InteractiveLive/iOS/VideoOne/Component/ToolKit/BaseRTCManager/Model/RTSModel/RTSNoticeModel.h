// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RTSNoticeModel : NSObject

@property (nonatomic, copy) NSString *eventName;
@property (nonatomic, copy) NSString *timestamp;
@property (nonatomic, copy) NSDictionary *data;

@end

NS_ASSUME_NONNULL_END
