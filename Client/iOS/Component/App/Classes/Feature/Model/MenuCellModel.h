// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MenuCellModel : NSObject

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *desTitle;

@property (nonatomic, copy) NSString *link;
@property (nonatomic, assign) BOOL isMore;

@property (nonatomic) void (^block)(void);

@end

NS_ASSUME_NONNULL_END
