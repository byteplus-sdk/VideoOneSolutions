// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DramaDisrecordManager : NSObject

+ (instancetype)sharedInstance;

+ (void)destroyUnit;

+ (BOOL)isOpenDisrecord;

- (void)showDisRecordView;

- (void)hideDisRecordView;


@end

NS_ASSUME_NONNULL_END
